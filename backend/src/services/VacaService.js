import { VacaRepository } from "../repositories/VacaRepository.js";
import AppError from "../utils/AppError.js";

export class VacaService {
  constructor() {
    this.repository = new VacaRepository();
  }

  // Buscas
  async listVacasByUsuario(usuarioId) {
    try {
      return await this.repository.findVacasByUsuarioId(usuarioId);
    } catch (error) {
      throw new AppError("Erro ao listar vacas do usuário", 500);
    }
  }

  async getVacaByQrCode(qrCode, usuarioId) {
    try {
      const vaca = await this.repository.findVacaByQrCode(qrCode, usuarioId);
      if (!vaca) {
        throw new AppError("Vaca não encontrada", 404);
      }
      return vaca;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao buscar vaca por QR code", 500);
    }
  }

  async searchVacasByNome(nome, usuarioId) {
    try {
      return await this.repository.findVacasByNome(nome, usuarioId);
    } catch (error) {
      throw new AppError("Erro ao buscar vacas por nome", 500);
    }
  }

  async getVacaByBrinco(brinco, usuarioId) {
    try {
      const vaca = await this.repository.findVacaByBrinco(brinco, usuarioId);
      if (!vaca) {
        throw new AppError("Vaca não encontrada", 404);
      }
      return vaca;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao buscar vaca por brinco", 500);
    }
  }

  // Ações Principais
  async registrarOrdenha(ordenhaData, vacaId, usuarioId) {
    try {
      // Validar se a vaca pertence ao usuário
      await this.validarVacaDoUsuario(vacaId, usuarioId);

      return await this.repository.createOrdenha(ordenhaData, vacaId);
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao registrar ordenha", 500);
    }
  }

  async registrarCio(cioData, vacaId, usuarioId) {
    try {
      await this.validarVacaDoUsuario(vacaId, usuarioId);

      return await this.repository.createCio(cioData, vacaId);
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao registrar cio", 500);
    }
  }

  async registrarInseminacao(inseminacaoData, vacaId, usuarioId) {
    try {
      await this.validarVacaDoUsuario(vacaId, usuarioId);

      return await this.repository.createInseminacao(inseminacaoData, vacaId);
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao registrar inseminação", 500);
    }
  }

  async confirmarPrenhez(prenhezData, vacaId, usuarioId) {
    try {
      await this.validarVacaDoUsuario(vacaId, usuarioId);

      return await this.repository.confirmPrenhez(prenhezData, vacaId);
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao confirmar prenhez", 500);
    }
  }

  async registrarParto(partoData, vacaId, usuarioId) {
    try {
      await this.validarVacaDoUsuario(vacaId, usuarioId);

      return await this.repository.registerParto(partoData, vacaId);
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao registrar parto", 500);
    }
  }

  async registrarPeso(pesoData, vacaId, usuarioId) {
    try {
      await this.validarVacaDoUsuario(vacaId, usuarioId);

      return await this.repository.createPeso(pesoData, vacaId);
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao registrar peso", 500);
    }
  }

  // Gestão de Vacas
  async criarVaca(vacaData, usuarioId) {
    try {
      // Validar campos obrigatórios
      if (!vacaData.nome || !vacaData.data_nascimento || !vacaData.raca) {
        throw new AppError(
          "Nome, data de nascimento e raça são obrigatórios",
          400
        );
      }

      // Verificar se já existe vaca com mesmo brinco para este usuário
      if (vacaData.numero_brinco) {
        const existingVaca = await this.repository.findVacaByBrinco(
          vacaData.numero_brinco,
          usuarioId
        );
        if (existingVaca) {
          throw new AppError(
            "Já existe uma vaca com este número de brinco",
            400
          );
        }
      }

      // Verificar se já existe vaca com mesmo QR code para este usuário
      if (vacaData.qr_code) {
        const existingVaca = await this.repository.findVacaByQrCode(
          vacaData.qr_code,
          usuarioId
        );
        if (existingVaca) {
          throw new AppError("Já existe uma vaca com este QR code", 400);
        }
      }

      return await this.repository.createVaca(vacaData, usuarioId);
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao criar vaca", 500);
    }
  }

  async validarVacaDoUsuario(vacaId, usuarioId) {
    try {
      const vacas = await this.repository.findVacasByUsuarioId(usuarioId);
      const vaca = vacas.find((v) => v.id === parseInt(vacaId));

      if (!vaca) {
        throw new AppError(
          "Vaca não encontrada ou não pertence ao usuário",
          404
        );
      }

      return true;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError("Erro ao validar propriedade da vaca", 500);
    }
  }
}
