export class Ordenha {
  constructor({
    id,
    vaca_id,
    data_ordenha,
    hora_ordenha,
    quantidade_ml,
    turno,
  }) {
    this.id = id;
    this.vaca_id = vaca_id;
    this.data_ordenha = data_ordenha;
    this.hora_ordenha = hora_ordenha;
    this.quantidade_ml = quantidade_ml;
    this.turno = turno;
  }
}
