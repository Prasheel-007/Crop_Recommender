import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInput);
    _passwordController.addListener(_validateInput);
  }

  void _validateInput() {
    final isEnabled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    if (isEnabled != _isLoginButtonEnabled) {
      setState(() {
        _isLoginButtonEnabled = isEnabled;
      });
    }
  }

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  void _skipLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.grass, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text('Welcome!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Log in or skip to continue', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 40),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoginButtonEnabled ? _login : null,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ),
              TextButton(onPressed: _skipLogin, child: const Text('Skip for now'))
            ],
          ),
        ),
      ),
    );
  }
}