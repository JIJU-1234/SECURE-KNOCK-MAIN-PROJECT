
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const UserComplaintApp());
}

class UserComplaintApp extends StatelessWidget {
  const UserComplaintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Complaints',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const UserComplaintPage(title: 'User Complaints'),
    );
  }
}

class UserComplaintPage extends StatefulWidget {
  const UserComplaintPage({super.key, required this.title});
  final String title;

  @override
  State<UserComplaintPage> createState() => _UserComplaintPageState();
}

class _UserComplaintPageState extends State<UserComplaintPage> {
  TextEditingController complaintController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1), // light teal background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Send Complaint Form Card ---
            Card(
              elevation: 8,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Send Complaint",
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
                            controller: complaintController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Your Complaint',
                              hintText: 'Type your complaint here...',
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
                              String? error;
                              if (value == null || value.trim().isEmpty) {
                                error = "Please enter your complaint";
                              } else {
                                List<String> errors = [];
                                if (value.trim().length < 4) {
                                  errors.add("must be at least 4 characters");
                                }
                                if (RegExp(r'^[0-9\s]+$').hasMatch(value.trim())) {
                                  errors.add("cannot contain only numbers");
                                }
                                if (errors.isNotEmpty) {
                                  error = errors.join(", ");
                                }
                              }
                              return error;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              icon: const Icon(Icons.send, size: 26),
                              label: const Text(
                                'Submit Complaint',
                                style: TextStyle(fontSize: 20),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _sendComplaint();
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

            // --- View Complaints Section (Redesigned) ---
            complaints.isEmpty
                ? const Center(
              child: Text(
                "No complaints yet.",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final c = complaints[index];
                Color statusColor = c['status']
                    .toString()
                    .toLowerCase() ==
                    'replied'
                    ? Colors.green
                    : Colors.orange;

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
                        // Complaint Text
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.description,
                                color: Colors.teal, size: 26),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c['complaint'],
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Date
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.grey, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              "Date: ${c['date']}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Reply (if available)
                        if (c['reply'] != null &&
                            c['reply'].toString().isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.reply,
                                    color: Colors.blue, size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Reply: ${c['reply']}",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info, color: statusColor, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Status: ${c['status']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
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

  // --- send complaint ---
  Future<void> _sendComplaint() async {
    String complaintText = complaintController.text.trim();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    try {
      final response = await http.post(
        Uri.parse('$url/user_send_complaint/'),
        body: {
          'complaint': complaintText,
          'lid': lid,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          Fluttertoast.showToast(msg: 'Complaint submitted successfully');
          complaintController.clear();
          _loadComplaints(); // refresh list
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

  // --- load complaints ---
  Future<void> _loadComplaints() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    try {
      final response = await http.get(
        Uri.parse('$url/user_view_complaints/?lid=$lid'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            complaints =
            List<Map<String, dynamic>>.from(responseData['complaints']);
          });
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error loading complaints: $e');
    }
  }
}

