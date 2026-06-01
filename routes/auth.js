const express = require('express');
const router = express.Router();
const passport = require('passport');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { body, validationResult } = require('express-validator');
const db = require('../config/database');
const { notAuthenticated, redirectByRole } = require('../middleware/auth');

router.get('/login', notAuthenticated, (req, res) => {
  res.render('auth/login', { title: 'Login - EasyMed' });
});

router.post('/login', notAuthenticated, (req, res, next) => {
  passport.authenticate('local', (err, user, info) => {
    if (err) return next(err);
    if (!user) { req.flash('error', info.message); return res.redirect('/auth/login'); }
    req.logIn(user, (err) => {
      if (err) return next(err);
      req.flash('success', `Welcome back, ${user.first_name}!`);
      redirectByRole(res, user.role);
    });
  })(req, res, next);
});

router.get('/register', notAuthenticated, (req, res) => {
  res.render('auth/register', { title: 'Register - EasyMed', errors: [], formData: {} });
});

router.post('/register', notAuthenticated, [
  body('first_name').trim().notEmpty().withMessage('First name is required'),
  body('last_name').trim().notEmpty().withMessage('Last name is required'),
  body('email').trim().isEmail().withMessage('Valid email is required').normalizeEmail(),
  body('phone').trim().matches(/^[6-9]\d{9}$/).withMessage('Valid 10-digit phone required'),
  body('password').isLength({ min: 8 }).withMessage('Password min 8 chars')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).withMessage('Password needs uppercase, lowercase & number'),
  body('confirm_password').custom((v, { req }) => v === req.body.password).withMessage('Passwords do not match'),
  body('date_of_birth').notEmpty().withMessage('Date of birth is required'),
  body('gender').isIn(['Male','Female','Other']).withMessage('Gender required'),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.render('auth/register', { title: 'Register - EasyMed', errors: errors.array(), formData: req.body });
  try {
    const [existing] = await db.query('SELECT user_id FROM users WHERE email = ?', [req.body.email]);
    if (existing.length) return res.render('auth/register', { title: 'Register - EasyMed', errors: [{ msg: 'Email already registered.' }], formData: req.body });
    const hash = await bcrypt.hash(req.body.password, 12);
    const [result] = await db.query(
      'INSERT INTO users (uuid,first_name,last_name,email,password_hash,phone,role,gender,date_of_birth,blood_group) VALUES (?,?,?,?,?,?,?,?,?,?)',
      [uuidv4(), req.body.first_name, req.body.last_name, req.body.email, hash, req.body.phone, 'patient', req.body.gender, req.body.date_of_birth, req.body.blood_group || null]
    );
    const uid = result.insertId;
    const [[row]] = await db.query('CALL sp_generate_patient_code()');
    const patient_code = row.patient_code;
    await db.query(
      'INSERT INTO patients (user_id,patient_code,address,city,state,pincode,emergency_contact_name,emergency_contact_phone,emergency_contact_relation) VALUES (?,?,?,?,?,?,?,?,?)',
      [uid, patient_code, req.body.address||'', req.body.city||'', req.body.state||'', req.body.pincode||'', req.body.emergency_name||'', req.body.emergency_phone||'', req.body.emergency_relation||'']
    );
    req.flash('success', `Registered successfully! Your Patient ID: ${patient_code}. Please login.`);
    res.redirect('/auth/login');
  } catch (err) {
    console.error(err);
    res.render('auth/register', { title: 'Register - EasyMed', errors: [{ msg: 'Registration failed. Try again.' }], formData: req.body });
  }
});

router.get('/logout', (req, res, next) => {
  req.logout((err) => { if (err) return next(err); req.flash('success', 'Logged out successfully.'); res.redirect('/auth/login'); });
});

module.exports = router;
