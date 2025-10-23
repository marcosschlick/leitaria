export class Inseminacao {
  constructor({ id, vaca_id, tipo, nome_touro, data_inseminacao, status }) {
    this.id = id;
    this.vaca_id = vaca_id;
    this.tipo = tipo;
    this.nome_touro = nome_touro;
    this.data_inseminacao = data_inseminacao;
    this.status = status;
  }
}
