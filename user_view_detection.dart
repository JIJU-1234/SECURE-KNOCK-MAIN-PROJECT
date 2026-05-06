


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ViewDetectionPage extends StatefulWidget {
  const ViewDetectionPage({super.key});

  @override
  State<ViewDetectionPage> createState() => _ViewDetectionPageState();
}

class _ViewDetectionPageState extends State<ViewDetectionPage> {
  List<Map<String, dynamic>> detections = [];
  String imgBaseUrl = '';
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredDetections = [];

  @override
  void initState() {
    super.initState();
    getImgBaseUrl().then((_) => fetchDetections());
    searchController.addListener(() {
      filterDetections(searchController.text);
    });
  }

  Future<void> getImgBaseUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    imgBaseUrl = sh.getString('img_url') ?? '';
    if (imgBaseUrl.endsWith('/')) {
      imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);
    }
  }

  Future<void> fetchDetections() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      if (urls.endsWith('/')) {
        urls = urls.substring(0, urls.length - 1);
      }

      var response = await http.get(Uri.parse('$urls/view_criminal_detections/'));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          String fullImgUrl = item['image'] != ''
              ? (item['image'].startsWith('/')
              ? '$imgBaseUrl${item['image']}'
              : '$imgBaseUrl/${item['image']}')
              : '';

          tempList.add({
            'id': item['id'],
            'image': fullImgUrl,
            'date': item['date'],
            'criminal_name': item['criminal_name'],
            'houseowner_name': item['houseowner_name'],
          });
        }

        setState(() {
          detections = tempList;
          filteredDetections = tempList;
        });
      }
    } catch (e) {
      print("Error fetching detections: $e");
    }
  }

  void filterDetections(String value) {
    setState(() {
      filteredDetections = detections
          .where((d) =>
      d['criminal_name'].toLowerCase().contains(value.toLowerCase()) ||
          d['houseowner_name']
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ✅ Light teal gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ AppBar with Back Arrow + Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // 🔙 Back Arrow
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Search by Criminal or Houseowner',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ✅ Beautiful Detection Cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filteredDetections.length,
                  itemBuilder: (context, index) {
                    final d = filteredDetections[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      elevation: 8,
                      shadowColor: Colors.teal.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFE0F7FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 👤 Larger Image with rounded corners
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: d['image'] != ''
                                    ? Image.network(
                                  d['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                    : const Icon(Icons.image_not_supported,
                                    size: 80, color: Colors.grey),
                              ),
                              const SizedBox(width: 18),
                              // 📝 Text Content with spacing and larger font
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d['criminal_name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Houseowner: ${d['houseowner_name']}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Date: ${d['date']}",
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


