const db = require("../config/db");
 // importing db from server.js

// GET all users
exports.getAllUsers = (req, res) => {
  const sql = "SELECT * FROM user";
  db.query(sql, (err, results) => {
    if (err) {
        console.error("MySQL Error:", err); // 👈 Add this line
      return res.status(500).json({ error: "Database error" });
    }
    res.status(200).json(results);
  });
};

// POST create user
exports.createUser = (req, res) => {
  const { name, email, phone } = req.body;

  if (!name || !email || !phone) {
    return res.status(400).json({ error: "Missing fields" });
  }

  const sql = "INSERT INTO USER (name, email, phone) VALUES (?, ?, ?)";
  db.query(sql, [name, email, phone], (err, result) => {
    if (err) {
      return res.status(500).json({ error: "Insert failed" });
    }
    res.status(201).json({ message: "User created", userId: result.insertId });
  });
};
