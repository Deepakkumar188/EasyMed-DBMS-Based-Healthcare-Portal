// routes/appointment.js
const express = require('express');
const router  = express.Router();
const { query } = require('../config/db');
const { ensurePatient } = require('../middleware/auth');

// Step 1: Choose Department
router.get('/book', ensurePatient, async (req, res) => {
    const departments = await query('SELECT * FROM departments WHERE is_active=1 ORDER BY dept_name');
    res.render('appointment/step1-dept', { title: 'Book Appointment - Choose Department', departments });
});

// Step 2: Choose Doctor
router.get('/book/doctor', ensurePatient, async (req, res) => {
    const { dept_id } = req.query;
    if (!dept_id) return res.redirect('/appointment/book');
    const doctors = await query(
        `SELECT d.*, dep.dept_name FROM doctors d
         JOIN departments dep ON d.dept_id=dep.dept_id
         WHERE d.dept_id=? AND d.is_active=1`, [dept_id]);
    const dept = (await query('SELECT * FROM departments WHERE dept_id=?', [dept_id]))[0];
    res.render('appointment/step2-doctor', { title: 'Book Appointment - Choose Doctor', doctors, dept });
});

// Step 3: Choose Date/Time
router.get('/book/slot', ensurePatient, async (req, res) => {
    const { doctor_id } = req.query;
    if (!doctor_id) return res.redirect('/appointment/book');
    const doctor = (await query(
        `SELECT d.*, dep.dept_name, dep.dept_id FROM doctors d
         JOIN departments dep ON d.dept_id=dep.dept_id
         WHERE d.doctor_id=?`, [doctor_id]))[0];
    if (!doctor) return res.redirect('/appointment/book');
    const schedules = await query('SELECT * FROM doctor_schedules WHERE doctor_id=? AND is_available=1', [doctor_id]);
    res.render('appointment/step3-slot', { title: 'Book Appointment - Choose Slot', doctor, schedules });
});

// Step 4: Confirm & Submit
router.post('/book/confirm', ensurePatient, async (req, res) => {
    const { doctor_id, appt_date, appt_time, appt_type, reason, symptoms } = req.body;
    if (!doctor_id || !appt_date || !appt_time) {
        req.flash('error_msg','All fields are required.');
        return res.redirect('/appointment/book');
    }
    try {
        const doctor = (await query(
            `SELECT d.*, dep.dept_id, dep.dept_name FROM doctors d
             JOIN departments dep ON d.dept_id=dep.dept_id
             WHERE d.doctor_id=?`, [doctor_id]))[0];
        // Check slot conflict
        const conflict = await query(
            `SELECT appt_id FROM appointments
             WHERE doctor_id=? AND appt_date=? AND appt_time=?
               AND status NOT IN ('Cancelled','No-Show')`, [doctor_id, appt_date, appt_time]);
        if (conflict.length) {
            req.flash('error_msg','This time slot is already booked. Please choose another.');
            return res.redirect(`/appointment/book/slot?doctor_id=${doctor_id}`);
        }
        const pid = req.session.patient.patient_id;
        const uid = 'APT' + Date.now().toString().slice(-8);
        await query(
            `INSERT INTO appointments (appt_uid, patient_id, doctor_id, dept_id, appt_date, appt_time, appt_type, reason, symptoms, fee, status)
             VALUES (?,?,?,?,?,?,?,?,?,?,'Confirmed')`,
            [uid, pid, doctor_id, doctor.dept_id, appt_date, appt_time,
             appt_type||'Consultation', reason||null, symptoms||null, doctor.consultation_fee]);
        const apptId = (await query('SELECT appt_id FROM appointments WHERE appt_uid=?', [uid]))[0]?.appt_id;
        // Notification
        await query(
            `INSERT INTO notifications (user_type, user_id, title, message, type)
             VALUES ('Patient',?,'Appointment Confirmed',
             CONCAT('Your appointment with Dr. ',?,? ,' is confirmed for ',?,' at ',?),
             'Appointment')`,
            [pid, doctor.first_name, doctor.last_name, appt_date, appt_time]);
        req.flash('success_msg', `Appointment booked successfully! ID: ${uid}`);
        res.redirect(`/appointment/confirmation/${apptId}`);
    } catch (err) {
        console.error(err);
        req.flash('error_msg','Failed to book appointment. Please try again.');
        res.redirect('/appointment/book');
    }
});

// Confirmation Page
router.get('/confirmation/:id', ensurePatient, async (req, res) => {
    const pid = req.session.patient.patient_id;
    const appt = (await query(
        `SELECT a.*, CONCAT('Dr. ',d.first_name,' ',d.last_name) AS doctor_name,
                d.specialization, d.qualification, d.phone AS doctor_phone,
                dep.dept_name, dep.floor_number
         FROM appointments a
         JOIN doctors d ON a.doctor_id=d.doctor_id
         JOIN departments dep ON a.dept_id=dep.dept_id
         WHERE a.appt_id=? AND a.patient_id=?`, [req.params.id, pid]))[0];
    if (!appt) return res.redirect('/patient/appointments');
    res.render('appointment/confirmation', { title: 'Appointment Confirmed', appt });
});

// Get available slots (AJAX)
router.get('/slots', ensurePatient, async (req, res) => {
    const { doctor_id, date } = req.query;
    if (!doctor_id || !date) return res.json({ slots: [] });
    try {
        const dayName = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][new Date(date).getDay()];
        const schedule = (await query(
            'SELECT * FROM doctor_schedules WHERE doctor_id=? AND day_of_week=? AND is_available=1',
            [doctor_id, dayName]))[0];
        if (!schedule) return res.json({ slots: [], message: 'Doctor not available on this day' });
        // Generate time slots
        const slots = [];
        const booked = await query(
            `SELECT appt_time FROM appointments
             WHERE doctor_id=? AND appt_date=? AND status NOT IN ('Cancelled','No-Show')`,
            [doctor_id, date]);
        const bookedTimes = booked.map(b => b.appt_time.slice(0,5));
        let current = schedule.start_time.slice(0,5);
        const end   = schedule.end_time.slice(0,5);
        while (current < end) {
            const [h, m] = current.split(':').map(Number);
            const next   = `${String(h + Math.floor((m + schedule.slot_duration) / 60)).padStart(2,'0')}:${String((m + schedule.slot_duration) % 60).padStart(2,'0')}`;
            slots.push({ time: current, available: !bookedTimes.includes(current) });
            current = next;
        }
        res.json({ slots, schedule });
    } catch (err) {
        res.json({ slots: [], error: err.message });
    }
});

module.exports = router;
