import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class CriarVacaScreen extends StatefulWidget {
  const CriarVacaScreen({super.key});

  @override
  State<CriarVacaScreen> createState() => _CriarVacaScreenState();
}

class _CriarVacaScreenState extends State<CriarVacaScreen> {
  final _nomeController = TextEditingController();
  final _brincoController = TextEditingController();
  final _qrCodeController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _racaController = TextEditingController();

  bool _carregando = false;
  final _formKey = GlobalKey<FormState>();

  // Lista de raças pré-definidas
  final List<String> _racas = [
    'Holandesa',
    'Jersey',
    'Gir',
    'Girolando',
    'Guzerá',
    'Sindi',
    'Pardo Suíço',
    'Outra',
  ];
  String _racaSelecionada = 'Holandesa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Nova Vaca'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _carregando ? null : _criarVaca,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/icons/vaca.png', width: 80, height: 80),
              const SizedBox(height: 16),
              const Text(
                'Cadastrar Nova Vaca',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),

              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Vaca *',
                  prefixIcon: Icon(Icons.agriculture),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Mimosa, Flor, Estrela',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o nome da vaca';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Número do Brinco
              TextFormField(
                controller: _brincoController,
                decoration: const InputDecoration(
                  labelText: 'Número do Brinco *',
                  prefixIcon: Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 001, 002, A123',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o número do brinco';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo QR Code
              TextFormField(
                controller: _qrCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código QR (Opcional)',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                  hintText: 'Código único do QR Code',
                ),
              ),
              const SizedBox(height: 20),

              // Campo Raça (Dropdown)
              DropdownButtonFormField<String>(
                value: _racaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Raça *',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                items: _racas.map((String raca) {
                  return DropdownMenuItem<String>(
                    value: raca,
                    child: Text(raca),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _racaSelecionada = newValue!;
                    if (newValue == 'Outra') {
                      _racaController.text = '';
                    } else {
                      _racaController.text = newValue;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a raça';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo para raça personalizada (se selecionar "Outra")
              if (_racaSelecionada == 'Outra')
                TextFormField(
                  controller: _racaController,
                  decoration: const InputDecoration(
                    labelText: 'Informe a Raça *',
                    prefixIcon: Icon(Icons.create),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Nelore, Angus, etc.',
                  ),
                  validator: (value) {
                    if (_racaSelecionada == 'Outra' &&
                        (value == null || value.isEmpty)) {
                      return 'Por favor, informe a raça';
                    }
                    return null;
                  },
                ),
              if (_racaSelecionada == 'Outra') const SizedBox(height: 20),

              // Campo Data de Nascimento
              TextFormField(
                controller: _dataNascimentoController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento (Opcional)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  hintText: 'AAAA-MM-DD',
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? dataSelecionada = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(
                      const Duration(days: 365 * 2), // 2 anos atrás como padrão
                    ),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    locale: const Locale('pt', 'BR'),
                  );

                  if (dataSelecionada != null) {
                    final dataFormatada =
                        "${dataSelecionada.year}-${dataSelecionada.month.toString().padLeft(2, '0')}-${dataSelecionada.day.toString().padLeft(2, '0')}";
                    setState(() {
                      _dataNascimentoController.text = dataFormatada;
                    });
                  }
                },
              ),
              const SizedBox(height: 30),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _carregando ? null : _cancelar,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _criarVaca,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _carregando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Salvar Vaca',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _criarVaca() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      try {
        // Prepara os dados para envio
        final Map<String, dynamic> dadosVaca = {
          'nome': _nomeController.text.trim(),
          'numero_brinco': _brincoController.text.trim(),
          'raca': _racaSelecionada == 'Outra'
              ? _racaController.text.trim()
              : _racaSelecionada,
        };

        // Adiciona campos opcionais se preenchidos
        if (_qrCodeController.text.isNotEmpty) {
          dadosVaca['qr_code'] = _qrCodeController.text.trim();
        }

        if (_dataNascimentoController.text.isNotEmpty) {
          dadosVaca['data_nascimento'] = _dataNascimentoController.text;
        }

        await ApiService.post(ApiConfig.vacas, dadosVaca);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vaca cadastrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Retorna para a tela anterior
          Navigator.pop(context, true); // true indica que uma vaca foi criada
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar vaca: $e'),
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
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _brincoController.dispose();
    _qrCodeController.dispose();
    _dataNascimentoController.dispose();
    _racaController.dispose();
    super.dispose();
  }
}
