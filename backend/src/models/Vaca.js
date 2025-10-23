export class Vaca {
  constructor({
    id,
    numero_brinco,
    qr_code,
    nome,
    data_nascimento,
    raca_id,
    usuario_id,
  }) {
    this.id = id;
    this.numero_brinco = numero_brinco;
    this.qr_code = qr_code;
    this.nome = nome;
    this.data_nascimento = data_nascimento;
    this.raca_id = raca_id;
    this.usuario_id = usuario_id;
  }
}
