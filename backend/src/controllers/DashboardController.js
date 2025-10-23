import { DashboardService } from "../services/DashboardService.js";

export class DashboardController {
  constructor() {
    this.service = new DashboardService();
  }

  async getDashboard(req, res) {
    try {
      const dashboardData = await this.service.getDashboard(req.user.id);
      return res.status(200).json(dashboardData);
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }
}
