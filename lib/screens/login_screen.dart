import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      "assets/images/logo.png",
                      height: 150
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Welcome !",
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 40),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(color: Colors.black),
                      border: UnderlineInputBorder(),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.black),
                      border: UnderlineInputBorder(),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      // Go to Home and replace Login
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text("Log in"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Forgot Password",
                        style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Create"),
                  ),
                  const SizedBox(height: 10),
                  const Text("Don't Have an Account?",
                      style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}