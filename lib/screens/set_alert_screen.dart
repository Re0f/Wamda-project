import 'package:flutter/material.dart';
import '../data/models/alert.dart';
import '../data/repositories/alerts_repo.dart';

class SetAlertScreen extends StatefulWidget {
  const SetAlertScreen({super.key});

  @override
  State<SetAlertScreen> createState() => _SetAlertScreenState();
}

class _SetAlertScreenState extends State<SetAlertScreen> {
  final _labelCtrl = TextEditingController();
  TimeOfDay? _time;
  // Sun..Sat:
  final List<bool> _days = List.filled(7, false);
  final _dayNames = const ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  int _daysToMask(List<bool> v) {
    int m = 0;
    for (int i = 0; i < v.length; i++) {
      if (v[i]) m |= (1 << i);
    }
    return m;
  }

  String _fmtTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 7, minute: 30),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a time')),
      );
      return;
    }
    final mask = _daysToMask(_days);
    final a = Alert(
      label: _labelCtrl.text.trim().isEmpty ? 'Alert' : _labelCtrl.text.trim(),
      hour: _time!.hour,
      minute: _time!.minute,
      daysMask: mask, // 0 = بدون تكرار (مرّة واحدة) (الجدولة لاحقًا)
      enabled: true,
    );
    await AlertsRepo.instance.insert(a);
    if (!mounted) return;
    Navigator.pop(context, true); // نرجع للشاشة السابقة ونطلب تحديث
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFEBDCF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Set Alert",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // Time
                InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    child: Text(_time == null ? 'Tap to pick time' : _fmtTime(_time!)),
                  ),
                ),
                const SizedBox(height: 16),

                // Repeat days
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (i) {
                      return FilterChip(
                        label: Text(_dayNames[i]),
                        selected: _days[i],
                        onSelected: (v) => setState(() => _days[i] = v),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // Label
                TextField(
                  controller: _labelCtrl,
                  decoration: const InputDecoration(
                    labelText: "Label",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
