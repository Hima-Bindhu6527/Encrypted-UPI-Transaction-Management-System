require("dotenv").config();
console.log("✅ ENV TEST:", {
  DB_HOST: process.env.DB_HOST,
  DB_USER: process.env.DB_USER,
  DB_PASSWORD: process.env.DB_PASSWORD,
  DB_NAME: process.env.DB_NAME,
  DB_PORT: process.env.DB_PORT,
});
const express = require("express");
const app = express();
const port = 5000;

// Import DB just to initialize it (no need to connect again)
require("./src/config/db");

// Middleware
app.use(express.json());

// Routes
const userRoutes = require("./src/routes/userRoutes");
app.use("/api/users", userRoutes);

// Start server
app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}`);
});
