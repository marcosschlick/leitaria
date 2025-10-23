import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
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

  // Função genérica para registrar ações
  Future<void> _registrarAcao(
    String tipoAcao,
    String endpoint,
    Map<String, dynamic> dados,
  ) async {
    setState(() {
      _carregando = true;
    });

    try {
      await ApiService.post(endpoint, dados);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$tipoAcao registrado para ${widget.vaca.nome}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar $tipoAcao: $e'),
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

  // Funções específicas para cada ação - CORRIGIDAS
  Future<void> _registrarOrdenha() async {
    final quantidadeController = TextEditingController();
    final turnoController = TextEditingController();
    String turnoSelecionado = 'manhã';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Ordenha'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (ml)',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 5000 (para 5 litros)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: turnoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Turno',
                    border: OutlineInputBorder(),
                  ),
                  items: ['manhã', 'tarde'].map((String turno) {
                    return DropdownMenuItem<String>(
                      value: turno,
                      child: Text(turno),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    turnoSelecionado = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (quantidadeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, informe a quantidade'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final now = DateTime.now();
                final dados = {
                  'quantidade_ml': int.parse(quantidadeController.text),
                  'turno': turnoSelecionado,
                  'data_ordenha': _formatarDataParaAPI(now),
                  'hora_ordenha': _formatarHoraParaAPI(now),
                };

                Navigator.pop(context);
                await _registrarAcao(
                  'Ordenha',
                  ApiConfig.registrarOrdenha(widget.vaca.id),
                  dados,
                );
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrarCio() async {
    final dataController = TextEditingController();
    final horaController = TextEditingController();
    final now = DateTime.now();
    dataController.text = _formatarDataParaAPI(now);
    horaController.text = _formatarHoraParaAPI(now);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Cio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dataController,
                  decoration: const InputDecoration(
                    labelText: 'Data da Detecção',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? dataSelecionada = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      locale: const Locale('pt', 'BR'),
                    );

                    if (dataSelecionada != null) {
                      dataController.text = _formatarDataParaAPI(
                        dataSelecionada,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: horaController,
                  decoration: const InputDecoration(
                    labelText: 'Hora da Detecção',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay? horaSelecionada = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (horaSelecionada != null) {
                      final now = DateTime.now();
                      final DateTime horaDateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        horaSelecionada.hour,
                        horaSelecionada.minute,
                      );
                      horaController.text = _formatarHoraParaAPI(horaDateTime);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final dados = {
                  'data_detecao': dataController.text,
                  'hora_detecao': horaController.text,
                };

                Navigator.pop(context);
                _registrarAcao(
                  'Cio',
                  ApiConfig.registrarCio(widget.vaca.id),
                  dados,
                );
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrarPeso() async {
    final pesoController = TextEditingController();
    final dataController = TextEditingController();
    final now = DateTime.now();
    dataController.text = _formatarDataParaAPI(now);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Peso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pesoController,
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dataController,
                  decoration: const InputDecoration(
                    labelText: 'Data do Registro',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? dataSelecionada = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      locale: const Locale('pt', 'BR'),
                    );

                    if (dataSelecionada != null) {
                      dataController.text = _formatarDataParaAPI(
                        dataSelecionada,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pesoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, informe o peso'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final dados = {
                  'peso_kg': double.parse(pesoController.text),
                  'data_registro': dataController.text,
                };

                Navigator.pop(context);
                _registrarAcao(
                  'Peso',
                  ApiConfig.registrarPeso(widget.vaca.id),
                  dados,
                );
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrarInseminacao() async {
    final dataController = TextEditingController();
    final touroController = TextEditingController();
    String tipoSelecionado = 'IA';
    final now = DateTime.now();
    dataController.text = _formatarDataParaAPI(now);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Inseminação'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: ['IA', 'Monta natural'].map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    tipoSelecionado = newValue!;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: touroController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Touro (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dataController,
                  decoration: const InputDecoration(
                    labelText: 'Data da Inseminação',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? dataSelecionada = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      locale: const Locale('pt', 'BR'),
                    );

                    if (dataSelecionada != null) {
                      dataController.text = _formatarDataParaAPI(
                        dataSelecionada,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final dados = {
                  'tipo': tipoSelecionado,
                  'data_inseminacao': dataController.text,
                };

                if (touroController.text.isNotEmpty) {
                  dados['nome_touro'] = touroController.text;
                }

                Navigator.pop(context);
                _registrarAcao(
                  'Inseminação',
                  ApiConfig.registrarInseminacao(widget.vaca.id),
                  dados,
                );
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarPrenhez() async {
    final dataController = TextEditingController();
    final now = DateTime.now();
    dataController.text = _formatarDataParaAPI(now);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Prenhez'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dataController,
                  decoration: const InputDecoration(
                    labelText: 'Data da Confirmação',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? dataSelecionada = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      locale: const Locale('pt', 'BR'),
                    );

                    if (dataSelecionada != null) {
                      dataController.text = _formatarDataParaAPI(
                        dataSelecionada,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final dados = {'data_inicio': dataController.text};

                Navigator.pop(context);
                _registrarAcao(
                  'Prenhez',
                  ApiConfig.registrarPrenhez(widget.vaca.id),
                  dados,
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrarParto() async {
    final dataController = TextEditingController();
    String sexoSelecionado = 'Fêmea';
    final now = DateTime.now();
    dataController.text = _formatarDataParaAPI(now);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Parto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dataController,
                  decoration: const InputDecoration(
                    labelText: 'Data do Parto',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? dataSelecionada = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      locale: const Locale('pt', 'BR'),
                    );

                    if (dataSelecionada != null) {
                      dataController.text = _formatarDataParaAPI(
                        dataSelecionada,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: sexoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Sexo da Cria',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Fêmea', 'Macho'].map((String sexo) {
                    return DropdownMenuItem<String>(
                      value: sexo,
                      child: Text(sexo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    sexoSelecionado = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final dados = {
                  'data_parto': dataController.text,
                  'sexo_cria': sexoSelecionado,
                };

                Navigator.pop(context);
                _registrarAcao(
                  'Parto',
                  ApiConfig.registrarParto(widget.vaca.id),
                  dados,
                );
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBotaoAcao(
    String texto,
    IconData icone,
    Color cor,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _carregando ? null : onPressed,
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
                    _registrarOrdenha,
                  ),
                  const SizedBox(width: 8),
                  _buildBotaoAcao(
                    'Cio',
                    Icons.circle,
                    Colors.orange,
                    _registrarCio,
                  ),
                  const SizedBox(width: 8),
                  _buildBotaoAcao(
                    'Peso',
                    Icons.monitor_weight,
                    Colors.purple,
                    _registrarPeso,
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
                    _registrarInseminacao,
                  ),
                  const SizedBox(width: 8),
                  _buildBotaoAcao(
                    'Prenhez',
                    Icons.favorite,
                    Colors.red,
                    _confirmarPrenhez,
                  ),
                  const SizedBox(width: 8),
                  _buildBotaoAcao(
                    'Parto',
                    Icons.emoji_people,
                    Colors.green,
                    _registrarParto,
                  ),
                ],
              ),
              if (_carregando)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
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

  String _formatarDataParaAPI(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  String _formatarHoraParaAPI(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
