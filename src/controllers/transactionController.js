const { successResponse, errorResponse } = require('../utils/responseUtils');
const db = require('../config/db');

// Create a transaction (money transfer)
exports.createTransaction = (req, res) => {
    const { senderVPA, receiverVPA, amount, transactionType } = req.body;

    // Validate missing fields
    if (!senderVPA || !receiverVPA || !amount || !transactionType) {
        return errorResponse(res, 'All fields are required', 400);
    }

    // Validate transaction type
    const validTransactionTypes = ['transfer', 'deposit', 'withdrawal'];
    if (!validTransactionTypes.includes(transactionType)) {
        return errorResponse(res, 'Invalid transaction type', 400);
    }

    // Validate sender's VPA existence
    db.query('SELECT 1 FROM ACCOUNT WHERE VPA = ?', [senderVPA], (err, result) => {
        if (err) {
            return errorResponse(res, 'Database error', 500, err);
        }
        if (result.length === 0) {
            return errorResponse(res, 'Sender VPA not found', 404);
        }

        // Validate receiver's VPA existence
        db.query('SELECT 1 FROM ACCOUNT WHERE VPA = ?', [receiverVPA], (err, result) => {
            if (err) {
                return errorResponse(res, 'Database error', 500, err);
            }
            if (result.length === 0) {
                return errorResponse(res, 'Receiver VPA not found', 404);
            }

            // Validate amount
            if (amount <= 0) {
                return errorResponse(res, 'Amount must be greater than zero', 400);
            }

            // Validate sender's balance
            db.query('SELECT balance FROM ACCOUNT WHERE VPA = ?', [senderVPA], (err, result) => {
                if (err) {
                    return errorResponse(res, 'Database error', 500, err);
                }

                const senderBalance = result[0]?.balance;
                if (senderBalance < amount) {
                    return errorResponse(res, 'Insufficient balance', 400);
                }

                // Start transaction
                db.beginTransaction((err) => {
                    if (err) {
                        return errorResponse(res, 'Transaction error', 500, err);
                    }

                    // Deduct from sender's balance
                    db.query('UPDATE ACCOUNT SET balance = balance - ? WHERE VPA = ?', [amount, senderVPA], (err, result) => {
                        if (err) {
                            return db.rollback(() => {
                                return errorResponse(res, 'Error updating sender balance', 500, err);
                            });
                        }

                        // Add to receiver's balance
                        db.query('UPDATE ACCOUNT SET balance = balance + ? WHERE VPA = ?', [amount, receiverVPA], (err, result) => {
                            if (err) {
                                return db.rollback(() => {
                                    return errorResponse(res, 'Error updating receiver balance', 500, err);
                                });
                            }

                            // Insert transaction record
                            const transactionQuery = 'INSERT INTO TRANSACTION (senderVPA, receiverVPA, amount, transactionType) VALUES (?, ?, ?, ?)';
                            db.query(transactionQuery, [senderVPA, receiverVPA, amount, transactionType], (err, result) => {
                                if (err) {
                                    return db.rollback(() => {
                                        return errorResponse(res, 'Error recording transaction', 500, err);
                                    });
                                }

                                // Commit transaction
                                db.commit((err) => {
                                    if (err) {
                                        return db.rollback(() => {
                                            return errorResponse(res, 'Commit failed', 500, err);
                                        });
                                    }
                                    return successResponse(res, { transactionId: result.insertId }, 'Transaction successful');
                                });
                            });
                        });
                    });
                });
            });
        });
    });
};

// Fetch transaction history
exports.getTransactionHistory = (req, res) => {
    const { userVPA } = req.query;

    // Validate VPA in query
    if (!userVPA) {
        return errorResponse(res, 'VPA is required to fetch transaction history', 400);
    }

    // Get transaction history for the user
    db.query('SELECT * FROM TRANSACTION WHERE senderVPA = ? OR receiverVPA = ? ORDER BY date DESC', [userVPA, userVPA], (err, result) => {
        if (err) {
            return errorResponse(res, 'Database error', 500, err);
        }

        return successResponse(res, { transactions: result }, 'Transaction history fetched successfully');
    });
};
