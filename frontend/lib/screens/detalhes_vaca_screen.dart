import 'package:flutter/material.dart';
import '../models/vaca.dart';

class DetalhesVacaScreen extends StatefulWidget {
  final Vaca vaca;

  const DetalhesVacaScreen({super.key, required this.vaca});

  @override
  State<DetalhesVacaScreen> createState() => _DetalhesVacaScreenState();
}

class _DetalhesVacaScreenState extends State<DetalhesVacaScreen> {
  bool _carregando = false;

  Widget _buildInfoCard(String titulo, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarAcao(String tipoAcao) async {
    setState(() {
      _carregando = true;
    });

    try {
      // TODO: Implementar lógica específica para cada ação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$tipoAcao registrado para ${widget.vaca.nome}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar $tipoAcao: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Widget _buildBotaoAcao(
    String texto,
    IconData icone,
    Color cor,
    String tipoAcao,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _carregando ? null : () => _registrarAcao(tipoAcao),
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
        icon: Icon(icone, size: 20),
        label: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vaca.nome),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cabeçalho com ícone e nome
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.agriculture,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.vaca.nome,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Brinco: ${widget.vaca.numeroBrinco}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Informações Básicas
            _buildInfoCard('Informações Básicas', [
              _buildInfoItem('Número do Brinco', widget.vaca.numeroBrinco),
              _buildInfoItem('Raça', widget.vaca.raca),
              if (widget.vaca.dataNascimento != null)
                _buildInfoItem(
                  'Data de Nascimento',
                  _formatarData(widget.vaca.dataNascimento!),
                ),
              if (widget.vaca.qrCode != null)
                _buildInfoItem('QR Code', widget.vaca.qrCode!),
              _buildInfoItem('ID', widget.vaca.id.toString()),
            ]),
            const SizedBox(height: 20),

            // Ações Rápidas
            _buildInfoCard('Ações Rápidas', [
              const Text(
                'Registrar eventos para esta vaca:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildBotaoAcao(
                    'Ordenha',
                    Icons.local_drink,
                    Colors.blue,
                    'Ordenha',
                  ),
                  const SizedBox(width: 8),
                  _buildBotaoAcao('Cio', Icons.circle, Colors.orange, 'Cio'),
                  const SizedBox(width: 8),
                  _buildBotaoAcao(
                    'Peso',
                    Icons.monitor_weight,
                    Colors.purple,
                    'Peso',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildBotaoAcao(
                    'Inseminação',
                    Icons.health_and_safety,
                    Colors.pink,
                    'Inseminação',
                  ),
                  const SizedBox(width: 8),
                  _buildBotaoAcao(
                    'Prenhez',
                    Icons.favorite,
                    Colors.red,
                    'Prenhez',
                  ),
                  const SizedBox(width: 8),
                  _buildBotaoAcao(
                    'Parto',
                    Icons.emoji_people,
                    Colors.green,
                    'Parto',
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),

            _buildInfoCard('Estatísticas', [
              const Center(),
              const SizedBox(height: 8),
              _buildInfoItem('Produção Total', '0 Litros'),
              _buildInfoItem('Última Ordenha', 'Não registrada'),
              _buildInfoItem('Status Reprodutivo', 'Não informado'),
            ]),
          ],
        ),
      ),
    );
  }

  String _formatarData(String data) {
    try {
      final dateTime = DateTime.parse(data);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return data;
    }
  }
}
