const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/', async (req, res) => {
  try {
    const [doctors] = await db.query('SELECT * FROM vw_doctor_profile LIMIT 6');
    const [depts] = await db.query('SELECT * FROM departments WHERE is_active=1 LIMIT 8');
    const [[stats]] = await db.query('CALL sp_dashboard_stats()');
    res.render('index', { title: 'EasyMed - Healthcare Portal', doctors, depts, stats });
  } catch(e) {
    res.render('index', { title: 'EasyMed - Healthcare Portal', doctors: [], depts: [], stats: {} });
  }
});

router.get('/about', (req, res) => res.render('about', { title: 'About - EasyMed' }));
router.get('/contact', (req, res) => res.render('contact', { title: 'Contact - EasyMed' }));
router.get('/services', async (req, res) => {
  const [depts] = await db.query('SELECT * FROM departments WHERE is_active=1');
  res.render('services', { title: 'Services - EasyMed', depts });
});
router.get('/doctors', async (req, res) => {
  const [doctors] = await db.query('SELECT * FROM vw_doctor_profile WHERE is_available=1');
  res.render('doctors', { title: 'Our Doctors - EasyMed', doctors });
});

module.exports = router;
