import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const ForexBotApp());
}

class ForexBotApp extends StatelessWidget {
  const ForexBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Forex Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const TradingDashboard(),
    );
  }
}

class TradingDashboard extends StatefulWidget {
  const TradingDashboard({super.key});

  @override
  State<TradingDashboard> createState() => _TradingDashboardState();
}

class _TradingDashboardState extends State<TradingDashboard> {
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _mt5Login = TextEditingController();
  
  bool _isBotRunning = false;
  double _balance = 500.00;
  double _profitToday = 0.00;
  List<String> _tradeLogs = ["System initialized... Ready to trade."];

  // Simulated Broker List
  final List<String> _brokers = ['Exness', 'IC Markets', 'Pepperstone', 'Weltrade'];
  String? _selectedBroker;

  void _toggleBot() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isBotRunning = !_isBotRunning;
        _tradeLogs.insert(0, _isBotRunning ? "-> Bot Started: Analyzing EUR/USD..." : "-> Bot Stopped: Liquidating positions...");
      });

      if (_isBotRunning) {
        // Simple simulation of profit updates
        Timer.periodic(const Duration(seconds: 5), (timer) {
          if (!_isBotRunning) {
            timer.cancel();
          } else {
            setState(() {
              _profitToday += 1.25;
              _balance += 1.25;
              _tradeLogs.insert(0, "-> Trade Win: +1.25 USD (Scalp Strategy)");
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI FOREX BOT PRO', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER STATUS CARD
              _buildStatusCard(),

              const SizedBox(height: 30),
              const Text("CONNECTION SETTINGS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // INPUT FIELDS
              _buildTextField(_email, "User Email", Icons.email_outlined),
              const SizedBox(height: 15),
              
              DropdownButtonFormField<String>(
                value: _selectedBroker,
                decoration: _inputDecoration("Broker", Icons.account_balance_outlined),
                items: _brokers.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => setState(() => _selectedBroker = val),
                validator: (val) => val == null ? "Select a broker" : null,
              ),

              const SizedBox(height: 15),
              _buildTextField(_mt5Login, "MT5 Login ID", Icons.login),
              
              const SizedBox(height: 30),

              // ACTION BUTTONS
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _toggleBot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBotRunning ? Colors.redAccent : Colors.greenAccent[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _isBotRunning ? "STOP AI BOT" : "START AI BOT",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Text("LIVE TRADE LOGS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // TRADE LOG CONTAINER
              Container(
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListView.builder(
                  itemCount: _tradeLogs.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _tradeLogs[index],
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueGrey.shade900, Colors.black]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isBotRunning ? Colors.greenAccent : Colors.redAccent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Account Balance", style: TextStyle(color: Colors.white70)),
              Text("\$${_balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isBotRunning ? "STATUS: ACTIVE" : "STATUS: PAUSED", 
                style: TextStyle(color: _isBotRunning ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
              Text("Daily Profit: +\$${_profitToday.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      validator: (val) => val!.isEmpty ? "Required field" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.greenAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
    );
  }
}
