import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // LOGIN
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // BROKER DATA MAP
  String? selectedBroker;
  String? selectedServer;

  // Real-world MT5 broker server routing configurations
  final Map<String, List<String>> brokerServers = {
    'Deriv': ['Deriv-Server', 'Deriv-Server-02', 'Deriv-Demo'],
    'Exness': ['Exness-MT5Trial', 'Exness-MT5Real', 'Exness-MT5Real2', 'Exness-MT5Real3'],
    'IC Markets': ['ICMarketsSC-MT5', 'ICMarketsSC-MT5-2', 'ICMarkets-Demo'],
    'JustMarkets': ['JustMarkets-Live', 'JustMarkets-Live2', 'JustMarkets-Demo'],
    'Weltrade': ['Weltrade-Live', 'Weltrade-Live2', 'Weltrade-Demo'],
    'Pepperstone': ['Pepperstone-MT5-Live', 'Pepperstone-MT5-Demo'],
  };

  final mt5LoginController = TextEditingController();
  final mt5PasswordController = TextEditingController();

  // RISK SETTINGS
  final tradeAmountController = TextEditingController();
  final maxTradesController = TextEditingController();

  bool botRunning = false;
  String tradeDirection = "Both";

  double balance = 500.0;
  double profitToday = 35.0;

  void startBot() {
    if (!botRunning) {
      setState(() {
        botRunning = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("AI Trading Bot Engine Started")),
      );
    }
  }

  void stopBot() {
    if (botRunning) {
      setState(() {
        botRunning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("AI Trading Bot Engine Halted")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    mt5LoginController.dispose();
    mt5PasswordController.dispose();
    tradeAmountController.dispose();
    maxTradesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Forex Bot", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: botRunning ? Colors.green.withOpacity(0.2) : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER LOGO SECTION
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    size: 80,
                    color: botRunning ? Colors.green : Colors.blueAccent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "AI FOREX TRADING SYSTEM",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // BOT STATUS DASHBOARD
            BotStatusCard(
              botRunning: botRunning,
              balance: balance,
              profitToday: profitToday,
              tradeDirection: tradeDirection,
            ),
            const SizedBox(height: 20),

            // MASTER CONTROL BUTTON
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: botRunning ? stopBot : startBot,
                icon: Icon(botRunning ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white),
                label: Text(
                  botRunning ? "STOP ALGO ENGINE" : "ENGAGE ALGO ENGINE",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: botRunning ? Colors.redAccent : Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ACCOUNT CREDENTIALS SECTION (With Cascading Server Dropdown)
            AccountCredentialsCard(
              emailController: emailController,
              passwordController: passwordController,
              selectedBroker: selectedBroker,
              selectedServer: selectedServer,
              brokerServers: brokerServers,
              mt5LoginController: mt5LoginController,
              mt5PasswordController: mt5PasswordController,
              onBrokerChanged: (value) {
                setState(() {
                  selectedBroker = value;
                  selectedServer = null; // Reset server when broker updates
                });
              },
              onServerChanged: (value) {
                setState(() {
                  selectedServer = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // RISK & PARAMETERS CONFIGURATION
            RiskSettingsCard(
              tradeDirection: tradeDirection,
              tradeAmountController: tradeAmountController,
              maxTradesController: maxTradesController,
              onDirectionChanged: (value) {
                if (value != null) setState(() => tradeDirection = value);
              },
            ),
            const SizedBox(height: 24),

            // DISCONNECT / CONNECT AUX BUTTON
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Broker handshake parameters synchronized successfully")),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.white30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SYNC CREDENTIALS", style: TextStyle(letterSpacing: 1.1)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class BotStatusCard extends StatelessWidget {
  final bool botRunning;
  final double balance;
  final double profitToday;
  final String tradeDirection;

  const BotStatusCard({
    super.key,
    required this.botRunning,
    required this.balance,
    required this.profitToday,
    required this.tradeDirection,
  });

  @override
  Widget build(BuildContext context) {
    final pnlSign = profitToday >= 0 ? '+' : '-';
    final pnlColor = profitToday >= 0 ? Colors.green : Colors.redAccent;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: botRunning ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  botRunning ? "SYSTEM RUNNING" : "SYSTEM DEACTIVATED",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: botRunning ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricTile("Balance", "\$${balance.toStringAsFixed(2)}"),
                _buildMetricTile(
                  "Today's PnL",
                  "$pnlSign\$${profitToday.abs().toStringAsFixed(2)}",
                  color: pnlColor,
                ),
                _buildMetricTile("Filter", tradeDirection.toUpperCase()),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class AccountCredentialsCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? selectedBroker;
  final String? selectedServer;
  final Map<String, List<String>> brokerServers;
  final TextEditingController mt5LoginController;
  final TextEditingController mt5PasswordController;
  final ValueChanged<String?> onBrokerChanged;
  final ValueChanged<String?> onServerChanged;

  const AccountCredentialsCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.selectedBroker,
    required this.selectedServer,
    required this.brokerServers,
    required this.mt5LoginController,
    required this.mt5PasswordController,
    required this.onBrokerChanged,
    required this.onServerChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the available servers based on the currently selected broker node
    List<String> availableServers = selectedBroker != null ? brokerServers[selectedBroker]! : [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BROKER & METATRADER INTEGRATION",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Client Portal Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Client Portal Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBroker,
              decoration: const InputDecoration(labelText: "Target Broker Node", border: OutlineInputBorder()),
              items: brokerServers.keys.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: onBrokerChanged,
            ),
            const SizedBox(height: 16),
            // CASCADING DEPENDENT DROP-DOWN FOR LIVE/DEMO SERVERS
            DropdownButtonFormField<String>(
              value: selectedServer,
              disabledHint: const Text("Select a broker first"),
              decoration: const InputDecoration(labelText: "MT5 Active Server Routing", border: OutlineInputBorder()),
              items: availableServers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: selectedBroker == null ? null : onServerChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mt5LoginController,
                    decoration: const InputDecoration(labelText: "MT5 Login ID", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: mt5PasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "MT5 Password", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RiskSettingsCard extends StatelessWidget {
  final String tradeDirection;
  final TextEditingController tradeAmountController;
  final TextEditingController maxTradesController;
  final ValueChanged<String?> onDirectionChanged;

  const RiskSettingsCard({
    super.key,
    required this.tradeDirection,
    required this.tradeAmountController,
    required this.maxTradesController,
    required this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ALGORITHMIC RISK PARAMETERS",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tradeAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Margin Per Trade (\$)", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: maxTradesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Max Allowed Trades", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Execution Vector Rule", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "Buy", label: Text("Long Only")),
                ButtonSegment(value: "Sell", label: Text("Short Only")),
                ButtonSegment(value: "Both", label: Text("Bi-Directional")),
              ],
              selected: {tradeDirection},
              onSelectionChanged: (Set<String> selection) {
                onDirectionChanged(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
