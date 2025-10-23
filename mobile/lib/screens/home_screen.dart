import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _fazerLogout(BuildContext context) {
    ApiService.clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MilkFlow'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _fazerLogout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 80, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Login realizado com sucesso!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.green,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Informações',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _criarLinha(
                            icone: Icons.api,
                            titulo: 'API',
                            descricao: 'http://localhost:3000',
                          ),
                          const SizedBox(height: 15),
                          _criarLinha(
                            icone: Icons.lock,
                            titulo: 'Token',
                            descricao: ApiService.getToken() != null
                                ? 'Autenticado'
                                : 'Não autenticado',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Funcionalidades disponíveis:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _criarCardFuncionalidade(
                    icone: Icons.dashboard,
                    titulo: 'Dashboard',
                    descricao: 'Visualizar resumo do rebanho e alertas',
                  ),
                  const SizedBox(height: 10),
                  _criarCardFuncionalidade(
                    icone: Icons.agriculture,
                    titulo: 'Gestão de Vacas',
                    descricao: 'Gerenciar rebanho e registrar eventos',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _criarLinha({
    required IconData icone,
    required String titulo,
    required String descricao,
  }) {
    return Row(
      children: [
        Icon(icone, color: Colors.green, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                descricao,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _criarCardFuncionalidade({
    required IconData icone,
    required String titulo,
    required String descricao,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icone, color: Colors.green, size: 30),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(descricao),
      ),
    );
  }
}
