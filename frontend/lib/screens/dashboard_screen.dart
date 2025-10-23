import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _dashboardData = {};
  bool _carregando = true;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  Future<void> _carregarDashboard() async {
    try {
      final resposta = await ApiService.get(ApiConfig.dashboard);
      setState(() {
        _dashboardData = resposta;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  Widget _buildStatCard(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        constraints: const BoxConstraints(minHeight: 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 32, color: cor),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaCard(String titulo, String descricao, Color cor) {
    return Card(
      elevation: 2,
      color: cor.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.warning, color: cor),
        title: Text(
          titulo,
          style: TextStyle(fontWeight: FontWeight.bold, color: cor),
        ),
        subtitle: Text(descricao),
      ),
    );
  }

  List<Widget> _buildAlertas() {
    final alertas = _dashboardData['alertas'] ?? {};
    final List<Widget> widgets = [];

    // Detalhes de cios
    final detalhesCios = alertas['detalhes_cios'] ?? [];
    for (var cio in detalhesCios) {
      widgets.add(
        _buildAlertaCard(
          'Cio Detectado',
          '${cio['nome']} (Brinco: ${cio['numero_brinco']}) - Próximo ciclo em 21 dias',
          Colors.orange,
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDashboard,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dashboard',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _erro,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _carregarDashboard,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Layout responsivo baseado na largura da tela
                final isMobile = constraints.maxWidth < 600;
                final crossAxisCount = isMobile ? 2 : 4;
                final childAspectRatio = isMobile ? 1.0 : 1.2;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Estatísticas do Rebanho
                      const Text(
                        'Estatísticas do Rebanho',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid responsivo
                      GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildStatCard(
                            'Total de Vacas',
                            _dashboardData['totais']?['vacas']?.toString() ??
                                '0',
                            Icons.agriculture,
                            Colors.green,
                          ),
                          _buildStatCard(
                            'Em Lactação',
                            _dashboardData['totais']?['lactacao']?.toString() ??
                                '0',
                            Icons.local_drink,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'Vacas Prenhes',
                            _dashboardData['totais']?['prenhas']?.toString() ??
                                '0',
                            Icons.favorite,
                            Colors.pink,
                          ),
                          _buildStatCard(
                            'Produção Hoje',
                            '${_dashboardData['producao']?['leite_hoje_litros']?.toString() ?? '0'} L',
                            Icons.bar_chart,
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Produção do Dia
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.bar_chart, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Produção do Dia',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  '${_dashboardData['producao']?['leite_hoje_litros']?.toString() ?? '0'} Litros',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Produção total de leite hoje',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Alertas
                      const Text(
                        'Alertas e Avisos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAlertas().isNotEmpty
                          ? Column(children: _buildAlertas())
                          : const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Nenhum alerta no momento',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
