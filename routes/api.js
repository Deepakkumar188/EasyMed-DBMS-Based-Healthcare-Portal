const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { isAuthenticated } = require('../middleware/auth');

router.use(isAuthenticated);

router.get('/notifications', async (req, res) => {
  const [notifs] = await db.query('SELECT * FROM notifications WHERE user_id=? ORDER BY created_at DESC LIMIT 10', [req.user.user_id]);
  const [[{unread}]] = await db.query('SELECT COUNT(*) as unread FROM notifications WHERE user_id=? AND is_read=0', [req.user.user_id]);
  res.json({ notifications: notifs, unread });
});

router.post('/notifications/read', async (req, res) => {
  await db.query('UPDATE notifications SET is_read=1 WHERE user_id=?', [req.user.user_id]);
  res.json({ success: true });
});

router.get('/doctors/:id/info', async (req, res) => {
  const [d] = await db.query('SELECT * FROM vw_doctor_profile WHERE doctor_id=?', [req.params.id]);
  res.json(d[0] || {});
});

router.get('/stats', async (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });
  const [[stats]] = await db.query('CALL sp_dashboard_stats()');
  res.json(stats);
});

module.exports = router;
