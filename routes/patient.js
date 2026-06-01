const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { isPatient } = require('../middleware/auth');
const moment = require('moment');

router.use(isPatient);

router.get('/dashboard', async (req, res) => {
  try {
    const [p] = await db.query('SELECT * FROM patients WHERE user_id=?', [req.user.user_id]);
    if (!p.length) { req.flash('error','Patient profile not found.'); return res.redirect('/auth/logout'); }
    const patient = p[0];
    const [upcomingAppts] = await db.query('SELECT * FROM vw_appointment_details WHERE patient_code=? AND appointment_date>=CURDATE() AND status NOT IN ("Cancelled","Completed") ORDER BY appointment_date,appointment_time LIMIT 5', [patient.patient_code]);
    const [recentAppts] = await db.query('SELECT * FROM vw_appointment_details WHERE patient_code=? ORDER BY appointment_date DESC LIMIT 5', [patient.patient_code]);
    const [notifications] = await db.query('SELECT * FROM notifications WHERE user_id=? AND is_read=0 ORDER BY created_at DESC LIMIT 5', [req.user.user_id]);
    const [bills] = await db.query('SELECT * FROM bills WHERE patient_id=? AND payment_status!="Paid" ORDER BY bill_date DESC LIMIT 5', [patient.patient_id]);
    const [[counts]] = await db.query(`SELECT COUNT(*) as total_appointments,(SELECT COUNT(*) FROM appointments WHERE patient_id=? AND status='Completed') as completed,(SELECT COUNT(*) FROM appointments WHERE patient_id=? AND appointment_date>=CURDATE() AND status='Scheduled') as upcoming,(SELECT COALESCE(SUM(balance_amount),0) FROM bills WHERE patient_id=? AND payment_status!='Paid') as pending_dues FROM appointments WHERE patient_id=?`, [patient.patient_id,patient.patient_id,patient.patient_id,patient.patient_id,patient.patient_id]);
    res.render('patient/dashboard', { title: 'Patient Dashboard - EasyMed', patient, upcomingAppts, recentAppts, notifications, bills, counts });
  } catch(e) { console.error(e); res.render('patient/dashboard', { title:'Patient Dashboard',patient:{},upcomingAppts:[],recentAppts:[],notifications:[],bills:[],counts:{} }); }
});

router.get('/appointments', async (req, res) => {
  const [p] = await db.query('SELECT * FROM patients WHERE user_id=?', [req.user.user_id]);
  const [appointments] = await db.query('SELECT * FROM vw_appointment_details WHERE patient_code=? ORDER BY appointment_date DESC,appointment_time DESC', [p[0].patient_code]);
  res.render('patient/appointments', { title: 'My Appointments - EasyMed', appointments, patient: p[0] });
});

router.get('/book-appointment', async (req, res) => {
  const [doctors] = await db.query('SELECT * FROM vw_doctor_profile WHERE is_available=1 ORDER BY full_name');
  const [depts] = await db.query('SELECT * FROM departments WHERE is_active=1 ORDER BY dept_name');
  res.render('patient/book-appointment', { title: 'Book Appointment - EasyMed', doctors, depts, errors: [], formData: {} });
});

router.post('/book-appointment', async (req, res) => {
  try {
    const [p] = await db.query('SELECT * FROM patients WHERE user_id=?', [req.user.user_id]);
    const patient = p[0];
    const [doc] = await db.query('SELECT * FROM doctors WHERE doctor_id=?', [req.body.doctor_id]);
    if (!doc.length) { req.flash('error','Doctor not found.'); return res.redirect('/patient/book-appointment'); }
    const fee = req.body.appointment_type === 'Follow-up' ? doc[0].follow_up_fee : doc[0].consultation_fee;
    const apt_code = 'APT' + moment().format('YYYYMM') + Math.floor(Math.random()*99999).toString().padStart(5,'0');
    await db.query(
      'INSERT INTO appointments (appointment_code,patient_id,doctor_id,dept_id,appointment_date,appointment_time,appointment_type,status,reason_for_visit,symptoms,priority,consultation_fee,payment_status,booked_by) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [apt_code, patient.patient_id, req.body.doctor_id, doc[0].dept_id, req.body.appointment_date, req.body.appointment_time, req.body.appointment_type||'New', 'Scheduled', req.body.reason||'', req.body.symptoms||'', req.body.priority||'Normal', fee, 'Pending', req.user.user_id]
    );
    await db.query('INSERT INTO notifications (user_id,title,message,type) VALUES (?,?,?,?)',
      [req.user.user_id, 'Appointment Booked!', `Your appointment ${apt_code} has been scheduled for ${moment(req.body.appointment_date).format('DD MMM YYYY')} at ${req.body.appointment_time}.`, 'Appointment']);
    req.flash('success', `Appointment booked successfully! Your Appointment ID: ${apt_code}`);
    res.redirect('/patient/appointments');
  } catch(e) { console.error(e); req.flash('error','Booking failed. Try again.'); res.redirect('/patient/book-appointment'); }
});

router.post('/appointments/:id/cancel', async (req, res) => {
  const [p] = await db.query('SELECT * FROM patients WHERE user_id=?', [req.user.user_id]);
  await db.query("UPDATE appointments SET status='Cancelled',cancellation_reason=?,cancelled_by='Patient' WHERE appointment_id=? AND patient_id=?", [req.body.reason||'Cancelled by patient', req.params.id, p[0].patient_id]);
  req.flash('success','Appointment cancelled.');
  res.redirect('/patient/appointments');
});

router.get('/medical-records', async (req, res) => {
  const [p] = await db.query('SELECT * FROM patients WHERE user_id=?', [req.user.user_id]);
  const [records] = await db.query(`SELECT mr.*,CONCAT(u.first_name," ",u.last_name) as doctor_name,d.specialization FROM medical_records mr JOIN doctors doc ON mr.doctor_id=doc.doctor_id JOIN users u ON doc.user_id=u.user_id LEFT JOIN departments d ON doc.dept_id=d.dept_id WHERE mr.patient_id=? ORDER BY visit_date DESC`, [p[0].patient_id]);
  res.render('patient/medical-records', { title: 'Medical Records - EasyMed', records, patient: p[0] });
});

router.get('/prescriptions', async (req, res) => {
  const [p] = await db.query('SELECT * FROM patients WHERE user_id=?', [req.user.user_id]);
  const [prescriptions] = await db.query(`SELECT pr.*,CONCAT(u.first_name," ",u.last_name) as doctor_name FROM prescriptions pr JOIN doctors d ON pr.doctor_id=d.doctor_id JOIN users u ON d.user_id=u.user_id WHERE pr.patient_id=? ORDER BY prescription_date DESC`, [p[0].patient_id]);
  for (const pres of prescriptions) {
    const [items] = await db.query('SELECT * FROM prescription_items WHERE prescription_id=?', [pres.prescription_id]);
    pres.items = items;
  }
  res.render('patient/prescriptions', { title: 'Prescriptions - EasyMed', prescriptions, patient: p[0] });
});

router.get('/lab-results', async (req, res) => {
  const [p] = await db.query('SELECT * FROM patients WHERE user_id=?', [req.user.user_id]);
  const [tests] = await db.query(`SELECT lt.*,CONCAT(u.first_name," ",u.last_name) as doctor_name FROM lab_tests lt JOIN doctors d ON lt.doctor_id=d.doctor_id JOIN users u ON d.user_id=u.user_id WHERE lt.patient_id=? ORDER BY ordered_date DESC`, [p[0].patient_id]);
  res.render('patient/lab-results', { title: 'Lab Results - EasyMed', tests, patient: p[0] });
});

router.get('/bills', async (req, res) => {
  const [p] = await db.query('SELECT * FROM patients WHERE user_id=?', [req.user.user_id]);
  const [bills] = await db.query('SELECT b.*,(SELECT COUNT(*) FROM bill_items WHERE bill_id=b.bill_id) as item_count FROM bills b WHERE b.patient_id=? ORDER BY b.bill_date DESC', [p[0].patient_id]);
  res.render('patient/bills', { title: 'Bills & Payments - EasyMed', bills, patient: p[0] });
});

router.get('/profile', async (req, res) => {
  const [p] = await db.query('SELECT p.*,u.first_name,u.last_name,u.email,u.phone,u.gender,u.date_of_birth,u.blood_group,u.profile_image FROM patients p JOIN users u ON p.user_id=u.user_id WHERE p.user_id=?', [req.user.user_id]);
  res.render('patient/profile', { title: 'My Profile - EasyMed', patient: p[0], errors: [] });
});

router.post('/profile', async (req, res) => {
  await db.query('UPDATE users SET phone=?,blood_group=? WHERE user_id=?', [req.body.phone, req.body.blood_group, req.user.user_id]);
  await db.query('UPDATE patients SET address=?,city=?,state=?,pincode=?,emergency_contact_name=?,emergency_contact_phone=?,emergency_contact_relation=?,occupation=?,known_allergies=?,chronic_conditions=?,current_medications=? WHERE user_id=?',
    [req.body.address,req.body.city,req.body.state,req.body.pincode,req.body.emergency_name,req.body.emergency_phone,req.body.emergency_relation,req.body.occupation,req.body.known_allergies,req.body.chronic_conditions,req.body.current_medications,req.user.user_id]);
  req.flash('success','Profile updated successfully!');
  res.redirect('/patient/profile');
});

module.exports = router;
