import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _availableDevices = const [
    'SVH-Headset-01',
    'SVH-Headset-02',
    'Demo-ESP32'
  ];
  String? _selectedDevice;
  bool _isConnected = false;
  bool _dnd = false;
  int _battery = 80;

  Future<void> _connect() async {
    if (_selectedDevice == null) return;
    setState(() => _isConnected = false);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isConnected = true);
  }

  Future<void> _reconnect() async {
    await _connect();
  }

  Future<void> _testVibration() async {
    if (!_isConnected) {
      _snack('Connect a device first');
      return;
    }
    _snack('Vibration test sent ✅');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    const grad = [Color(0xFFF3E8FF), Color(0xFFEBDCF9)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Select a device',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedDevice,
                        items: _availableDevices
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedDevice = v),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _selectedDevice == null ? null : _connect,
                              child: const Text('Connect'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_isConnected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Device connected successfully'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Battery:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _battery / 100,
                                minHeight: 12,
                                backgroundColor: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('$_battery%'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Do Not Disturb'),
                        value: _dnd,
                        onChanged: (v) => setState(() => _dnd = v),
                      ),
                    ],
                  ),
                ),
                _SectionCard(
                  child: Column(
                    children: [
                      _WideButton(
                        label: 'Reconnect',
                        onPressed: _isConnected ? _reconnect : null,
                      ),
                      const SizedBox(height: 8),
                      _WideButton(
                        label: 'Test Vibration',
                        onPressed: _testVibration,
                      ),
                      const SizedBox(height: 8),
                      _WideButton(
                        label: 'Log out',
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/', // يرجع لصفحة تسجيل الدخول
                                (route) => false, // يمسح كل الصفحات السابقة
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _WideButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label),
      ),
    );
  }
}
