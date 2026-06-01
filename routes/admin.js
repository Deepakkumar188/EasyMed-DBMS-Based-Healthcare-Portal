const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { isAdmin } = require('../middleware/auth');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

router.use(isAdmin);

router.get('/dashboard', async (req, res) => {
  try {
    const [[stats]] = await db.query('CALL sp_dashboard_stats()');
    const [recentAppointments] = await db.query('SELECT * FROM vw_appointment_details ORDER BY appointment_date DESC, appointment_time DESC LIMIT 10');
    const [recentPatients] = await db.query('SELECT * FROM vw_patient_summary ORDER BY patient_id DESC LIMIT 8');
    const [monthlyRevenue] = await db.query(`
      SELECT DATE_FORMAT(bill_date,'%b %Y') as month, SUM(total_amount) as revenue, COUNT(*) as bills
      FROM bills WHERE bill_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) GROUP BY DATE_FORMAT(bill_date,'%Y-%m') ORDER BY bill_date`);
    const [deptStats] = await db.query(`
      SELECT d.dept_name, COUNT(a.appointment_id) as appointments FROM departments d
      LEFT JOIN appointments a ON d.dept_id=a.dept_id AND MONTH(a.appointment_date)=MONTH(CURDATE())
      GROUP BY d.dept_id ORDER BY appointments DESC LIMIT 8`);
    res.render('admin/dashboard', { title: 'Admin Dashboard - EasyMed', stats: stats || {}, recentAppointments, recentPatients, monthlyRevenue, deptStats });
  } catch(e) {
    console.error(e);
    res.render('admin/dashboard', { title: 'Admin Dashboard - EasyMed', stats: {}, recentAppointments: [], recentPatients: [], monthlyRevenue: [], deptStats: [] });
  }
});

router.get('/patients', async (req, res) => {
  const search = req.query.search || '';
  const page = parseInt(req.query.page) || 1;
  const limit = 15;
  const offset = (page-1)*limit;
  let query = 'SELECT * FROM vw_patient_summary';
  let params = [];
  if (search) { query += ' WHERE full_name LIKE ? OR patient_code LIKE ? OR email LIKE ?'; params = [`%${search}%`,`%${search}%`,`%${search}%`]; }
  query += ' ORDER BY patient_id DESC LIMIT ? OFFSET ?';
  params.push(limit, offset);
  const [patients] = await db.query(query, params);
  const [[{total}]] = await db.query('SELECT COUNT(*) as total FROM vw_patient_summary' + (search ? ' WHERE full_name LIKE ? OR patient_code LIKE ?' : ''), search ? [`%${search}%`,`%${search}%`] : []);
  res.render('admin/patients', { title: 'Patients - EasyMed Admin', patients, search, page, total, limit });
});

router.get('/patients/:id', async (req, res) => {
  const [p] = await db.query('SELECT p.*,u.* FROM patients p JOIN users u ON p.user_id=u.user_id WHERE p.patient_id=?', [req.params.id]);
  if (!p.length) { req.flash('error','Patient not found'); return res.redirect('/admin/patients'); }
  const [appointments] = await db.query('SELECT * FROM vw_appointment_details WHERE patient_code=? ORDER BY appointment_date DESC LIMIT 20', [p[0].patient_code]);
  const [records] = await db.query('SELECT mr.*,CONCAT(u.first_name," ",u.last_name) as doctor_name FROM medical_records mr JOIN doctors d ON mr.doctor_id=d.doctor_id JOIN users u ON d.user_id=u.user_id WHERE mr.patient_id=? ORDER BY visit_date DESC', [req.params.id]);
  const [bills] = await db.query('SELECT * FROM bills WHERE patient_id=? ORDER BY bill_date DESC', [req.params.id]);
  res.render('admin/patient-detail', { title: 'Patient Detail - EasyMed', patient: p[0], appointments, records, bills });
});

router.get('/doctors', async (req, res) => {
  const [doctors] = await db.query('SELECT d.*,u.first_name,u.last_name,u.email,u.phone,u.gender,u.is_active,dept.dept_name FROM doctors d JOIN users u ON d.user_id=u.user_id LEFT JOIN departments dept ON d.dept_id=dept.dept_id ORDER BY d.doctor_id');
  res.render('admin/doctors', { title: 'Doctors - EasyMed Admin', doctors });
});

router.get('/doctors/add', async (req, res) => {
  const [depts] = await db.query('SELECT * FROM departments WHERE is_active=1');
  res.render('admin/doctor-form', { title: 'Add Doctor - EasyMed', depts, doctor: null, errors: [] });
});

router.post('/doctors/add', async (req, res) => {
  try {
    const hash = await bcrypt.hash(req.body.password || 'Doctor@123', 12);
    const [ur] = await db.query(
      'INSERT INTO users (uuid,first_name,last_name,email,password_hash,phone,role,gender,date_of_birth) VALUES (?,?,?,?,?,?,?,?,?)',
      [uuidv4(), req.body.first_name, req.body.last_name, req.body.email, hash, req.body.phone, 'doctor', req.body.gender, req.body.date_of_birth]
    );
    const maxCode = (await db.query('SELECT COUNT(*)+1 as n FROM doctors'))[0][0].n;
    const doc_code = 'DOC' + String(maxCode).padStart(6,'0');
    await db.query(
      'INSERT INTO doctors (user_id,doctor_code,dept_id,specialization,qualification,experience_years,license_number,consultation_fee,follow_up_fee,bio,available_days,slot_duration,joining_date) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [ur.insertId, doc_code, req.body.dept_id||null, req.body.specialization, req.body.qualification, req.body.experience_years||0, req.body.license_number||null, req.body.consultation_fee||500, req.body.follow_up_fee||300, req.body.bio||'', req.body.available_days||'Mon,Tue,Wed,Thu,Fri', req.body.slot_duration||30, req.body.joining_date||null]
    );
    req.flash('success', `Doctor ${req.body.first_name} added successfully! Code: ${doc_code}`);
    res.redirect('/admin/doctors');
  } catch(e) { console.error(e); req.flash('error','Failed to add doctor.'); res.redirect('/admin/doctors/add'); }
});

router.get('/appointments', async (req, res) => {
  const date = req.query.date || '';
  const status = req.query.status || '';
  let q = 'SELECT * FROM vw_appointment_details WHERE 1=1';
  let p = [];
  if (date) { q += ' AND appointment_date=?'; p.push(date); }
  if (status) { q += ' AND status=?'; p.push(status); }
  q += ' ORDER BY appointment_date DESC, appointment_time DESC LIMIT 50';
  const [appointments] = await db.query(q, p);
  res.render('admin/appointments', { title: 'Appointments - EasyMed Admin', appointments, date, status });
});

router.get('/departments', async (req, res) => {
  const [depts] = await db.query('SELECT d.*,(SELECT COUNT(*) FROM doctors WHERE dept_id=d.dept_id) as doctor_count,(SELECT COUNT(*) FROM appointments a WHERE a.dept_id=d.dept_id AND MONTH(a.appointment_date)=MONTH(CURDATE())) as monthly_appointments FROM departments d ORDER BY dept_name');
  res.render('admin/departments', { title: 'Departments - EasyMed Admin', depts });
});

router.get('/billing', async (req, res) => {
  const [bills] = await db.query(`SELECT b.*,CONCAT(u.first_name," ",u.last_name) as patient_name,p.patient_code FROM bills b JOIN patients p ON b.patient_id=p.patient_id JOIN users u ON p.user_id=u.user_id ORDER BY b.bill_date DESC LIMIT 50`);
  res.render('admin/billing', { title: 'Billing - EasyMed Admin', bills });
});

router.get('/lab-tests', async (req, res) => {
  const [tests] = await db.query(`SELECT lt.*,CONCAT(pu.first_name," ",pu.last_name) as patient_name,CONCAT(du.first_name," ",du.last_name) as doctor_name FROM lab_tests lt JOIN patients p ON lt.patient_id=p.patient_id JOIN users pu ON p.user_id=pu.user_id JOIN doctors d ON lt.doctor_id=d.doctor_id JOIN users du ON d.user_id=du.user_id ORDER BY lt.ordered_date DESC LIMIT 50`);
  res.render('admin/lab-tests', { title: 'Lab Tests - EasyMed Admin', tests });
});

router.get('/reports', async (req, res) => {
  const [monthlyData] = await db.query(`SELECT DATE_FORMAT(appointment_date,'%b') as month, COUNT(*) as total, SUM(CASE WHEN status='Completed' THEN 1 ELSE 0 END) as completed, SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END) as cancelled FROM appointments WHERE appointment_date >= DATE_SUB(CURDATE(),INTERVAL 12 MONTH) GROUP BY DATE_FORMAT(appointment_date,'%Y-%m') ORDER BY appointment_date`);
  const [deptWise] = await db.query(`SELECT dept.dept_name, COUNT(*) as total FROM appointments a JOIN departments dept ON a.dept_id=dept.dept_id GROUP BY dept.dept_id ORDER BY total DESC`);
  const [topDoctors] = await db.query(`SELECT CONCAT(u.first_name," ",u.last_name) as name,d.specialization,COUNT(a.appointment_id) as appointments FROM appointments a JOIN doctors d ON a.doctor_id=d.doctor_id JOIN users u ON d.user_id=u.user_id WHERE a.status='Completed' GROUP BY d.doctor_id ORDER BY appointments DESC LIMIT 5`);
  res.render('admin/reports', { title: 'Reports - EasyMed Admin', monthlyData, deptWise, topDoctors });
});

router.get('/settings', async (req, res) => {
  const [settings] = await db.query('SELECT * FROM system_settings ORDER BY setting_key');
  res.render('admin/settings', { title: 'Settings - EasyMed Admin', settings });
});

module.exports = router;

router.post('/settings/update', async (req, res) => {
  try {
    for (const [key, value] of Object.entries(req.body)) {
      await db.query('UPDATE system_settings SET setting_value=? WHERE setting_key=?', [value, key]);
    }
    req.flash('success', 'Settings saved successfully.');
  } catch(e) { req.flash('error', 'Failed to save settings.'); }
  res.redirect('/admin/settings');
});

router.post('/departments/add', async (req, res) => {
  try {
    await db.query('INSERT INTO departments (dept_name,dept_code,description,floor_number) VALUES (?,?,?,?)',
      [req.body.dept_name, req.body.dept_code.toUpperCase(), req.body.description||'', req.body.floor_number||1]);
    req.flash('success', `Department ${req.body.dept_name} added.`);
  } catch(e) { req.flash('error', 'Failed to add department. Code may be duplicate.'); }
  res.redirect('/admin/departments');
});
