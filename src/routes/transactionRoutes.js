const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');

// Create transaction route
router.post('/create', transactionController.createTransaction);

// Fetch transaction history route
router.get('/history', transactionController.getTransactionHistory);

module.exports = router;
