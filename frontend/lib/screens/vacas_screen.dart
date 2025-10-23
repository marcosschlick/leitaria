import 'package:flutter/material.dart';
import 'package:milkflow/models/vaca.dart';
import 'package:milkflow/screens/detalhes_vaca_screen.dart';
import 'criar_vaca_screen.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class VacasScreen extends StatefulWidget {
  const VacasScreen({super.key});

  @override
  State<VacasScreen> createState() => _VacasScreenState();
}

class _VacasScreenState extends State<VacasScreen> {
  List<Vaca> _vacas = [];
  List<Vaca> _vacasFiltradas = [];
  bool _carregando = true;
  String _erro = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qrCodeController = TextEditingController();
  final TextEditingController _brincoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarVacas();
  }

  Future<void> _carregarVacas() async {
    try {
      final resposta = await ApiService.get(ApiConfig.vacas);
      final List<dynamic> vacasJson = resposta['vacas'] ?? [];

      setState(() {
        _vacas = vacasJson.map((json) => Vaca.fromJson(json)).toList();
        _vacasFiltradas = _vacas;
        _carregando = false;
        _erro = '';
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  void _filtrarVacas(String query) {
    setState(() {
      if (query.isEmpty) {
        _vacasFiltradas = _vacas;
      } else {
        _vacasFiltradas = _vacas
            .where(
              (vaca) =>
                  vaca.nome.toLowerCase().contains(query.toLowerCase()) ||
                  vaca.numeroBrinco.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _limparBusca() {
    _searchController.clear();
    _qrCodeController.clear();
    _brincoController.clear();
    setState(() {
      _vacasFiltradas = _vacas;
    });
  }

  Widget _buildVacaCard(Vaca vaca) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Image.asset('assets/icons/vaca.png', width: 36, height: 36),
        title: Text(
          vaca.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brinco: ${vaca.numeroBrinco}'),
            Text('Raça: ${vaca.raca}'),
            if (vaca.dataNascimento != null)
              Text('Nascimento: ${_formatarData(vaca.dataNascimento!)}'),
            if (vaca.qrCode != null) Text('QR Code: ${vaca.qrCode}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesVacaScreen(vaca: vaca),
            ),
          );
        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Vacas'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarVacas,
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
                    'Erro ao carregar vacas',
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
                    onPressed: _carregarVacas,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Barra de Busca
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por nome ou brinco',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filtrarVacas('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _filtrarVacas,
                  ),
                ),

                // Contador de resultados
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_vacasFiltradas.length} vaca(s) encontrada(s)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_vacasFiltradas.length != _vacas.length)
                        TextButton(
                          onPressed: _limparBusca,
                          child: const Text('Mostrar Todas'),
                        ),
                    ],
                  ),
                ),

                // Lista de Vacas
                Expanded(
                  child: _vacasFiltradas.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.agriculture_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma vaca encontrada',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _vacasFiltradas.length,
                          itemBuilder: (context, index) {
                            return _buildVacaCard(_vacasFiltradas[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CriarVacaScreen()),
          ).then((vacaCriada) {
            // Se uma vaca foi criada, atualiza a lista
            if (vacaCriada == true) {
              _carregarVacas();
            }
          });
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qrCodeController.dispose();
    _brincoController.dispose();
    super.dispose();
  }
}
