class Vaca {
  final int id;
  final String nome;
  final String numeroBrinco;
  final String? qrCode;
  final String raca;
  final String? dataNascimento;
  final String? status;
  final int usuarioId;

  Vaca({
    required this.id,
    required this.nome,
    required this.numeroBrinco,
    this.qrCode,
    required this.raca,
    this.dataNascimento,
    this.status,
    required this.usuarioId,
  });

  factory Vaca.fromJson(Map<String, dynamic> json) {
    return Vaca(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Sem nome',
      numeroBrinco: json['numero_brinco'] ?? 'Sem brinco',
      qrCode: json['qr_code'],
      raca: json['raca'] ?? 'Raça não informada',
      dataNascimento: json['data_nascimento'],
      status: json['status'],
      usuarioId: json['usuario_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'numero_brinco': numeroBrinco,
      'qr_code': qrCode,
      'raca': raca,
      'data_nascimento': dataNascimento,
      'status': status,
      'usuario_id': usuarioId,
    };
  }
}
