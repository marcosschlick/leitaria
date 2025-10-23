class Usuario {
  final String nome;
  final String email;
  final String dataNascimento;
  final String senha;

  Usuario({
    required this.nome,
    required this.email,
    required this.dataNascimento,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'data_nascimento': dataNascimento,
      'senha': senha,
    };
  }
}

class UsuarioLogin {
  final String email;
  final String senha;

  UsuarioLogin({required this.email, required this.senha});

  Map<String, dynamic> toJson() {
    return {'email': email, 'senha': senha};
  }
}
