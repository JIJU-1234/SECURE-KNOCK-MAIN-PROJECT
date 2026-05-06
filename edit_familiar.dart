






import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_knock/add_familiarperson.dart';
import 'package:secure_knock/user_view_familiarperson.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const UpdateFamiliarPerson(title: 'Edit Familiar Person'));
}

class UpdateFamiliarPerson extends StatefulWidget {
  final String title;

  const UpdateFamiliarPerson({super.key, required this.title});

  @override
  State<UpdateFamiliarPerson> createState() => _UpdateFamiliarPersonState();
}

class _UpdateFamiliarPersonState extends State<UpdateFamiliarPerson> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? familiarPerson;
  String imgBaseUrl = '';
  String selectedGender = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  File? _selectedImage;
  String photoUrl = "";

  @override
  void initState() {
    super.initState();
    _getData();
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

  Future<void> _getData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');
    String? img_url = sh.getString('img_url');

    if (url == null || lid == null || img_url == null) return;

    try {
      final response =
      await http.post(Uri.parse('$url/view_familiar_person/'), body: {
        'lid': lid,
      });

      if (response.statusCode == 200) {
        var resData = jsonDecode(response.body);
        if (resData['status'] == 'ok') {
          var data = resData['data'][0];
          setState(() {
            familiarPerson = data;
            _nameController.text = data['name'];
            _emailController.text = data['email'];
            _phoneController.text = data['phone'];
            _placeController.text = data['place'];
            _postController.text = data['post'];
            _pinController.text = data['pin'];
            _districtController.text = data['district'];
            _stateController.text = data['state'];
            _relationController.text = data['relation'];
            selectedGender = data['gender'];
            photoUrl = img_url + data['photo'];
          });
        } else {
          Fluttertoast.showToast(msg: 'No data found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fill all required fields");
      return;
    }

    if (selectedGender.isEmpty) {
      Fluttertoast.showToast(msg: "Please select gender");
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null || lid == null) return;

    final uri = Uri.parse('$url/update_familiarperson/');
    var request = http.MultipartRequest('POST', uri);

    request.fields['lid'] = lid;
    request.fields['names'] = _nameController.text.trim();
    request.fields['gender'] = selectedGender;
    request.fields['email'] = _emailController.text.trim();
    request.fields['phone'] = _phoneController.text.trim();
    request.fields['place'] = _placeController.text.trim();
    request.fields['post'] = _postController.text.trim();
    request.fields['pin'] = _pinController.text.trim();
    request.fields['district'] = _districtController.text.trim();
    request.fields['state'] = _stateController.text.trim();
    request.fields['relation'] = _relationController.text.trim();

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        _selectedImage!.path,
      ));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Updated successfully");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ViewFamiliarPersonPage(title: '',)),
        );
      } else {
        Fluttertoast.showToast(msg: "Update failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType type = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
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
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Familiar Person"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2DFDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    // Image
                    GestureDetector(
                      onTap: _chooseImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.teal.shade50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl) as ImageProvider
                            : null,
                        child: _selectedImage == null && photoUrl.isEmpty
                            ? const Icon(Icons.add_a_photo,
                            size: 40, color: Colors.teal)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    _buildTextField(
                      _nameController,
                      "Enter Name",
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Required";
                        if (!RegExp(r'^[A-Z][a-zA-Z\s]*$')
                            .hasMatch(val.trim())) {
                          return "Must start with capital letter & only letters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Gender
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gender",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                        if (selectedGender.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 4),
                            child: Text(
                              "Gender is required",
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 12),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text("Male"),
                                value: "Male",
                                groupValue: selectedGender,
                                onChanged: (val) {
                                  setState(() {
                                    selectedGender = val!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text("Female"),
                                value: "Female",
                                groupValue: selectedGender,
                                onChanged: (val) {
                                  setState(() {
                                    selectedGender = val!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    _buildTextField(
                      _emailController,
                      "Enter Email",
                      type: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Required";
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(val.trim()))
                          return "Enter valid email";
                        return null;
                      },
                    ),
                    _buildTextField(
                      _phoneController,
                      "Enter Phone",
                      type: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Required";
                        if (!RegExp(r'^\d{10}$').hasMatch(val.trim()))
                          return "Enter 10-digit number";
                        return null;
                      },
                    ),
                    _buildTextField(
                      _placeController,
                      "Enter Place",
                    ),
                    _buildTextField(
                      _postController,
                      "Enter Post",
                    ),
                    _buildTextField(
                      _pinController,
                      "Enter PIN",
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Required";
                        if (!RegExp(r'^\d{6}$').hasMatch(val.trim()))
                          return "Enter 6-digit PIN";
                        return null;
                      },
                    ),
                    _buildTextField(_districtController, "Enter District"),
                    _buildTextField(_stateController, "Enter State"),
                    _buildTextField(_relationController, "Enter Relation"),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _sendData,
                        icon: const Icon(Icons.update),
                        label: const Text("Update"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
    );
  }
}

