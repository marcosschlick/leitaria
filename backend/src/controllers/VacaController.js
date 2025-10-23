import { VacaService } from "../services/VacaService.js";

export class VacaController {
  constructor() {
    this.service = new VacaService();
  }

  // Buscas
  async listarVacas(req, res) {
    try {
      const vacas = await this.service.listVacasByUsuario(req.user.id);
      return res.status(200).json({ vacas });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async buscarVacaPorQrCode(req, res) {
    try {
      const { qrCode } = req.params;
      const vaca = await this.service.getVacaByQrCode(qrCode, req.user.id);
      return res.status(200).json({ vaca });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async buscarVacasPorNome(req, res) {
    try {
      const { nome } = req.query;
      if (!nome) {
        return res
          .status(400)
          .json({ error: "Parâmetro 'nome' é obrigatório" });
      }
      const vacas = await this.service.searchVacasByNome(nome, req.user.id);
      return res.status(200).json({ vacas });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async buscarVacaPorBrinco(req, res) {
    try {
      const { brinco } = req.params;
      const vaca = await this.service.getVacaByBrinco(brinco, req.user.id);
      return res.status(200).json({ vaca });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  // Gestão de Vacas
  async criarVaca(req, res) {
    try {
      const vaca = await this.service.criarVaca(req.body, req.user.id);
      return res.status(201).json({ vaca });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  // Ações Principais
  async registrarOrdenha(req, res) {
    try {
      const { vacaId } = req.params;
      const ordenha = await this.service.registrarOrdenha(
        req.body,
        vacaId,
        req.user.id
      );
      return res.status(201).json({ ordenha });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async registrarCio(req, res) {
    try {
      const { vacaId } = req.params;
      const cio = await this.service.registrarCio(
        req.body,
        vacaId,
        req.user.id
      );
      return res.status(201).json({ cio });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async registrarInseminacao(req, res) {
    try {
      const { vacaId } = req.params;
      const inseminacao = await this.service.registrarInseminacao(
        req.body,
        vacaId,
        req.user.id
      );
      return res.status(201).json({ inseminacao });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async confirmarPrenhez(req, res) {
    try {
      const { vacaId } = req.params;
      const prenhez = await this.service.confirmarPrenhez(
        req.body,
        vacaId,
        req.user.id
      );
      return res.status(201).json({ prenhez });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async registrarParto(req, res) {
    try {
      const { vacaId } = req.params;
      const resultado = await this.service.registrarParto(
        req.body,
        vacaId,
        req.user.id
      );
      return res.status(201).json({
        prenhez: resultado.prenhez,
        lactacao: resultado.lactacao,
      });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }

  async registrarPeso(req, res) {
    try {
      const { vacaId } = req.params;
      const peso = await this.service.registrarPeso(
        req.body,
        vacaId,
        req.user.id
      );
      return res.status(201).json({ peso });
    } catch (error) {
      return res.status(error.statusCode || 500).json({ error: error.message });
    }
  }
}
