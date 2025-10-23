import pool from "../database/database.js";
import { Vaca } from "../models/Vaca.js";

export class DashboardRepository {
  async countVacasByUsuario(usuarioId) {
    const query = "SELECT COUNT(*) FROM vacas WHERE usuario_id = $1";
    const { rows } = await pool.query(query, [usuarioId]);
    return parseInt(rows[0].count);
  }

  async countVacasEmLactacaoByUsuario(usuarioId) {
    const query = `
      SELECT COUNT(DISTINCT l.vaca_id)
      FROM lactacoes l
      INNER JOIN vacas v ON l.vaca_id = v.id
      WHERE l.data_fim IS NULL AND v.usuario_id = $1
    `;
    const { rows } = await pool.query(query, [usuarioId]);
    return parseInt(rows[0].count);
  }

  async countVacasPrenhasByUsuario(usuarioId) {
    const query = `
      SELECT COUNT(DISTINCT p.vaca_id)
      FROM prenhezes p
      INNER JOIN vacas v ON p.vaca_id = v.id
      WHERE p.data_parto IS NULL AND v.usuario_id = $1
    `;
    const { rows } = await pool.query(query, [usuarioId]);
    return parseInt(rows[0].count);
  }

  async findVacasProvaveisCioHoje(usuarioId) {
    const query = `
      SELECT DISTINCT v.*
      FROM cios c
      INNER JOIN vacas v ON c.vaca_id = v.id
      LEFT JOIN prenhezes p ON v.id = p.vaca_id 
        AND p.data_inicio >= c.data_detecao 
        AND p.data_parto IS NULL
      WHERE v.usuario_id = $1
        AND c.data_detecao = CURRENT_DATE - INTERVAL '21 days'
        AND p.id IS NULL
      ORDER BY v.nome
    `;
    const { rows } = await pool.query(query, [usuarioId]);
    return rows.map((row) => new Vaca(row));
  }

  async getLeiteOrdenhadoHoje(usuarioId) {
    const query = `
      SELECT COALESCE(SUM(o.quantidade_ml), 0) as total_ml
      FROM ordenhas o
      INNER JOIN vacas v ON o.vaca_id = v.id
      WHERE o.data_ordenha = CURRENT_DATE 
        AND v.usuario_id = $1
    `;
    const { rows } = await pool.query(query, [usuarioId]);
    return parseInt(rows[0].total_ml);
  }

  async findPartosProximos(usuarioId) {
    const query = `
      SELECT p.*, v.nome as vaca_nome, v.numero_brinco
      FROM prenhezes p
      INNER JOIN vacas v ON p.vaca_id = v.id
      WHERE p.data_parto IS NOT NULL 
        AND p.data_parto BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '15 days'
        AND v.usuario_id = $1
      ORDER BY p.data_parto
    `;
    const { rows } = await pool.query(query, [usuarioId]);
    return rows;
  }
}
