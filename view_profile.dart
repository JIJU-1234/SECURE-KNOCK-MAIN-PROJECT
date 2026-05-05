
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:secure_knock/user_update_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

void main() {
  runApp(const ViewUserProfileApp());
}

class ViewUserProfileApp extends StatelessWidget {
  const ViewUserProfileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ViewUserProfilePage(title: 'User Profile'),
    );
  }
}

class ViewUserProfilePage extends StatefulWidget {
  const ViewUserProfilePage({super.key, required this.title});
  final String title;

  @override
  State<ViewUserProfilePage> createState() => _ViewUserProfilePageState();
}

class _ViewUserProfilePageState extends State<ViewUserProfilePage> {
  Map<String, dynamic>? userProfile;
  String imgBaseUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String apiUrlBase = sh.getString('url') ?? '';
      imgBaseUrl = sh.getString('img_url') ?? '';

      if (apiUrlBase.endsWith('/')) {
        apiUrlBase = apiUrlBase.substring(0, apiUrlBase.length - 1);
      }
      if (imgBaseUrl.endsWith('/')) {
        imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);
      }

      String? lid = sh.getString('lid');
      if (lid == null || lid.isEmpty) return;

      String apiUrl = '$apiUrlBase/user_view_profile/';
      var response = await http.post(Uri.parse(apiUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        String photoPath = jsonData['photo'] ?? '';
        String fullPhotoUrl = '';
        if (photoPath != '') {
          fullPhotoUrl =
          photoPath.startsWith('/') ? '$imgBaseUrl$photoPath' : '$imgBaseUrl/$photoPath';
        }

        setState(() {
          userProfile = {
            'name': jsonData['name'].toString(),
            'email': jsonData['email'].toString(),
            'phone': jsonData['phone'].toString(),
            'place': jsonData['place'].toString(),
            'housename': jsonData['housename'].toString(),
            'pin': jsonData['pin'].toString(),
            'state': jsonData['state'].toString(),
            'district': jsonData['district'].toString(),
            'photo': fullPhotoUrl,
            'id': jsonData['id'].toString(),
          };
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BankingDashboard()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text("User Profile"),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB2DFDB), Color(0xFFE0F2F1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: userProfile == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadowColor: Colors.teal.withOpacity(0.5),
                    child: Container(
                      width: double.infinity,
                      // 🔹 Increased height for better layout balance
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Image Inside Card
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: userProfile!['photo'] != ''
                                ? NetworkImage(userProfile!['photo'])
                                : null,
                            child: userProfile!['photo'] == ''
                                ? const Icon(Icons.person, size: 70, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Profile Details
                          _buildDetailRow("Name", userProfile!['name']),
                          _buildDetailRow("Email", userProfile!['email']),
                          _buildDetailRow("Phone", userProfile!['phone']),
                          _buildDetailRow("Place", userProfile!['place']),
                          _buildDetailRow("House Name", userProfile!['housename']),
                          _buildDetailRow("PIN", userProfile!['pin']),
                          _buildDetailRow("State", userProfile!['state']),
                          _buildDetailRow("District", userProfile!['district']),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const UpdateHouseownerProfile(title: "Edit Profile"),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 22),
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 19),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
