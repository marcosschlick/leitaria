import express from "express";
import { DashboardController } from "../controllers/DashboardController.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";

const dashboardController = new DashboardController();
const router = express.Router();

// dashboard routes
router.get("/", authMiddleware, (req, res) =>
  dashboardController.getDashboard(req, res)
);

export { router as dashboardRoutes };
