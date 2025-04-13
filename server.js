require("dotenv").config(); // Load environment variables from .env file
const express = require("express");
const cors = require("cors");
const app = express();

// Database connection (ensure your db.js properly handles connection)
const db = require("./src/config/db");

// Import routes
const userRoutes = require("./src/routes/userRoutes");
const transactionRoutes = require("./src/routes/transactionRoutes");
const balanceRoutes = require("./src/routes/balanceRoutes");

// Middleware
app.use(cors()); // Enable Cross-Origin Resource Sharing
app.use(express.json()); // Middleware to parse JSON bodies

// Test route to check if server is working
app.get("/test", (req, res) => {
  res.send("Server is working!");
});

// Register routes
app.use("/api/users", userRoutes);
app.use("/api/transactions", transactionRoutes);
app.use("/api/balance", balanceRoutes);

// Start the server
app.listen(5000, () => {
  console.log("🚀 Server running on http://localhost:5000");
 // console.log("✅ Connected to MySQL Database 'upi'");
});
