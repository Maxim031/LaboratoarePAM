import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// 1. STATELESS WIDGET
/// Acest widget nu își schimbă starea internă (nu stochează date dinamice).
/// Rolul lui este doar de a configura tema și structura aplicației.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Consum',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const CalculatorConsumScreen(),
    );
  }
}

/// 2. STATEFUL WIDGET
/// Acest widget păstrează starea (datele introduse de utilizator și rezultat)
/// și redenează ecranul de fiecare dată când apelăm `setState()`.
class CalculatorConsumScreen extends StatefulWidget {
  const CalculatorConsumScreen({super.key});

  @override
  State<CalculatorConsumScreen> createState() => _CalculatorConsumScreenState();
}

class _CalculatorConsumScreenState extends State<CalculatorConsumScreen> {
  // Controllere pentru a citi textul din câmpurile de introducere
  final TextEditingController _distantaController = TextEditingController();
  final TextEditingController _combustibilController = TextEditingController();

  // Variabilă de stare pentru textul cu rezultatul
  String _rezultat = "";

  // Metoda care conține logica de calcul
  void _calculeazaConsum() {
    final double? distanta = double.tryParse(_distantaController.text);
    final double? combustibil = double.tryParse(_combustibilController.text);

    // Apelăm setState pentru a notifica Flutter că starea s-a schimbat
    // și că ecranul trebuie actualizat
    setState(() {
      if (distanta == null || combustibil == null) {
        _rezultat = "Introduceți numere valide!";
      } else if (distanta <= 0) {
        _rezultat = "Distanța trebuie să fie mai mare decât 0!";
      } else if (combustibil < 0) {
        _rezultat = "Cantitatea nu poate fi negativă!";
      } else {
        final double consum = (combustibil * 100) / distanta;
        _rezultat = "Consum mediu: ${consum.toStringAsFixed(2)} l/100 km";
      }
    });
  }

  // Eliberăm resursele controllerelor când widget-ul este distrus
  @override
  void dispose() {
    _distantaController.dispose();
    _combustibilController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator Consum'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Widget pentru introducerea distanței
              TextField(
                controller: _distantaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Distanța parcursă (km)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Widget pentru introducerea combustibilului
              TextField(
                controller: _combustibilController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Combustibil consumat (litri)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Widget Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _calculeazaConsum,
                  child: const Text(
                    "Calculează",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Widget Text pentru afișarea rezultatului
              Text(
                _rezultat,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}