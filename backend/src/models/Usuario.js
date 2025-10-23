export class Usuario {
  constructor({ id, nome, email, data_nascimento, senha_hash }) {
    this.id = id;
    this.nome = nome;
    this.email = email;
    this.data_nascimento = data_nascimento;
    this.senha_hash = senha_hash;
  }
}
