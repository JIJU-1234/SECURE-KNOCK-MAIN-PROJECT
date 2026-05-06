// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'home.dart';
//
// void main() {
//   runApp(const ViewFamiliarPersonApp());
// }
//
// class ViewFamiliarPersonApp extends StatelessWidget {
//   const ViewFamiliarPersonApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: ViewFamiliarPersonPage(title: 'View Familiar Persons'),
//     );
//   }
// }
//
// class ViewFamiliarPersonPage extends StatefulWidget {
//   const ViewFamiliarPersonPage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<ViewFamiliarPersonPage> createState() => _ViewFamiliarPersonPageState();
// }
//
// class _ViewFamiliarPersonPageState extends State<ViewFamiliarPersonPage> {
//   List<Map<String, dynamic>> familiarPersons = [];
//   List<Map<String, dynamic>> filteredPersons = [];
//   TextEditingController searchController = TextEditingController();
//   String imgBaseUrl = '';
//
//   @override
//   void initState() {
//     super.initState();
//     getImgBaseUrl().then((_) => viewFamiliarPersons(""));
//     searchController.addListener(() {
//       filterPersons(searchController.text);
//     });
//   }
//
//   Future<void> getImgBaseUrl() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     imgBaseUrl = sh.getString('img_url') ?? '';
//     if (imgBaseUrl.endsWith('/')) imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);
//   }
//
//   Future<void> viewFamiliarPersons(String searchValue) async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       if (urls.endsWith('/')) urls = urls.substring(0, urls.length - 1);
//       String apiUrl = '$urls/view_familiar_person/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           String photoPath = item['photo'] ?? '';
//           String fullPhotoUrl = '';
//           if (photoPath != '') {
//             fullPhotoUrl = photoPath.startsWith('/') ? '$imgBaseUrl$photoPath' : '$imgBaseUrl/$photoPath';
//           }
//
//           tempList.add({
//             'id': item['id'].toString(),
//             'name': item['name'].toString(),
//             'photo': fullPhotoUrl,
//             'gender': item['gender'].toString(),
//             'email': item['email'].toString(),
//             'phone': item['phone'].toString(),
//             'place': item['place'].toString(),
//             'post': item['post'].toString(),
//             'pin': item['pin'].toString(),
//             'district': item['district'].toString(),
//             'state': item['state'].toString(),
//             'relation': item['relation'].toString(),
//           });
//         }
//         setState(() {
//           familiarPersons = tempList;
//           filteredPersons = tempList;
//         });
//       }
//     } catch (e) {
//       print("Error fetching familiar persons: $e");
//     }
//   }
//
//   void filterPersons(String value) {
//     setState(() {
//       filteredPersons = familiarPersons
//           .where((c) =>
//       c['name'].toLowerCase().contains(value.toLowerCase()) ||
//           c['place'].toLowerCase().contains(value.toLowerCase()) ||
//           c['district'].toLowerCase().contains(value.toLowerCase()))
//           .toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const BankingDashboard()),
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 232, 177, 61),
//           title: TextField(
//             controller: searchController,
//             decoration: const InputDecoration(
//               hintText: 'Search...',
//               border: InputBorder.none,
//               hintStyle: TextStyle(color: Colors.white70),
//             ),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         body: ListView.builder(
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           itemCount: filteredPersons.length,
//           itemBuilder: (context, index) {
//             final c = filteredPersons[index];
//             return Card(
//               margin: const EdgeInsets.all(10),
//               elevation: 5,
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(10),
//                 leading: c['photo'] != ''
//                     ? Image.network(
//                   c['photo'],
//                   width: 70,
//                   height: 70,
//                   fit: BoxFit.cover,
//                 )
//                     : const Icon(Icons.person, size: 50),
//                 title: Text(
//                   c['name'],
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Gender: ${c['gender']}"),
//                     Text("Email: ${c['email']}"),
//                     Text("Phone: ${c['phone']}"),
//                     Text("Place: ${c['place']}"),
//                     Text("Post: ${c['post']}"),
//                     Text("PIN: ${c['pin']}"),
//                     Text("District: ${c['district']}"),
//                     Text("State: ${c['state']}"),
//                     Text("Relation: ${c['relation']}"),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:secure_knock/edit_familiar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';
//
// import 'home.dart';
//
// class ViewFamiliarPersonApp extends StatelessWidget {
//   const ViewFamiliarPersonApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: ViewFamiliarPersonPage(title: 'View Familiar Persons'),
//     );
//   }
// }
//
// class ViewFamiliarPersonPage extends StatefulWidget {
//   const ViewFamiliarPersonPage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<ViewFamiliarPersonPage> createState() => _ViewFamiliarPersonPageState();
// }
//
// class _ViewFamiliarPersonPageState extends State<ViewFamiliarPersonPage> {
//   List<Map<String, dynamic>> familiarPersons = [];
//   List<Map<String, dynamic>> filteredPersons = [];
//   TextEditingController searchController = TextEditingController();
//   String imgBaseUrl = '';
//
//   @override
//   void initState() {
//     super.initState();
//     getImgBaseUrl().then((_) => viewFamiliarPersons(""));
//     searchController.addListener(() {
//       filterPersons(searchController.text);
//     });
//   }
//
//   Future<void> getImgBaseUrl() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     imgBaseUrl = sh.getString('img_url') ?? '';
//     if (imgBaseUrl.endsWith('/')) imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);
//   }
//
//   Future<void> viewFamiliarPersons(String searchValue) async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       if (urls.endsWith('/')) urls = urls.substring(0, urls.length - 1);
//       String apiUrl = '$urls/view_familiar_person/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           String photoPath = item['photo'] ?? '';
//           String fullPhotoUrl = '';
//           if (photoPath != '') {
//             fullPhotoUrl = photoPath.startsWith('/') ? '$imgBaseUrl$photoPath' : '$imgBaseUrl/$photoPath';
//           }
//
//           tempList.add({
//             'id': item['id'].toString(),
//             'name': item['name'].toString(),
//             'photo': fullPhotoUrl,
//             'gender': item['gender'].toString(),
//             'email': item['email'].toString(),
//             'phone': item['phone'].toString(),
//             'place': item['place'].toString(),
//             'post': item['post'].toString(),
//             'pin': item['pin'].toString(),
//             'district': item['district'].toString(),
//             'state': item['state'].toString(),
//             'relation': item['relation'].toString(),
//           });
//         }
//         setState(() {
//           familiarPersons = tempList;
//           filteredPersons = tempList;
//         });
//       }
//     } catch (e) {
//       print("Error fetching familiar persons: $e");
//     }
//   }
//
//   void filterPersons(String value) {
//     setState(() {
//       filteredPersons = familiarPersons
//           .where((c) =>
//       c['name'].toLowerCase().contains(value.toLowerCase()) ||
//           c['place'].toLowerCase().contains(value.toLowerCase()) ||
//           c['district'].toLowerCase().contains(value.toLowerCase()))
//           .toList();
//     });
//   }
//
//   Future<void> deleteFamiliarPerson(String id) async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       if (urls.endsWith('/')) urls = urls.substring(0, urls.length - 1);
//       String apiUrl = '$urls/delete_familiar_person/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {'id': id});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         Fluttertoast.showToast(msg: "Deleted successfully");
//         viewFamiliarPersons("");
//       } else {
//         Fluttertoast.showToast(msg: "Delete failed");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const BankingDashboard()),
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 232, 177, 61),
//           title: TextField(
//             controller: searchController,
//             decoration: const InputDecoration(
//               hintText: 'Search...',
//               border: InputBorder.none,
//               hintStyle: TextStyle(color: Colors.white70),
//             ),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         body: ListView.builder(
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           itemCount: filteredPersons.length,
//           itemBuilder: (context, index) {
//             final c = filteredPersons[index];
//             return Card(
//               margin: const EdgeInsets.all(10),
//               elevation: 5,
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(10),
//                 leading: c['photo'] != ''
//                     ? Image.network(
//                   c['photo'],
//                   width: 70,
//                   height: 70,
//                   fit: BoxFit.cover,
//                 )
//                     : const Icon(Icons.person, size: 50),
//                 title: Text(
//                   c['name'],
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Gender: ${c['gender']}"),
//                     Text("Email: ${c['email']}"),
//                     Text("Phone: ${c['phone']}"),
//                     Text("Place: ${c['place']}"),
//                     Text("Post: ${c['post']}"),
//                     Text("PIN: ${c['pin']}"),
//                     Text("District: ${c['district']}"),
//                     Text("State: ${c['state']}"),
//                     Text("Relation: ${c['relation']}"),
//                   ],
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EditFamiliarPersonPage(
//                               familiarPerson: c,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         deleteFamiliarPerson(c['id']);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }





// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:secure_knock/edit_familiar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';
//
// import 'home.dart';
//
// class ViewFamiliarPersonApp extends StatelessWidget {
//   const ViewFamiliarPersonApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: ViewFamiliarPersonPage(title: 'View Familiar Persons'),
//     );
//   }
// }
//
// class ViewFamiliarPersonPage extends StatefulWidget {
//   const ViewFamiliarPersonPage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<ViewFamiliarPersonPage> createState() => _ViewFamiliarPersonPageState();
// }
//
// class _ViewFamiliarPersonPageState extends State<ViewFamiliarPersonPage> {
//   List<Map<String, dynamic>> familiarPersons = [];
//   List<Map<String, dynamic>> filteredPersons = [];
//   TextEditingController searchController = TextEditingController();
//   String imgBaseUrl = '';
//
//   @override
//   void initState() {
//     super.initState();
//     getImgBaseUrl().then((_) => viewFamiliarPersons(""));
//     searchController.addListener(() {
//       filterPersons(searchController.text);
//     });
//   }
//
//   Future<void> getImgBaseUrl() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     imgBaseUrl = sh.getString('img_url') ?? '';
//     if (imgBaseUrl.endsWith('/')) imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);
//   }
//
//   Future<void> viewFamiliarPersons(String searchValue) async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       if (urls.endsWith('/')) urls = urls.substring(0, urls.length - 1);
//       String apiUrl = '$urls/view_familiar_person/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           String photoPath = item['photo'] ?? '';
//           String fullPhotoUrl = '';
//           if (photoPath != '') {
//             fullPhotoUrl = photoPath.startsWith('/') ? '$imgBaseUrl$photoPath' : '$imgBaseUrl/$photoPath';
//           }
//
//           tempList.add({
//             'id': item['id'].toString(),
//             'name': item['name'].toString(),
//             'photo': fullPhotoUrl,
//             'gender': item['gender'].toString(),
//             'email': item['email'].toString(),
//             'phone': item['phone'].toString(),
//             'place': item['place'].toString(),
//             'post': item['post'].toString(),
//             'pin': item['pin'].toString(),
//             'district': item['district'].toString(),
//             'state': item['state'].toString(),
//             'relation': item['relation'].toString(),
//           });
//         }
//         setState(() {
//           familiarPersons = tempList;
//           filteredPersons = tempList;
//         });
//       }
//     } catch (e) {
//       print("Error fetching familiar persons: $e");
//     }
//   }
//
//   void filterPersons(String value) {
//     setState(() {
//       filteredPersons = familiarPersons
//           .where((c) =>
//       c['name'].toLowerCase().contains(value.toLowerCase()) ||
//           c['place'].toLowerCase().contains(value.toLowerCase()) ||
//           c['district'].toLowerCase().contains(value.toLowerCase()))
//           .toList();
//     });
//   }
//
//   Future<void> deleteFamiliarPerson(String id) async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       if (urls.endsWith('/')) urls = urls.substring(0, urls.length - 1);
//       String apiUrl = '$urls/delete_familiar_person/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {'id': id});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         Fluttertoast.showToast(msg: "Deleted successfully");
//         viewFamiliarPersons(""); // Refresh list after delete
//       } else {
//         Fluttertoast.showToast(msg: "Delete failed");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const BankingDashboard()),
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 232, 177, 61),
//           title: TextField(
//             controller: searchController,
//             decoration: const InputDecoration(
//               hintText: 'Search...',
//               border: InputBorder.none,
//               hintStyle: TextStyle(color: Colors.white70),
//             ),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         body: ListView.builder(
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           itemCount: filteredPersons.length,
//           itemBuilder: (context, index) {
//             final c = filteredPersons[index];
//             return Card(
//               margin: const EdgeInsets.all(10),
//               elevation: 5,
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(10),
//                 leading: c['photo'] != ''
//                     ? Image.network(
//                   c['photo'],
//                   width: 70,
//                   height: 70,
//                   fit: BoxFit.cover,
//                 )
//                     : const Icon(Icons.person, size: 50),
//                 title: Text(
//                   c['name'],
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Gender: ${c['gender']}"),
//                     Text("Email: ${c['email']}"),
//                     Text("Phone: ${c['phone']}"),
//                     Text("Place: ${c['place']}"),
//                     Text("Post: ${c['post']}"),
//                     Text("PIN: ${c['pin']}"),
//                     Text("District: ${c['district']}"),
//                     Text("State: ${c['state']}"),
//                     Text("Relation: ${c['relation']}"),
//                   ],
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () async {
//                         bool? updated = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EditFamiliarPersonPage(
//                               familiarPerson: c,
//                             ),
//                           ),
//                         );
//                         if (updated == true) {
//                           viewFamiliarPersons(""); // refresh after edit
//                         }
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         deleteFamiliarPerson(c['id']);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:secure_knock/edit_familiar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'home.dart';

class ViewFamiliarPersonApp extends StatelessWidget {
  const ViewFamiliarPersonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ViewFamiliarPersonPage(title: 'View Familiar Persons'),
    );
  }
}

class ViewFamiliarPersonPage extends StatefulWidget {
  const ViewFamiliarPersonPage({super.key, required this.title});
  final String title;

  @override
  State<ViewFamiliarPersonPage> createState() =>
      _ViewFamiliarPersonPageState();
}

class _ViewFamiliarPersonPageState extends State<ViewFamiliarPersonPage> {
  List<Map<String, dynamic>> familiarPersons = [];
  List<Map<String, dynamic>> filteredPersons = [];
  TextEditingController searchController = TextEditingController();
  String imgBaseUrl = '';

  @override
  void initState() {
    super.initState();
    getImgBaseUrl().then((_) => viewFamiliarPersons(""));
    searchController.addListener(() {
      filterPersons(searchController.text);
    });
  }

  Future<void> getImgBaseUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    imgBaseUrl = sh.getString('img_url') ?? '';
    if (imgBaseUrl.endsWith('/')) imgBaseUrl = imgBaseUrl.substring(0, imgBaseUrl.length - 1);
  }

  Future<void> viewFamiliarPersons(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      if (urls.endsWith('/')) urls = urls.substring(0, urls.length - 1);
      String apiUrl = '$urls/view_familiar_person/';

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
            'gender': item['gender'].toString(),
            'email': item['email'].toString(),
            'phone': item['phone'].toString(),
            'place': item['place'].toString(),
            'post': item['post'].toString(),
            'pin': item['pin'].toString(),
            'district': item['district'].toString(),
            'state': item['state'].toString(),
            'relation': item['relation'].toString(),
          });
        }
        setState(() {
          familiarPersons = tempList;
          filteredPersons = tempList;
        });
      }
    } catch (e) {
      print("Error fetching familiar persons: $e");
    }
  }

  void filterPersons(String value) {
    setState(() {
      filteredPersons = familiarPersons
          .where((c) =>
      c['name'].toLowerCase().contains(value.toLowerCase()) ||
          c['place'].toLowerCase().contains(value.toLowerCase()) ||
          c['district'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteFamiliarPerson(String id) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      if (urls.endsWith('/')) urls = urls.substring(0, urls.length - 1);
      String apiUrl = '$urls/delete_familiar_person/';

      var response = await http.post(Uri.parse(apiUrl), body: {'fid': id});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Deleted successfully");
        viewFamiliarPersons(""); // Refresh list after delete
      } else {
        Fluttertoast.showToast(msg: "Delete failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Widget buildCard(Map<String, dynamic> c) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: c['photo'] != ''
                  ? Image.network(
                c['photo'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 80,
                height: 80,
                color: Colors.teal.shade100,
                child: const Icon(Icons.person, size: 40, color: Colors.teal),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal),
                  ),
                  const SizedBox(height: 8),
                  infoRow("Gender", c['gender']),
                  infoRow("Email", c['email']),
                  infoRow("Phone", c['phone']),
                  infoRow("Place", c['place']),
                  infoRow("Post", c['post']),
                  infoRow("PIN", c['pin']),
                  infoRow("District", c['district']),
                  infoRow("State", c['state']),
                  infoRow("Relation", c['relation']),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateFamiliarPerson(
                           title: '',
                        ),
                      ),
                    );
                    if (updated == true) {
                      viewFamiliarPersons(""); // refresh after edit
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(50, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Icon(Icons.edit, size: 20),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    deleteFamiliarPerson(c['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(50, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Icon(Icons.delete, size: 20),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
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
        backgroundColor: Colors.teal.shade50,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search by name/place/district...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: filteredPersons.isEmpty
            ? const Center(
          child: Text(
            "No familiar persons found",
            style: TextStyle(fontSize: 18, color: Colors.teal),
          ),
        )
            : ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: filteredPersons.length,
          itemBuilder: (context, index) {
            final c = filteredPersons[index];
            return buildCard(c);
          },
        ),
      ),
    );
  }
}
