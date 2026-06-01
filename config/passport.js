// config/passport.js
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const bcrypt = require('bcryptjs');
const db = require('./database');

passport.use('local', new LocalStrategy(
  { usernameField: 'email', passwordField: 'password' },
  async (email, password, done) => {
    try {
      const [rows] = await db.query('SELECT * FROM users WHERE email = ? AND is_active = TRUE', [email]);
      if (!rows.length) return done(null, false, { message: 'No account found with this email address.' });
      
      const user = rows[0];
      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (!isMatch) return done(null, false, { message: 'Incorrect password. Please try again.' });

      // Update last login
      await db.query('UPDATE users SET last_login = NOW() WHERE user_id = ?', [user.user_id]);
      
      return done(null, user);
    } catch (err) {
      return done(err);
    }
  }
));

passport.serializeUser((user, done) => done(null, user.user_id));

passport.deserializeUser(async (id, done) => {
  try {
    const [rows] = await db.query('SELECT * FROM users WHERE user_id = ?', [id]);
    done(null, rows[0] || false);
  } catch (err) {
    done(err);
  }
});

module.exports = passport;
