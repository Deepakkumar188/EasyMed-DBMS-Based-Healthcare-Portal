const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { isDoctor } = require('../middleware/auth');
const moment = require('moment');

router.use(isDoctor);

router.get('/dashboard', async (req, res) => {
  try {
    const [d] = await db.query('SELECT * FROM doctors WHERE user_id=?', [req.user.user_id]);
    if (!d.length) { req.flash('error','Doctor profile not found.'); return res.redirect('/auth/logout'); }
    const doctor = d[0];
    const [todayAppts] = await db.query('SELECT * FROM vw_appointment_details WHERE doctor_name LIKE ? AND appointment_date=CURDATE() ORDER BY appointment_time', [`%${req.user.last_name}%`]);
    const [upcomingAppts] = await db.query('SELECT * FROM vw_appointment_details WHERE doctor_name LIKE ? AND appointment_date>CURDATE() ORDER BY appointment_date,appointment_time LIMIT 10', [`%${req.user.last_name}%`]);
    const [[counts]] = await db.query(`SELECT COUNT(*) as total,(SELECT COUNT(*) FROM appointments WHERE doctor_id=? AND appointment_date=CURDATE()) as today,(SELECT COUNT(*) FROM appointments WHERE doctor_id=? AND status='Completed' AND MONTH(appointment_date)=MONTH(CURDATE())) as monthly,(SELECT COUNT(*) FROM appointments WHERE doctor_id=? AND status='Scheduled' AND appointment_date>=CURDATE()) as pending FROM appointments WHERE doctor_id=?`, [doctor.doctor_id,doctor.doctor_id,doctor.doctor_id,doctor.doctor_id,doctor.doctor_id]);
    res.render('doctor/dashboard', { title: 'Doctor Dashboard - EasyMed', doctor, todayAppts, upcomingAppts, counts });
  } catch(e) { console.error(e); res.render('doctor/dashboard', { title:'Doctor Dashboard',doctor:{},todayAppts:[],upcomingAppts:[],counts:{} }); }
});

router.get('/appointments', async (req, res) => {
  const [d] = await db.query('SELECT * FROM doctors WHERE user_id=?', [req.user.user_id]);
  const date = req.query.date || moment().format('YYYY-MM-DD');
  const [appointments] = await db.query('SELECT * FROM vw_appointment_details WHERE doctor_name LIKE ? AND appointment_date=? ORDER BY appointment_time', [`%${req.user.last_name}%`, date]);
  res.render('doctor/appointments', { title: 'My Appointments - EasyMed', appointments, doctor: d[0], date, moment });
});

router.post('/appointments/:id/start', async (req, res) => {
  await db.query("UPDATE appointments SET status='In-Progress' WHERE appointment_id=?", [req.params.id]);
  res.redirect('/doctor/appointments');
});

router.get('/appointments/:id/record', async (req, res) => {
  const [appt] = await db.query('SELECT * FROM vw_appointment_details WHERE appointment_id=?', [req.params.id]);
  if (!appt.length) { req.flash('error','Appointment not found'); return res.redirect('/doctor/appointments'); }
  const [d] = await db.query('SELECT * FROM doctors WHERE user_id=?', [req.user.user_id]);
  const [p] = await db.query('SELECT * FROM patients WHERE patient_code=?', [appt[0].patient_code]);
  const [prevRecords] = await db.query('SELECT * FROM medical_records WHERE patient_id=? ORDER BY visit_date DESC LIMIT 5', [p[0].patient_id]);
  res.render('doctor/create-record', { title: 'Create Medical Record - EasyMed', appt: appt[0], doctor: d[0], patient: p[0], prevRecords });
});

router.post('/appointments/:id/record', async (req, res) => {
  try {
    const [appt] = await db.query('SELECT * FROM vw_appointment_details WHERE appointment_id=?', [req.params.id]);
    const [d] = await db.query('SELECT * FROM doctors WHERE user_id=?', [req.user.user_id]);
    const [p] = await db.query('SELECT * FROM patients WHERE patient_code=?', [appt[0].patient_code]);
    const vitals = JSON.stringify({ bp: req.body.bp, pulse: req.body.pulse, temp: req.body.temperature, spo2: req.body.spo2, weight: req.body.weight, height: req.body.height });
    await db.query(
      'INSERT INTO medical_records (appointment_id,patient_id,doctor_id,visit_date,chief_complaint,history_of_illness,physical_examination,vital_signs,diagnosis,treatment_plan,prescription,lab_tests_ordered,follow_up_date,doctor_notes) VALUES (?,?,?,CURDATE(),?,?,?,?,?,?,?,?,?,?)',
      [req.params.id, p[0].patient_id, d[0].doctor_id, req.body.chief_complaint, req.body.history, req.body.examination, vitals, req.body.diagnosis, req.body.treatment, req.body.prescription_text, req.body.lab_tests, req.body.follow_up_date||null, req.body.doctor_notes]
    );
    await db.query("UPDATE appointments SET status='Completed' WHERE appointment_id=?", [req.params.id]);
    req.flash('success','Medical record saved and appointment completed.');
    res.redirect('/doctor/appointments');
  } catch(e) { console.error(e); req.flash('error','Failed to save record.'); res.redirect(`/doctor/appointments/${req.params.id}/record`); }
});

router.get('/patients', async (req, res) => {
  const [d] = await db.query('SELECT * FROM doctors WHERE user_id=?', [req.user.user_id]);
  const [patients] = await db.query(`SELECT DISTINCT p.*,u.first_name,u.last_name,u.email,u.phone,u.blood_group,MAX(a.appointment_date) as last_visit FROM appointments a JOIN patients p ON a.patient_id=p.patient_id JOIN users u ON p.user_id=u.user_id WHERE a.doctor_id=? GROUP BY p.patient_id ORDER BY last_visit DESC`, [d[0].doctor_id]);
  res.render('doctor/patients', { title: 'My Patients - EasyMed', patients, doctor: d[0] });
});

router.get('/schedule', async (req, res) => {
  const [d] = await db.query('SELECT * FROM doctors WHERE user_id=?', [req.user.user_id]);
  const [schedules] = await db.query('SELECT * FROM doctor_schedules WHERE doctor_id=? ORDER BY FIELD(day_of_week,"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")', [d[0].doctor_id]);
  res.render('doctor/schedule', { title: 'My Schedule - EasyMed', schedules, doctor: d[0] });
});

router.get('/profile', async (req, res) => {
  const [d] = await db.query('SELECT d.*,u.first_name,u.last_name,u.email,u.phone,u.gender,u.date_of_birth,u.blood_group,u.profile_image,dept.dept_name FROM doctors d JOIN users u ON d.user_id=u.user_id LEFT JOIN departments dept ON d.dept_id=dept.dept_id WHERE d.user_id=?', [req.user.user_id]);
  res.render('doctor/profile', { title: 'My Profile - EasyMed', doctor: d[0] });
});

module.exports = router;
