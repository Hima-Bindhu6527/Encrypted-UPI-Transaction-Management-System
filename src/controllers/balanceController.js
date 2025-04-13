const { successResponse, errorResponse } = require('../utils/responseUtils');
const db = require('../config/db');

// Fetch balance for a given VPA
exports.getBalance = (req, res) => {
    const { vpa } = req.params;

    // Validate VPA input
    if (!vpa) {
        return errorResponse(res, 'VPA is required', 400);
    }

    // Optional: Add VPA format validation if needed (e.g., regex for proper VPA format)
    const vpaRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    if (!vpaRegex.test(vpa)) {
        return errorResponse(res, 'Invalid VPA format', 400);
    }

    // Query the database for the balance of the given VPA
    db.query('SELECT balance FROM ACCOUNT WHERE VPA = ?', [vpa], (err, result) => {
        if (err) {
            console.error('Database error:', err);  // Log the error for debugging
            return errorResponse(res, 'Database error', 500, err);  // Send detailed error response
        }

        if (!result[0]) {
            return errorResponse(res, 'User not found', 404);  // Handle case when user is not found
        }

        // Return the balance of the user
        return successResponse(res, { balance: result[0].balance }, 'Balance fetched successfully');
    });
};
