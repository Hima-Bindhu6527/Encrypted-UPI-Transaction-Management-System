// Controller: userController.js
const db = require("../config/db");
const { successResponse, errorResponse } = require('../utils/responseUtils');

// Get all users
exports.getAllUsers = (req, res) => {
  const sql = "SELECT * FROM USER";
  db.query(sql, (err, results) => {
    if (err) {
      console.error("MySQL Error:", err);
      return errorResponse(res, "Database error", 500, err);
    }
    return successResponse(res, results, "Users fetched successfully");
  });
};

// Create a new user
exports.createUser = (req, res) => {
  const { name, email, mobile_number, hashedpin } = req.body;

  if (!name || !email || !mobile_number || !hashedpin) {
    return errorResponse(res, "All fields (name, email, mobile_number, hashedpin) are required", 400);
  }

  const sql = "INSERT INTO USER (name, email, mobile_number, hashedpin) VALUES (?, ?, ?, ?)";
  db.query(sql, [name, email, mobile_number, hashedpin], (err, result) => {
    if (err) {
      console.error("❌ Insert failed:", err);
      return errorResponse(res, "Failed to create user", 500, err);
    }
    return successResponse(res, { userId: result.insertId }, "User created successfully");
  });
};
