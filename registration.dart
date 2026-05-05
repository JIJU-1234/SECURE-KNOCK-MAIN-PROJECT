


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

void main() {
  runApp(const MyAddUserPage(title: 'Add User'));
}

class MyAddUserPage extends StatefulWidget {
  const MyAddUserPage({super.key, required this.title});
  final String title;

  @override
  State<MyAddUserPage> createState() => _MyAddUserPageState();
}

class _MyAddUserPageState extends State<MyAddUserPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nametextController = TextEditingController();
  final TextEditingController _emailtextController = TextEditingController();
  final TextEditingController _phonenotextController = TextEditingController();
  final TextEditingController _placetextController = TextEditingController();
  final TextEditingController _housenametextController = TextEditingController();
  final TextEditingController _pintextController = TextEditingController();
  final TextEditingController _statetextController = TextEditingController();
  final TextEditingController _districttextController = TextEditingController();
  final TextEditingController _passwordtextController = TextEditingController();

  File? _selectedImage;

  // Map to hold live error messages
  Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _nametextController.addListener(() => _validateName(_nametextController.text));
    _emailtextController.addListener(() => _validateEmail(_emailtextController.text));
    _phonenotextController.addListener(() => _validatePhone(_phonenotextController.text));
    _placetextController.addListener(() => _validateRequired(_placetextController.text, "Place"));
    _housenametextController.addListener(() => _validateRequired(_housenametextController.text, "House Name"));
    _pintextController.addListener(() => _validatePin(_pintextController.text));
    _statetextController.addListener(() => _validateRequired(_statetextController.text, "State"));
    _districttextController.addListener(() => _validateRequired(_districttextController.text, "District"));
    _passwordtextController.addListener(() => _validatePassword(_passwordtextController.text));
  }

  Future<void> _chooseImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  void _validateName(String value) {
    if (value.isEmpty) {
      _errors['name'] = "Full Name is required";
    } else if (!RegExp(r"^[A-Z][a-zA-Z\s]*$").hasMatch(value)) {
      _errors['name'] = "Name must start with capital and contain letters only";
    } else {
      _errors['name'] = null;
    }
    setState(() {});
  }

  void _validateEmail(String value) {
    if (value.isEmpty) {
      _errors['email'] = "Email is required";
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      _errors['email'] = "Enter a valid email";
    } else {
      _errors['email'] = null;
    }
    setState(() {});
  }

  void _validatePhone(String value) {
    if (value.isEmpty) {
      _errors['phone'] = "Phone Number is required";
    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      _errors['phone'] = "Enter valid 10-digit phone number";
    } else {
      _errors['phone'] = null;
    }
    setState(() {});
  }

  void _validateRequired(String value, String field) {
    if (value.isEmpty) {
      _errors[field] = "$field is required";
    } else {
      _errors[field] = null;
    }
    setState(() {});
  }

  void _validatePin(String value) {
    if (value.isEmpty) {
      _errors['pin'] = "PIN Code is required";
    } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      _errors['pin'] = "PIN must be 6 digits";
    } else {
      _errors['pin'] = null;
    }
    setState(() {});
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      _errors['password'] = "Password is required";
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{6,}$').hasMatch(value)) {
      _errors['password'] = "Password must contain upper, lower, number, special, min 6 chars";
    } else {
      _errors['password'] = null;
    }
    setState(() {});
  }

  bool _allValid() {
    return _errors.values.every((e) => e == null) && _selectedImage != null;
  }

  Future<void> _sendData() async {
    if (!_allValid()) {
      Fluttertoast.showToast(msg: "Fix all errors before submitting");
      return;
    }

    String uname = _nametextController.text.trim();
    String uemail = _emailtextController.text.trim();
    String uphone = _phonenotextController.text.trim();
    String uplace = _placetextController.text.trim();
    String uhousename = _housenametextController.text.trim();
    String upin = _pintextController.text.trim();
    String ustate = _statetextController.text.trim();
    String udistrict = _districttextController.text.trim();
    String upassword = _passwordtextController.text.trim();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null || url.isEmpty) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/houseowners_registration/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['names'] = uname;
    request.fields['email'] = uemail;
    request.fields['phone'] = uphone;
    request.fields['place'] = uplace;
    request.fields['housename'] = uhousename;
    request.fields['pin'] = upin;
    request.fields['state'] = ustate;
    request.fields['district'] = udistrict;
    request.fields['password'] = upassword;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (respStr.isEmpty) {
        Fluttertoast.showToast(msg: "Empty server response");
        return;
      }

      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Submitted successfully.");
        // Navigate to login page after successful submission
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyLoginPage(title: 'Login')),
        );
      } else {
        Fluttertoast.showToast(msg: "Submission failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }

  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, TextInputType type = TextInputType.text, String? errorKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: type,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          if (errorKey != null && _errors[errorKey] != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 5),
              child: Text(
                _errors[errorKey]!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyLoginPage(title: '')),
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Add New User",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2575FC),
                        ),
                      ),
                      const SizedBox(height: 20),

                      InkWell(
                        onTap: _chooseImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: _selectedImage == null
                              ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                              : null,
                        ),
                      ),
                      if (_selectedImage == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text("Image is required", style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      const SizedBox(height: 20),

                      _buildTextField(_nametextController, "Full Name", errorKey: "name"),
                      _buildTextField(_emailtextController, "Email", type: TextInputType.emailAddress, errorKey: "email"),
                      _buildTextField(_phonenotextController, "Phone Number", type: TextInputType.phone, errorKey: "phone"),
                      _buildTextField(_placetextController, "Place", errorKey: "Place"),
                      _buildTextField(_housenametextController, "House Name", errorKey: "House Name"),
                      _buildTextField(_pintextController, "PIN Code", type: TextInputType.number, errorKey: "pin"),
                      _buildTextField(_statetextController, "State", errorKey: "State"),
                      _buildTextField(_districttextController, "District", errorKey: "District"),
                      _buildTextField(_passwordtextController, "Password", isPassword: true, errorKey: "password"),

                      const SizedBox(height: 25),

                      ElevatedButton.icon(
                        onPressed: _sendData,
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text("Submit", style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2575FC),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
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
    );
  }
}

