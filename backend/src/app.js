import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { authRoutes } from "./routes/AuthRoutes.js";
import { dashboardRoutes } from "./routes/DashboardRoutes.js";

dotenv.config();

const app = express();

app.use(
  cors({
    origin: process.env.ALLOWED_CORS,
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.use(express.json());

app.use("/auth", authRoutes);
app.use("/dashboard", dashboardRoutes);

export default app;
