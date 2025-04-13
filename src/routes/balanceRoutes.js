const express = require('express');
const router = express.Router();
const balanceController = require('../controllers/balanceController');

// Route to get user balance by VPA
router.get('/:vpa', balanceController.getBalance);

module.exports = router;
