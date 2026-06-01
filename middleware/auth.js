// middleware/auth.js
const isAuthenticated = (req, res, next) => {
  if (req.isAuthenticated()) return next();
  req.flash('error', 'Please login to access this page.');
  res.redirect('/auth/login');
};

const isAdmin = (req, res, next) => {
  if (req.isAuthenticated() && req.user.role === 'admin') return next();
  res.status(403).render('errors/403', { title: 'Access Denied', user: req.user });
};

const isDoctor = (req, res, next) => {
  if (req.isAuthenticated() && (req.user.role === 'doctor' || req.user.role === 'admin')) return next();
  res.status(403).render('errors/403', { title: 'Access Denied', user: req.user });
};

const isPatient = (req, res, next) => {
  if (req.isAuthenticated() && (req.user.role === 'patient' || req.user.role === 'admin')) return next();
  res.status(403).render('errors/403', { title: 'Access Denied', user: req.user });
};

const isStaff = (req, res, next) => {
  if (req.isAuthenticated() && ['admin', 'doctor', 'staff', 'receptionist'].includes(req.user.role)) return next();
  res.status(403).render('errors/403', { title: 'Access Denied', user: req.user });
};

const notAuthenticated = (req, res, next) => {
  if (!req.isAuthenticated()) return next();
  redirectByRole(res, req.user.role);
};

const redirectByRole = (res, role) => {
  const routes = { admin: '/admin/dashboard', doctor: '/doctor/dashboard', patient: '/patient/dashboard', staff: '/staff/dashboard', receptionist: '/receptionist/dashboard' };
  res.redirect(routes[role] || '/dashboard');
};

module.exports = { isAuthenticated, isAdmin, isDoctor, isPatient, isStaff, notAuthenticated, redirectByRole };
