import pool from "../database/database.js";
import { Usuario } from "../models/Usuario.js";

export class UsuarioRepository {
  async findById(id) {
    const query = "SELECT * FROM usuarios WHERE id = $1";
    const { rows } = await pool.query(query, [id]);
    return rows.length > 0 ? new Usuario(rows[0]) : null;
  }

  async findByEmail(email) {
    const query = "SELECT * FROM usuarios WHERE email = $1";
    const { rows } = await pool.query(query, [email]);
    return rows.length > 0 ? new Usuario(rows[0]) : null;
  }

  async create(usuarioData) {
    const { nome, email, data_nascimento, senha_hash } = usuarioData;
    const query = `
      INSERT INTO usuarios (nome, email, data_nascimento, senha_hash) 
      VALUES ($1, $2, $3, $4) 
      RETURNING *
    `;
    const { rows } = await pool.query(query, [
      nome,
      email,
      data_nascimento,
      senha_hash,
    ]);
    return new Usuario(rows[0]);
  }
}
