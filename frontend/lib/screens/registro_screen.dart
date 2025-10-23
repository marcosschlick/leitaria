import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _carregando = false;
  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuário'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person_add, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Criar Nova Conta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dataNascimentoController,
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento (AAAA-MM-DD)',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                hintText: '1990-01-15',
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? dataSelecionada = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(
                    const Duration(days: 365 * 18),
                  ),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now().subtract(
                    const Duration(days: 365 * 18),
                  ),
                  locale: const Locale('pt', 'BR'),
                );

                if (dataSelecionada != null) {
                  final dataFormatada =
                      "${dataSelecionada.year}-${dataSelecionada.month.toString().padLeft(2, '0')}-${dataSelecionada.day.toString().padLeft(2, '0')}";
                  _dataNascimentoController.text = dataFormatada;
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarSenha ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _mostrarSenha = !_mostrarSenha;
                    });
                  },
                ),
              ),
              obscureText: !_mostrarSenha,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmarSenhaController,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarConfirmarSenha
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _mostrarConfirmarSenha = !_mostrarConfirmarSenha;
                    });
                  },
                ),
              ),
              obscureText: !_mostrarConfirmarSenha,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _carregando ? null : _registrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _registrarUsuario() async {
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _dataNascimentoController.text.isEmpty ||
        _senhaController.text.isEmpty ||
        _confirmarSenhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final novoUsuario = Usuario(
        nome: _nomeController.text,
        email: _emailController.text,
        dataNascimento: _dataNascimentoController.text,
        senha: _senhaController.text,
      );

      final resposta = await ApiService.post(
        ApiConfig.register,
        novoUsuario.toJson(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _dataNascimentoController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}
