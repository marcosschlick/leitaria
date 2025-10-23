import { UsuarioRepository } from "../repositories/UsuarioRepository.js";
import { hashPassword, checkPasswordHash } from "../utils/hash.js";
import AppError from "../utils/AppError.js";
import jwt from "jsonwebtoken";

export class AuthService {
  constructor() {
    this.repository = new UsuarioRepository();
  }

  async register(usuarioData) {
    // Verificar se usuário já existe
    const existingUsuario = await this.repository.findByEmail(
      usuarioData.email
    );
    if (existingUsuario) {
      throw new AppError("Usuário com este email já existe.", 400);
    }

    // Hash da senha
    const hashedPassword = await hashPassword(usuarioData.senha);

    // Criar usuário
    const usuarioToCreate = {
      nome: usuarioData.nome,
      email: usuarioData.email,
      data_nascimento: usuarioData.data_nascimento,
      senha_hash: hashedPassword,
    };

    const createdUsuario = await this.repository.create(usuarioToCreate);
    if (!createdUsuario) {
      throw new AppError("Não foi possível criar o usuário.", 400);
    }

    // Gerar token JWT
    const token = this.generateToken(createdUsuario);

    // Remover senha do response
    const { senha_hash, ...usuarioWithoutPassword } = createdUsuario;

    return { usuario: usuarioWithoutPassword, token };
  }

  async login(loginData) {
    const usuario = await this.repository.findByEmail(loginData.email);
    if (!usuario) {
      throw new AppError("Email ou senha inválidos.", 401);
    }

    // Verificar senha
    const isPasswordValid = await checkPasswordHash(
      loginData.senha,
      usuario.senha_hash
    );
    if (!isPasswordValid) {
      throw new AppError("Email ou senha inválidos.", 401);
    }

    // Gerar token JWT
    const token = this.generateToken(usuario);

    // Remover senha do response
    const { senha_hash, ...usuarioWithoutPassword } = usuario;

    return { usuario: usuarioWithoutPassword, token };
  }

  generateToken(usuario) {
    const payload = {
      id: usuario.id,
      email: usuario.email,
    };

    return jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN,
    });
  }

  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      throw new AppError("Token inválido ou expirado.", 401);
    }
  }

  async getCurrentUsuario(usuarioId) {
    const usuario = await this.repository.findById(usuarioId);
    if (!usuario) {
      throw new AppError("Usuário não encontrado.", 404);
    }

    // Remover senha do response
    const { senha_hash, ...usuarioWithoutPassword } = usuario;

    return usuarioWithoutPassword;
  }
}
