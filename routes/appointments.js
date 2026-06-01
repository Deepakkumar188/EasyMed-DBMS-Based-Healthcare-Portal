const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { isAuthenticated } = require('../middleware/auth');

router.get('/slots', isAuthenticated, async (req, res) => {
  const { doctor_id, date } = req.query;
  if (!doctor_id || !date) return res.json({ slots: [] });
  try {
    const [slots] = await db.query('CALL sp_get_doctor_available_slots(?,?)', [doctor_id, date]);
    res.json({ slots: slots[0] || [] });
  } catch(e) { res.json({ slots: [], error: e.message }); }
});

module.exports = router;
