import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final String userEmail;

  const ProfilePage({super.key, required this.userEmail});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool _isEditing = false;
  DatabaseReference? _dbRef;
  String? _userKey;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.ref("patients");
    _fetchUserData();
  }

  void _fetchUserData() async {
    DatabaseEvent event = await _dbRef!.once();
    Map<dynamic, dynamic>? users =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (users != null) {
      users.forEach((key, value) {
        if (value['email'] == widget.userEmail) {
          setState(() {
            _userKey = key;
            _nameController.text = value['name'] ?? '';
            _emailController.text = value['email'] ?? '';
            _addressController.text = value['address'] ?? '';
            _phoneController.text = value['phone'] ?? '';
            _idController.text = value['id'] ?? '';
            _insuranceController.text = value['insurance'] ?? '';
            _heightController.text = value['height'] ?? '';
            _weightController.text = value['weight'] ?? '';
          });
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      print("Picked Image Path: ${pickedFile.path}"); // Debugging log
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _saveUserData() async {
    if (_dbRef == null || _userKey == null) return;
    await _dbRef!.child(_userKey!).update({
      "name": _nameController.text,
      "email": _emailController.text,
      "address": _addressController.text,
      "phone": _phoneController.text,
      "id": _idController.text,
      "insurance": _insuranceController.text,
      "height": _heightController.text,
      "weight": _weightController.text,
    });
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profile updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isEditing) {
                _saveUserData();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purple.shade100,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child:
                      _profileImage == null
                          ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Name", _nameController),
              _buildTextField("Email", _emailController, enabled: false),
              _buildTextField("Address", _addressController),
              _buildTextField("Phone", _phoneController),
              _buildTextField("ID Number", _idController),
              _buildTextField("Insurance", _insuranceController),
              _buildTextField("Height", _heightController),
              _buildTextField("Weight", _weightController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isEditing ? _saveUserData : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing ? Colors.blue : Colors.grey,
                ),
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled && _isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
