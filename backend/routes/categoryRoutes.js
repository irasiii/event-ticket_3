const express = require('express');
const { getCategories, getCategoryById, createCategory, updateCategory, deleteCategory } = require('../controllers/categoryController');
const { protect } = require('../middleware/auth');
const { admin } = require('../middleware/admin');

const router = express.Router();

router.get('/',       getCategories);
router.get('/:id',    getCategoryById);
router.post('/',      protect, admin, createCategory);
router.put('/:id',    protect, admin, updateCategory);
router.delete('/:id', protect, admin, deleteCategory);

module.exports = router;
