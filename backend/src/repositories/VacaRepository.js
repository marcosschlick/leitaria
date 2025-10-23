import pool from "../database/database.js";
import { Vaca } from "../models/Vaca.js";
import { Ordenha } from "../models/Ordenha.js";
import { Cio } from "../models/Cio.js";
import { Inseminacao } from "../models/Inseminacao.js";
import { Prenhez } from "../models/Prenhez.js";
import { Peso } from "../models/Peso.js";

export class VacaRepository {
  // Buscas
  async findVacasByUsuarioId(usuarioId) {
    const query = "SELECT * FROM vacas WHERE usuario_id = $1 ORDER BY nome";
    const { rows } = await pool.query(query, [usuarioId]);
    return rows.map((row) => new Vaca(row));
  }

  async findVacaByQrCode(qrCode, usuarioId) {
    const query = "SELECT * FROM vacas WHERE qr_code = $1 AND usuario_id = $2";
    const { rows } = await pool.query(query, [qrCode, usuarioId]);
    return rows.length > 0 ? new Vaca(rows[0]) : null;
  }

  async findVacasByNome(nome, usuarioId) {
    const query =
      "SELECT * FROM vacas WHERE nome ILIKE $1 AND usuario_id = $2 ORDER BY nome";
    const { rows } = await pool.query(query, [`%${nome}%`, usuarioId]);
    return rows.map((row) => new Vaca(row));
  }

  async findVacaByBrinco(brinco, usuarioId) {
    const query =
      "SELECT * FROM vacas WHERE numero_brinco = $1 AND usuario_id = $2";
    const { rows } = await pool.query(query, [brinco, usuarioId]);
    return rows.length > 0 ? new Vaca(rows[0]) : null;
  }

  // Ações Principais
  async createOrdenha(ordenhaData, vacaId) {
    const { data_ordenha, hora_ordenha, quantidade_ml, turno } = ordenhaData;
    const query = `
      INSERT INTO ordenhas (vaca_id, data_ordenha, hora_ordenha, quantidade_ml, turno)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;
    const { rows } = await pool.query(query, [
      vacaId,
      data_ordenha,
      hora_ordenha,
      quantidade_ml,
      turno,
    ]);
    return new Ordenha(rows[0]);
  }

  async createCio(cioData, vacaId) {
    const { data_detecao, hora_detecao } = cioData;
    const query = `
      INSERT INTO cios (vaca_id, data_detecao, hora_detecao)
      VALUES ($1, $2, $3)
      RETURNING *
    `;
    const { rows } = await pool.query(query, [
      vacaId,
      data_detecao,
      hora_detecao,
    ]);
    return new Cio(rows[0]);
  }

  async createInseminacao(inseminacaoData, vacaId) {
    const { tipo, nome_touro, data_inseminacao, status } = inseminacaoData;
    const query = `
      INSERT INTO inseminacoes (vaca_id, tipo, nome_touro, data_inseminacao, status)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;
    const { rows } = await pool.query(query, [
      vacaId,
      tipo,
      nome_touro,
      data_inseminacao,
      status,
    ]);
    return new Inseminacao(rows[0]);
  }

  async confirmPrenhez(prenhezData, vacaId) {
    const { inseminacao_id, data_inicio, sexo_cria } = prenhezData;
    const query = `
      INSERT INTO prenhezes (vaca_id, inseminacao_id, data_inicio, sexo_cria)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `;
    const { rows } = await pool.query(query, [
      vacaId,
      inseminacao_id,
      data_inicio,
      sexo_cria,
    ]);
    return new Prenhez(rows[0]);
  }

  async registerParto(partoData, vacaId) {
    const client = await pool.connect();
    try {
      await client.query("BEGIN");

      // Atualizar prenhez com data do parto
      const updatePrenhezQuery = `
        UPDATE prenhezes 
        SET data_parto = $1 
        WHERE vaca_id = $2 AND data_parto IS NULL
        RETURNING *
      `;
      const { rows: prenhezRows } = await client.query(updatePrenhezQuery, [
        partoData.data_parto,
        vacaId,
      ]);

      // Iniciar nova lactação
      const insertLactacaoQuery = `
        INSERT INTO lactacoes (vaca_id, data_inicio)
        VALUES ($1, $2)
        RETURNING *
      `;
      const { rows: lactacaoRows } = await client.query(insertLactacaoQuery, [
        vacaId,
        partoData.data_parto,
      ]);

      await client.query("COMMIT");
      return {
        prenhez: new Prenhez(prenhezRows[0]),
        lactacao: new Lactacao(lactacaoRows[0]),
      };
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }

  async createPeso(pesoData, vacaId) {
    const { peso_kg, data_registro } = pesoData;
    const query = `
      INSERT INTO pesos (vaca_id, peso_kg, data_registro)
      VALUES ($1, $2, $3)
      RETURNING *
    `;
    const { rows } = await pool.query(query, [vacaId, peso_kg, data_registro]);
    return new Peso(rows[0]);
  }

  // Gestão de Vacas
  async createVaca(vacaData, usuario_id) {
    const { numero_brinco, qr_code, nome, data_nascimento, raca } = vacaData;
    const query = `
      INSERT INTO vacas (numero_brinco, qr_code, nome, data_nascimento, raca, usuario_id)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;
    const { rows } = await pool.query(query, [
      numero_brinco,
      qr_code,
      nome,
      data_nascimento,
      raca,
      usuario_id,
    ]);
    return new Vaca(rows[0]);
  }

  async getLitrosNoMes(vacaId) {
    const query = `
    SELECT COALESCE(SUM(quantidade_ml), 0) as total_ml
    FROM ordenhas 
    WHERE vaca_id = $1 
      AND data_ordenha >= date_trunc('month', CURRENT_DATE)
      AND data_ordenha < date_trunc('month', CURRENT_DATE) + INTERVAL '1 month'
  `;
    const { rows } = await pool.query(query, [vacaId]);
    return parseFloat(rows[0].total_ml) / 1000;
  }

  async getMediaDiariaLitros(vacaId) {
    const query = `
    SELECT 
      COALESCE(SUM(quantidade_ml), 0) as total_ml,
      COUNT(DISTINCT data_ordenha) as dias_com_ordenha
    FROM ordenhas 
    WHERE vaca_id = $1 
      AND data_ordenha >= date_trunc('month', CURRENT_DATE)
      AND data_ordenha < date_trunc('month', CURRENT_DATE) + INTERVAL '1 month'
  `;
    const { rows } = await pool.query(query, [vacaId]);
    const totalMl = parseFloat(rows[0].total_ml);
    const diasComOrdenha = parseInt(rows[0].dias_com_ordenha) || 1;

    return totalMl / diasComOrdenha / 1000;
  }

  async getUltimaOrdenhaLitros(vacaId) {
    const query = `
    SELECT quantidade_ml, data_ordenha 
    FROM ordenhas 
    WHERE vaca_id = $1 
    ORDER BY data_ordenha DESC, id DESC 
    LIMIT 1
  `;
    const { rows } = await pool.query(query, [vacaId]);

    if (rows.length > 0) {
      return {
        quantidade_litros: parseFloat(rows[0].quantidade_ml) / 1000,
        data_ordenha: rows[0].data_ordenha,
      };
    }
    return null;
  }
}
