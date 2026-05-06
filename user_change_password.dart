

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart'; // for BankingDashboard
import 'login.dart'; // for MyLoginPage

class WorkerChangePasswordPage extends StatefulWidget {
  const WorkerChangePasswordPage({super.key});

  @override
  State<WorkerChangePasswordPage> createState() => _WorkerChangePasswordPageState();
}

class _WorkerChangePasswordPageState extends State<WorkerChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController newPassCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (newPassCtrl.text != confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password and confirm password do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('url') ?? '';
      final loginId = prefs.getString('lid') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/user_change_password/'),
        body: {
          'login_id': loginId,
          'old_password': oldPassCtrl.text,
          'new_password': newPassCtrl.text,
        },
      );

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Error')),
      );

      if (data['success'] == true) {
        oldPassCtrl.clear();
        newPassCtrl.clear();
        confirmPassCtrl.clear();

        // Redirect to MyLoginPage after successful password change
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyLoginPage(title: '',)),
              (route) => false, // remove all previous routes
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    // Minimum 8 chars, at least 1 uppercase, 1 lowercase, 1 number, 1 special char
    final pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
    if (!RegExp(pattern).hasMatch(v)) {
      return 'Password must be at least 8 chars,\ninclude upper, lower, number & special char';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: const Color(0xFF26A69A), // teal color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BankingDashboard()),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF80CBC4), Color(0xFFE0F2F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                shadowColor: Colors.grey.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction, // ✅ live validation
                    child: Column(
                      children: [
                        const Text(
                          "Change Password",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: oldPassCtrl,
                          decoration: InputDecoration(
                            labelText: 'Old Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Enter old password' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: newPassCtrl,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: passwordValidator,
                          onChanged: (_) => setState(() {}), // ✅ live validation trigger
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: confirmPassCtrl,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirm new password';
                            if (v != newPassCtrl.text) return 'Passwords do not match';
                            return passwordValidator(v);
                          },
                          onChanged: (_) => setState(() {}), // ✅ live validation trigger
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : changePassword,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.all(0),
                              elevation: 5,
                              backgroundColor: Colors.transparent,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF26A69A), Color(0xFF80CBC4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Text(
                                  "Change Password",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
