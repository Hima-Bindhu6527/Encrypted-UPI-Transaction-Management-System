const express = require("express");
const router = express.Router();

const { getAllUsers, createUser } = require("../controllers/userController");

// GET route for fetching all users
router.get("/", getAllUsers);

// POST route for creating a new user
router.post("/", createUser);

module.exports = router;
