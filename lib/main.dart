import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const ExpensinfoApp());
}

class ExpensinfoApp extends StatelessWidget {
  const ExpensinfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D09C),
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LocalAuthentication auth = LocalAuthentication();
  bool unlocked = false;
  bool biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    authenticate();
  }

  Future<void> authenticate() async {
    if (!biometricEnabled) {
      setState(() => unlocked = true);
      return;
    }

    try {
      bool didAuth = await auth.authenticate(
        localizedReason: 'Unlock Expensinfo',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      setState(() => unlocked = didAuth);
    } catch (e) {
      setState(() => unlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!unlocked) {
      return const Scaffold(
        body: Center(child: Text("Authentication Required")),
      );
    }
    return const DashboardScreen();
  }
}
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalLent = 0;
  double totalBorrowed = 0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<Database> getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'expensinfo.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE ledger(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type TEXT, amount REAL, purpose TEXT, date TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> loadData() async {
    final db = await getDB();
    final data = await db.query('ledger');

    double lent = 0;
    double borrowed = 0;

    for (var t in data) {
      if (t['type'] == 'Lent') {
        lent += t['amount'] as double;
      } else if (t['type'] == 'Borrowed') {
        borrowed += t['amount'] as double;
      }
    }

    setState(() {
      transactions = data;
      totalLent = lent;
      totalBorrowed = borrowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    double net = totalLent - totalBorrowed;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransaction()),
          );
          loadData();
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Expensinfo",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            buildCard("You Will Receive", totalLent, Colors.green),
            buildCard("You Need To Pay", totalBorrowed, Colors.red),
            buildCard("Net Position", net, Colors.amber),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (_, i) {
                  final t = transactions[i];
                  return Card(
                    child: ListTile(
                      title: Text("${t['name']}  ₹${t['amount']}"),
                      subtitle: Text("${t['type']} • ${t['purpose']}"),
                      trailing: Text(t['date']),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCard(String title, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), const Color(0xFF1A1C22)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text("₹${value.toStringAsFixed(2)}"),
        ],
      ),
    );
  }
}
class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final name = TextEditingController();
  final amount = TextEditingController();
  final purpose = TextEditingController();
  String type = "Lent";

  Future<Database> getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), 'expensinfo.db'),
      version: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
            TextField(controller: purpose, decoration: const InputDecoration(labelText: "Purpose")),
            DropdownButton<String>(
              value: type,
              isExpanded: true,
              items: ["Lent", "Borrowed"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => type = v!),
            ),
            ElevatedButton(
              onPressed: () async {
                final db = await getDB();
                await db.insert("ledger", {
                  "name": name.text,
                  "type": type,
                  "amount": double.parse(amount.text),
                  "purpose": purpose.text,
                  "date": DateFormat('dd-MM-yyyy').format(DateTime.now()),
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
