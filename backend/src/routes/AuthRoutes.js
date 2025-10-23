import express from "express";
import { AuthController } from "../controllers/AuthController.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";

const authController = new AuthController();
const router = express.Router();

// auth routes
router.post("/login", (req, res) => authController.login(req, res));
router.post("/register", (req, res) => authController.register(req, res));
router.get("/me", authMiddleware, (req, res) => authController.getMe(req, res));

export { router as authRoutes };
