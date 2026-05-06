
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

void main() {
  runApp(const ViewCriminalApp());
}

class ViewCriminalApp extends StatelessWidget {
  const ViewCriminalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ViewCriminalPage(title: 'View Criminals'),
    );
  }
}

class ViewCriminalPage extends StatefulWidget {
  const ViewCriminalPage({super.key, required this.title});
  final String title;

  @override
  State<ViewCriminalPage> createState() => _ViewCriminalPageState();
}

class _ViewCriminalPageState extends State<ViewCriminalPage> {
  List<Map<String, dynamic>> criminals = [];
  List<Map<String, dynamic>> filteredCriminals = [];
  TextEditingController searchController = TextEditingController();
  String imgBaseUrl = '';

  @override
  void initState() {
    super.initState();
    getImgBaseUrl().then((_) => viewCriminals(""));
    searchController.addListener(() {
      filterCriminals(searchController.text);
    });
  }

  Future<void> getImgBaseUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    imgBaseUrl = sh.getString('img_url') ?? '';
    if (imgBaseUrl.endsWith('/')) imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);
  }

  Future<void> viewCriminals(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      if (urls.endsWith('/')) urls = urls.substring(0, urls.length - 1);
      String apiUrl = '$urls/user_view_criminals/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          String photoPath = item['photo'] ?? '';
          String fullPhotoUrl = '';
          if (photoPath != '') {
            fullPhotoUrl = photoPath.startsWith('/') ? '$imgBaseUrl$photoPath' : '$imgBaseUrl/$photoPath';
          }

          tempList.add({
            'id': item['id'].toString(),
            'name': item['name'].toString(),
            'photo': fullPhotoUrl,
            'place': item['place'].toString(),
            'post': item['post'].toString(),
            'pin': item['pin'].toString(),
            'district': item['district'].toString(),
            'state': item['state'].toString(),
            'country': item['country'].toString(),
            'gender': item['gender'].toString(),
            'dob': item['dob'].toString(),
            'height': item['height'].toString(),
            'weight': item['weight'].toString(),
            'identification_mark': item['identification_mark'].toString(),
            'arrest_information': item['arrest_information'].toString(),
            'charges': item['charges'].toString(),
          });
        }
        setState(() {
          criminals = tempList;
          filteredCriminals = tempList;
        });
      }
    } catch (e) {
      print("Error fetching criminals: $e");
    }
  }

  void filterCriminals(String value) {
    setState(() {
      filteredCriminals = criminals
          .where((c) =>
      c['name'].toLowerCase().contains(value.toLowerCase()) ||
          c['place'].toLowerCase().contains(value.toLowerCase()) ||
          c['district'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name, place, or district...',
                hintStyle: TextStyle(color: Colors.black54),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.black54),
              ),
              style: const TextStyle(color: Colors.black87, fontSize: 18),
            ),
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
          child: filteredCriminals.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: const EdgeInsets.only(top: 100, bottom: 20),
            itemCount: filteredCriminals.length,
            itemBuilder: (context, index) {
              final c = filteredCriminals[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image with rounded corners & shadow
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(2, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: c['photo'] != ''
                                    ? Image.network(
                                  c['photo'],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                    : Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person, size: 60, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['name'],
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                  const SizedBox(height: 12),
                                  _infoRow(Icons.location_on, c['place']),
                                  const SizedBox(height: 8),
                                  _infoRow(Icons.map, c['district']),
                                  const SizedBox(height: 8),
                                  _infoRow(Icons.flag, c['state']),
                                  const SizedBox(height: 8),
                                  _infoRow(Icons.info_outline, "Charges: ${c['charges']}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _detailText("Gender: ${c['gender']}"),
                        const SizedBox(height: 6),
                        _detailText("DOB: ${c['dob']}"),
                        const SizedBox(height: 6),
                        _detailText("Height: ${c['height']} | Weight: ${c['weight']}"),
                        const SizedBox(height: 6),
                        _detailText("Identification Mark: ${c['identification_mark']}"),
                        const SizedBox(height: 6),
                        _detailText("Arrest Info: ${c['arrest_information']}"),
                        const SizedBox(height: 6),
                        _detailText("Post: ${c['post']} | PIN: ${c['pin']} | Country: ${c['country']}"),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _detailText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.bold),
    );
  }
}
