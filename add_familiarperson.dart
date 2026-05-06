import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_knock/home.dart';
import 'package:secure_knock/user_view_familiarperson.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

// Import BankingDashboard page

class AddFamiliarPersonPage extends StatefulWidget {
  const AddFamiliarPersonPage({Key? key}) : super(key: key);

  @override
  State<AddFamiliarPersonPage> createState() => _AddFamiliarPersonPageState();
}

class _AddFamiliarPersonPageState extends State<AddFamiliarPersonPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  File? _image;
  String _selectedGender = ""; // Male or Female
  bool showGenderError = false; // flag to show gender error only on submit

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final ext = p.extension(picked.path).toLowerCase();
      if (ext == ".jpg" || ext == ".jpeg" || ext == ".png") {
        setState(() {
          _image = File(picked.path);
        });
      } else {
        Fluttertoast.showToast(msg: "Only image files allowed (jpg, jpeg, png)");
      }
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fill all fields correctly");
      return;
    }

    if (_image == null) {
      Fluttertoast.showToast(msg: "Please select a photo");
      return;
    }

    if (_selectedGender.isEmpty) {
      setState(() {
        showGenderError = true; // show error only on submit
      });
      Fluttertoast.showToast(msg: "Please select gender");
      return;
    } else {
      showGenderError = false;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? baseUrl = sh.getString('url');
    String? lid = sh.getString('lid');

    if (baseUrl == null || lid == null) {
      Fluttertoast.showToast(msg: "Missing server URL or user ID");
      return;
    }

    final uri = Uri.parse('$baseUrl/add_familiarperson/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['lid'] = lid;
    request.fields['names'] = _nameController.text.trim();
    request.fields['gender'] = _selectedGender;
    request.fields['email'] = _emailController.text.trim();
    request.fields['phone'] = _phoneController.text.trim();
    request.fields['place'] = _placeController.text.trim();
    request.fields['post'] = _postController.text.trim();
    request.fields['pin'] = _pinController.text.trim();
    request.fields['district'] = _districtController.text.trim();
    request.fields['state'] = _stateController.text.trim();
    request.fields['relation'] = _relationController.text.trim();

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        _image!.path,
        filename: p.basename(_image!.path),
      ),
    );

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Familiar person added successfully");
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "Failed to add familiar person");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  InputDecoration tealInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.teal),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    );
  }

  Widget genderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        if (showGenderError)
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 4),
            child: Text(
              "Gender is required",
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = "Male";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedGender == "Male"
                        ? Colors.teal.shade50
                        : Colors.white,
                    border: Border.all(color: Colors.teal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: "Male",
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        activeColor: Colors.teal,
                      ),
                      const SizedBox(width: 8),
                      const Text("Male", style: TextStyle(color: Colors.teal)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = "Female";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedGender == "Female"
                        ? Colors.teal.shade50
                        : Colors.white,
                    border: Border.all(color: Colors.teal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: "Female",
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        activeColor: Colors.teal,
                      ),
                      const SizedBox(width: 8),
                      const Text("Female", style: TextStyle(color: Colors.teal)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Add Familiar Person"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to BankingDashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BankingDashboard(),
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        const Text(
                          "Add Familiar Person",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                        const SizedBox(height: 20),

                        // Image Picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.teal.shade50,
                            backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? const Icon(Icons.add_a_photo,
                                size: 40, color: Colors.teal)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name Validation
                        TextFormField(
                          controller: _nameController,
                          decoration: tealInputDecoration("Name"),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Name is required";
                            } else if (!RegExp(r'^[A-Z][a-zA-Z\s]*$').hasMatch(val)) {
                              return "Name must start with a capital letter and contain only letters";
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 15),

                        // Gender
                        genderSelection(),
                        const SizedBox(height: 15),

                        // Other Fields
                        ...[
                          {"controller": _emailController, "label": "Email"},
                          {"controller": _phoneController, "label": "Phone"},
                          {"controller": _placeController, "label": "Place"},
                          {"controller": _postController, "label": "Post"},
                          {"controller": _pinController, "label": "PIN"},
                          {"controller": _districtController, "label": "District"},
                          {"controller": _stateController, "label": "State"},
                          {"controller": _relationController, "label": "Relation"},
                        ].map((field) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TextFormField(
                              controller: field['controller'] as TextEditingController,
                              decoration: tealInputDecoration(
                                  field['label'] as String),
                              keyboardType: field['label'] == "Email"
                                  ? TextInputType.emailAddress
                                  : field['label'] == "Phone"
                                  ? TextInputType.phone
                                  : TextInputType.text,
                              validator: (val) {
                                if (val == null || val.isEmpty) return "Required";

                                if (field['label'] == "Email" &&
                                    !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                        .hasMatch(val)) {
                                  return "Enter valid email";
                                }
                                if (field['label'] == "Phone" &&
                                    !RegExp(r'^[0-9]{10}$').hasMatch(val)) {
                                  return "Enter 10-digit phone";
                                }
                                if (field['label'] == "PIN" &&
                                    !RegExp(r'^[0-9]{6}$').hasMatch(val)) {
                                  return "PIN must be 6 digits";
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 20),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submitData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text("Submit",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const ViewFamiliarPersonPage(title: ''),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text("View",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
