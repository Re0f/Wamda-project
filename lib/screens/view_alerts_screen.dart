import 'package:flutter/material.dart';
import '../data/models/alert.dart';
import '../data/repositories/alerts_repo.dart';

class ViewAlertsScreen extends StatefulWidget {
  const ViewAlertsScreen({super.key});

  @override
  State<ViewAlertsScreen> createState() => _ViewAlertsScreenState();
}

class _ViewAlertsScreenState extends State<ViewAlertsScreen> {
  List<Alert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = await AlertsRepo.instance.getAll();
    if (!mounted) return;
    setState(() => _alerts = list);
  }

  String _fmt(int v) => v.toString().padLeft(2, '0');

  Future<void> _add() async {
    final changed = await Navigator.pushNamed(context, '/setalert');
    if (changed == true) _refresh();
  }

  Future<void> _delete(Alert a) async {
    await AlertsRepo.instance.delete(a.id!);
    _refresh();
  }

  Future<void> _toggle(Alert a, bool v) async {
    await AlertsRepo.instance.toggleEnabled(a.id!, v);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Alerts", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFEBDCF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _alerts.isEmpty
              ? const Center(child: Text('No alerts yet'))
              : ListView.separated(
            itemCount: _alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = _alerts[i];
              final time = '${_fmt(a.hour)}:${_fmt(a.minute)}';
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('$time - ${a.label}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: a.enabled,
                        onChanged: (v) => _toggle(a, v),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(a),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        label: const Text('Add Alert'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
