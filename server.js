// server.js - EasyMed Healthcare Portal Main Server
require('dotenv').config();
const express = require('express');
const session = require('express-session');
const flash = require('connect-flash');
const methodOverride = require('method-override');
const path = require('path');
const cors = require('cors');
const passport = require('./config/passport');

const app = express();
const PORT = process.env.PORT || 3000;

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(methodOverride('_method'));
app.use(cors());

app.use(session({
  secret: process.env.SESSION_SECRET || 'easymed_secret',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, maxAge: 24 * 60 * 60 * 1000, httpOnly: true }
}));

app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

app.use((req, res, next) => {
  res.locals.user = req.user || null;
  res.locals.success = req.flash('success');
  res.locals.error = req.flash('error');
  res.locals.info = req.flash('info');
  res.locals.moment = require('moment');
  next();
});

app.use('/', require('./routes/index'));
app.use('/auth', require('./routes/auth'));
app.use('/admin', require('./routes/admin'));
app.use('/patient', require('./routes/patient'));
app.use('/doctor', require('./routes/doctor'));
app.use('/appointments', require('./routes/appointments'));
app.use('/api', require('./routes/api'));

app.use((req, res) => {
  res.status(404).render('errors/404', { title: 'Page Not Found', user: req.user });
});

app.use((err, req, res, next) => {
  console.error('Server Error:', err.stack);
  res.status(500).render('errors/500', { title: 'Server Error', error: err, user: req.user });
});

app.listen(PORT, () => {
  console.log('\n  EasyMed Healthcare Portal running on http://localhost:' + PORT);
});

module.exports = app;
