import { DashboardRepository } from "../repositories/DashboardRepository.js";
import AppError from "../utils/AppError.js";

export class DashboardService {
  constructor() {
    this.repository = new DashboardRepository();
  }

  async getDashboard(usuario_id) {
    try {
      const [
        totalVacas,
        totalLactacao,
        totalPrenhas,
        vacasCio,
        leiteOrdenhadoHoje,
        partosProximos,
      ] = await Promise.all([
        this.repository.countVacasByUsuario(usuario_id),
        this.repository.countVacasEmLactacaoByUsuario(usuario_id),
        this.repository.countVacasPrenhasByUsuario(usuario_id),
        this.repository.findVacasProvaveisCioHoje(usuario_id),
        this.repository.getLeiteOrdenhadoHoje(usuario_id),
        this.repository.findPartosProximos(usuario_id),
      ]);

      const leiteOrdenhadoLitros = parseFloat(
        (leiteOrdenhadoHoje / 1000).toFixed(2)
      );

      return {
        totais: {
          vacas: totalVacas,
          lactacao: totalLactacao,
          prenhas: totalPrenhas,
        },
        alertas: {
          cios_detectados: vacasCio.length,
          partos_proximos: partosProximos.length,
          detalhes_cios: vacasCio.map((vaca) => ({
            id: vaca.id,
            nome: vaca.nome,
            numero_brinco: vaca.numero_brinco,
          })),
          detalhes_partos: partosProximos.map((parto) => ({
            id: parto.id,
            vaca_nome: parto.vaca_nome,
            numero_brinco: parto.numero_brinco,
            data_parto_previsto: parto.data_parto,
            dias_restantes: this.calcularDiasRestantes(parto.data_parto),
          })),
        },
        producao: {
          leite_hoje_litros: leiteOrdenhadoLitros,
        },
      };
    } catch (error) {
      throw new AppError("Erro ao carregar dados do dashboard", 500);
    }
  }

  calcularDiasRestantes(dataParto) {
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);

    const dataPartoDate = new Date(dataParto);
    dataPartoDate.setHours(0, 0, 0, 0);

    const diffTime = dataPartoDate - hoje;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    return Math.max(0, diffDays);
  }
}
