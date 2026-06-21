const express = require('express');
const { getVenues, getVenueById, createVenue, updateVenue, deleteVenue } = require('../controllers/venueController');
const { protect } = require('../middleware/auth');
const { admin } = require('../middleware/admin');

const router = express.Router();

router.get('/',       getVenues);
router.get('/:id',    getVenueById);
router.post('/',      protect, admin, createVenue);
router.put('/:id',    protect, admin, updateVenue);
router.delete('/:id', protect, admin, deleteVenue);

module.exports = router;
