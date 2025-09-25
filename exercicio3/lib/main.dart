import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de IMC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const IMCCalculator(title: 'Calculadora de IMC'),
    );
  }
}

class IMCCalculator extends StatefulWidget {
  const IMCCalculator({super.key, required this.title});

  final String title;

  @override
  State<IMCCalculator> createState() => _IMCCalculatorState();
}

class _IMCCalculatorState extends State<IMCCalculator> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  double _imc = 0;
  String _classificacao = '';
  bool _calculoRealizado = false;

  // Função para calcular o IMC
  double calcularIMC(double peso, double altura) {
    return peso / (altura * altura);
  }

  // Função para classificar o IMC
  String classificarIMC(double imc) {
    if (imc < 18.5) {
      return 'Abaixo do peso';
    } else if (imc < 25) {
      return 'Normal';
    } else if (imc < 30) {
      return 'Sobrepeso';
    } else {
      return 'Obesidade';
    }
  }

  // Função para obter a cor baseada na classificação
  Color _getClassificacaoColor() {
    switch (_classificacao) {
      case 'Abaixo do peso':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Sobrepeso':
        return Colors.orange;
      case 'Obesidade':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  void _calcular() {
    // Fecha o teclado
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        double peso = double.parse(_pesoController.text.replaceAll(',', '.'));
        double altura = double.parse(_alturaController.text.replaceAll(',', '.'));
        
        _imc = calcularIMC(peso, altura);
        _classificacao = classificarIMC(_imc);
        _calculoRealizado = true;
      });
    }
  }

  void _limpar() {
    setState(() {
      _pesoController.clear();
      _alturaController.clear();
      _imc = 0;
      _classificacao = '';
      _calculoRealizado = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Informe seus dados:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _pesoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe seu peso';
                  }
                  double? peso = double.tryParse(value.replaceAll(',', '.'));
                  if (peso == null || peso <= 0 || peso > 300) {
                    return 'Informe um peso válido (entre 1 e 300 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alturaController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Altura (m)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                  hintText: 'Ex: 1.75',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe sua altura';
                  }
                  double? altura = double.tryParse(value.replaceAll(',', '.'));
                  if (altura == null || altura <= 0 || altura > 3) {
                    return 'Informe uma altura válida (entre 0.1 e 3 metros)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calcular,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('CALCULAR', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _limpar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('LIMPAR', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              if (_calculoRealizado) ...[  
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getClassificacaoColor(), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Seu IMC: ${_imc.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Classificação: $_classificacao',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getClassificacaoColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }
}
