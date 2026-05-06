


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const UserSuggestionApp());
}

class UserSuggestionApp extends StatelessWidget {
  const UserSuggestionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SendSuggestionPage(),
    );
  }
}

class SendSuggestionPage extends StatefulWidget {
  const SendSuggestionPage({super.key});

  @override
  State<SendSuggestionPage> createState() => _SendSuggestionPageState();
}

class _SendSuggestionPageState extends State<SendSuggestionPage> {
  TextEditingController suggestionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  /// Function to send suggestion to backend
  Future<void> _sendSuggestion() async {
    String suggestionText = suggestionController.text.trim();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString(); // HOUSEOWNER_id

    try {
      final response = await http.post(
        Uri.parse('$url/user_send_suggestion/'), // matches Django view name
        body: {
          'suggestions': suggestionText,
          'lid': lid,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          Fluttertoast.showToast(msg: 'Suggestion submitted successfully');
          suggestionController.clear();
          _loadSuggestions(); // refresh list after sending
        } else {
          Fluttertoast.showToast(
              msg: 'Submission failed: ${responseData['status']}');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  /// Function to fetch user suggestions
  Future<void> _loadSuggestions() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    try {
      final response = await http.post(
        Uri.parse('$url/user_view_suggestions/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            suggestions =
            List<Map<String, dynamic>>.from(responseData['data']);
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error loading suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1), // light teal background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Send Suggestion Form Card ---
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Send Suggestion",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: suggestionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Your Suggestion',
                              hintText: 'Type your suggestion here...',
                              labelStyle: const TextStyle(fontSize: 18),
                              hintStyle: const TextStyle(fontSize: 16),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              errorStyle: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your suggestion";
                              }
                              if (value.trim().length < 4) {
                                return "Suggestion must be at least 4 characters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(15))),
                              icon: const Icon(Icons.send, size: 24),
                              label: const Text('Submit Suggestion'),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _sendSuggestion();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Suggestions List ---
            suggestions.isEmpty
                ? const Center(
              child: Text(
                "No suggestions yet.",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final s = suggestions[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Suggestion Text
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb,
                                color: Colors.teal, size: 26),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s['suggestions'],
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Date
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "Date: ${s['date']}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
