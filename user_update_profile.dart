
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_knock/view_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

void main() {
  runApp(const UpdateHouseownerProfile(title: ''));
}

class UpdateHouseownerProfile extends StatefulWidget {
  final dynamic title;

  const UpdateHouseownerProfile({super.key, required this.title});

  @override
  State<UpdateHouseownerProfile> createState() =>
      _UpdateHouseownerProfileState();
}

class _UpdateHouseownerProfileState extends State<UpdateHouseownerProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _UpdateHouseownerProfileState() {
    _get_data();
  }

  Map<String, dynamic>? userProfile;
  String imgBaseUrl = '';

  final TextEditingController _nametextController = TextEditingController();
  final TextEditingController _emailtextController = TextEditingController();
  final TextEditingController _phonenotextController = TextEditingController();
  final TextEditingController _placetextController = TextEditingController();
  final TextEditingController _housenametextController =
  TextEditingController();
  final TextEditingController _pintextController = TextEditingController();
  final TextEditingController _statetextController = TextEditingController();
  final TextEditingController _districttextController = TextEditingController();

  File? _selectedImage;
  String pic = "";

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

  void _get_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();
    String img_url = sh.getString('img_url').toString();

    final urls = Uri.parse('$url/user_view_profile/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String name = jsonDecode(response.body)['name'];
          String email = jsonDecode(response.body)['email'];
          String phone = jsonDecode(response.body)['phone'];
          String place = jsonDecode(response.body)['place'];
          String housename = jsonDecode(response.body)['housename'];
          String pin = jsonDecode(response.body)['pin'];
          String state = jsonDecode(response.body)['state'];
          String district = jsonDecode(response.body)['district'];
          String photo = img_url + jsonDecode(response.body)['photo'];

          _nametextController.text = name;
          _emailtextController.text = email;
          _phonenotextController.text = phone;
          _placetextController.text = place;
          _housenametextController.text = housename;
          _pintextController.text = pin;
          _statetextController.text = state;
          _districttextController.text = district;

          setState(() {
            pic = photo;
          });
        } else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ViewUserProfilePage(title: '')),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                shadowColor: Colors.teal.withOpacity(0.5),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                  child: Form(
                    key: _formKey,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction, // live validation
                    child: Column(
                      children: [
                        // Image
                        _selectedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            _selectedImage!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                            : (pic.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            pic,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Text("No Image Selected")),
                        const SizedBox(height: 10),

                        ElevatedButton.icon(
                          onPressed: _chooseImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Choose Image"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Form Fields with validators and onChanged for live validation
                        _buildTextField(
                          _nametextController,
                          'Enter Your Name',
                          type: TextInputType.name,
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Required";
                            }
                            final v = val.trim();
                            if (!RegExp(r'^[A-Z][a-zA-Z\s]*$').hasMatch(v)) {
                              return "Must start with capital letter & letters only";
                            }
                            return null;
                          },
                        ),

                        _buildTextField(
                          _emailtextController,
                          'Enter Your Email',
                          type: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Required";
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(val.trim())) {
                              return "Enter valid email";
                            }
                            return null;
                          },
                        ),

                        _buildTextField(
                          _phonenotextController,
                          'Enter Your Phone Number',
                          type: TextInputType.phone,
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Required";
                            if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) return "Enter 10-digit number";
                            return null;
                          },
                        ),

                        _buildTextField(
                          _placetextController,
                          'Enter Your Place',
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Required";
                            // allow letters, spaces, dots, hyphens
                            if (!RegExp(r'^[a-zA-Z\s\.-]+$').hasMatch(val.trim())) return "Only characters allowed";
                            return null;
                          },
                        ),

                        _buildTextField(
                          _housenametextController,
                          'Enter Your House Name',
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Required";
                            return null;
                          },
                        ),

                        _buildTextField(
                          _pintextController,
                          'Enter Your PIN',
                          type: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Required";
                            if (!RegExp(r'^\d{6}$').hasMatch(val.trim())) return "Enter 6-digit PIN";
                            return null;
                          },
                        ),

                        _buildTextField(
                          _statetextController,
                          'Enter Your State',
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Required";
                            return null;
                          },
                        ),

                        _buildTextField(
                          _districttextController,
                          'Enter Your District',
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return "Required";
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // final validation call
                              if (_formKey.currentState!.validate()) {
                                _sendData();
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please fix errors in the form");
                              }
                            },
                            icon: const Icon(Icons.update, size: 22),
                            label: const Text(
                              "Update",
                              style: TextStyle(fontSize: 18),
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

  // Reusable text field with live validation and design (validator and onChanged are optional)
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType type = TextInputType.text,
        void Function(String)? onChanged,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.teal, fontSize: 16),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        validator: validator ??
                (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }

  Future<void> _sendData() async {
    String uname = _nametextController.text.trim();
    String uemail = _emailtextController.text.trim();
    String uphone = _phonenotextController.text.trim();
    String uplace = _placetextController.text.trim();
    String uhousename = _housenametextController.text.trim();
    String upin = _pintextController.text.trim();
    String ustate = _statetextController.text.trim();
    String udistrict = _districttextController.text.trim();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null || url.isEmpty) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/update_houseowners_profile/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['names'] = uname;
    request.fields['email'] = uemail;
    request.fields['phone'] = uphone;
    request.fields['place'] = uplace;
    request.fields['housename'] = uhousename;
    request.fields['pin'] = upin;
    request.fields['state'] = ustate;
    request.fields['district'] = udistrict;
    request.fields['lid'] = lid.toString();

    if (_selectedImage != null) {
      request.files
          .add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
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
        Fluttertoast.showToast(msg: "Updated successfully.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ViewUserProfilePage(title: '')),
        );
      } else {
        Fluttertoast.showToast(msg: "Submission failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
