import { AuthService } from "../services/AuthService.js";

export class AuthController {
  constructor() {
    this.service = new AuthService();
  }

  async register(req, res) {
    try {
      const authResponse = await this.service.register(req.body);
      return res.status(201).json(authResponse);
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async login(req, res) {
    try {
      const authResponse = await this.service.login(req.body);
      return res.status(200).json(authResponse);
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async getMe(req, res) {
    try {
      const usuario = await this.service.getCurrentUsuario(req.user.id);
      return res.status(200).json({ usuario });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }
}
