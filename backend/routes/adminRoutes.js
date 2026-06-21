const express = require('express');
const {
  getAnalytics, getAllUsers, getUserById, updateUser, deleteUser,
  getAllBookings, getAllEvents,
} = require('../controllers/adminController');
const { protect } = require('../middleware/auth');
const { admin } = require('../middleware/admin');

const router = express.Router();

router.use(protect, admin);  // all admin routes require auth + admin role

router.get('/analytics',    getAnalytics);
router.get('/users',        getAllUsers);
router.get('/users/:id',    getUserById);
router.put('/users/:id',    updateUser);
router.delete('/users/:id', deleteUser);
router.get('/bookings',     getAllBookings);
router.get('/events',       getAllEvents);

module.exports = router;
