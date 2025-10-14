import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _grad = [Color(0xFFF3E8FF), Color(0xFFEBDCF9)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: _grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.menu, color: Colors.black),
                    Text(
                      "ومضه",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Icon(Icons.notifications, color: Colors.black),
                  ],
                ),
                const SizedBox(height: 30),

                // Welcome text
                const Text(
                  "استقلاليتك تبدأ بخطوات بسيطة مع ومضه",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                // 3 big buttons
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _HomeButton(
                        title: "إضافة تنبيه",
                        icon: Icons.add_alarm,
                        onTap: () {
                          Navigator.pushNamed(context, '/setalert');
                        },
                      ),
                      _HomeButton(
                        title: "عرض التنبيهات",
                        icon: Icons.notifications,
                        onTap: () {
                          Navigator.pushNamed(context, '/alerts'); // ✅ فتح صفحة عرض التنبيهات
                        },
                      ),
                      _HomeButton(
                        title: "الإعدادات",
                        icon: Icons.settings,
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
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

class _HomeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _HomeButton({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
