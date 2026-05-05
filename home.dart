

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:secure_knock/add_familiarperson.dart';
import 'package:secure_knock/user_change_password.dart';
import 'package:secure_knock/user_send_suggestions.dart';
import 'package:secure_knock/user_view_complaint.dart';
import 'package:secure_knock/user_view_criminals.dart';
import 'package:secure_knock/user_view_detection.dart';
import 'package:secure_knock/view_profile.dart';
import 'package:secure_knock/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class BankingDashboard extends StatefulWidget {
  const BankingDashboard({super.key});

  @override
  State<BankingDashboard> createState() => _BankingDashboardState();
}

class _BankingDashboardState extends State<BankingDashboard> {
  String userName = "User";
  String profileImageUrl = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String apiUrlBase = sh.getString('url') ?? '';
      String imgBaseUrl = sh.getString('img_url') ?? '';
      String? lid = sh.getString('lid');

      if (lid == null || lid.isEmpty) return;
      if (apiUrlBase.endsWith('/')) apiUrlBase = apiUrlBase.substring(0, apiUrlBase.length - 1);
      if (imgBaseUrl.endsWith('/')) imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);

      String apiUrl = '$apiUrlBase/user_view_profile/';
      var response = await http.post(Uri.parse(apiUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        String photoPath = jsonData['photo'] ?? '';
        String fullPhotoUrl = '';
        if (photoPath != '') {
          fullPhotoUrl = photoPath.startsWith('/') ? '$imgBaseUrl$photoPath' : '$imgBaseUrl/$photoPath';
        }

        setState(() {
          userName = jsonData['name'] ?? "User";
          profileImageUrl = fullPhotoUrl;
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save API URLs before clearing
    String? apiUrl = prefs.getString('url');
    String? imgUrl = prefs.getString('img_url');

    await prefs.clear();

    // Restore API URLs
    if (apiUrl != null) prefs.setString('url', apiUrl);
    if (imgUrl != null) prefs.setString('img_url', imgUrl);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyLoginPage(title: 'Login')),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomePage(),
      UserComplaintPage(title: 'Send Complaint'),
      SendSuggestionPage(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: Row(
            children: [
              const Icon(Icons.security, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              const Text(
                "Secure Knock",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: profileImageUrl != '' ? NetworkImage(profileImageUrl) : null,
                  child: profileImageUrl == '' ? Icon(Icons.person, color: Colors.teal, size: 28) : null,
                ),
                color: Colors.white,
                onSelected: (value) async {
                  if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewUserProfilePage(title: 'Profile'),
                      ),
                    );
                  } else if (value == 'logout') {
                    await handleLogout();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.teal),
                        SizedBox(width: 10),
                        Text('View Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Complaint'),
            BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Suggestion'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi $userName 👋',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        'What do you want to do today?',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.security, color: Colors.white, size: 50)
              ],
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: Lottie.asset(
              'assets/Welcome Animation.json',
              height: 180,
              repeat: true,
            ),
          ),
          const SizedBox(height: 25),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1,
            children: [
              buildActionCard('Criminals', Icons.report, Colors.redAccent, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewCriminalPage(title: '')));
              }),
              buildActionCard('Change Password', Icons.lock, Colors.teal, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkerChangePasswordPage()));
              }),
              buildActionCard('Criminal Detection', Icons.search, Colors.blue, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewDetectionPage()));
              }),
              buildActionCard('Add Familiar Person', Icons.group_add, Colors.purple, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFamiliarPersonPage()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 28,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

