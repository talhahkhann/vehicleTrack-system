import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../main.dart';

class AddDataScreen extends StatefulWidget {
  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController monthlyController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  late DateTime selectedDate = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  String? uploadedImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Form'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickAndUploadImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: uploadedImageUrl != null
                      ? NetworkImage(uploadedImageUrl!)
                      : null,
                  child: uploadedImageUrl == null
                      ? Icon(Icons.camera_alt, size: 40)
                      : null,
                  backgroundColor: Colors.brown.shade300,
                ),
              ),
              buildTextField(nameController, 'Name', Icons.person),
              buildTextField(ageController, 'Age', Icons.calendar_today,
                  isNumeric: true),
              buildTextField(phoneController, 'Phone', Icons.phone),
              buildTextField(positionController, 'Position', Icons.class_),
              buildTextField(addressController, 'Address', Icons.home),
              buildTextField(monthlyController, 'Security Fee', Icons.money,
                  isNumeric: true),
              ElevatedButton(
                onPressed: addDataToFirestore,
                child: Text('Submit Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController? controller, String label, IconData icon,
      {bool isNumeric = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
          enabled: enabled,
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          return null;
        },
      ),
    );
  }

  Future<void> pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        String uploadedUrl = await uploadImageToCloudinary(File(image.path));
        setState(() {
          uploadedImageUrl = uploadedUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image uploaded successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
    }
  }

  Future<String> uploadImageToCloudinary(File imageFile) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/dimowjk2l/image/upload');
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = 'Vehi Track';
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> addDataToFirestore() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")),
        );
        return;
      }

      final String uid = user.uid;

      DocumentReference ref =
          FirebaseFirestore.instance.collection('trust').doc();

      await ref.set({
        'uid': uid,
        'name': nameController.text,
        'age': int.parse(ageController.text),
        'phone': phoneController.text,
        'position': positionController.text,
        'address': addressController.text,
        'fee': double.parse(monthlyController.text),
        'isVisit': false,
        'id': ref.id,
        'imageUrl': uploadedImageUrl,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFormCompleted', true);

      generateAndSharePdf(ref.id, {
        'name': nameController.text,
        'age': ageController.text,
        'phone': phoneController.text,
        'position': positionController.text,
        'address': addressController.text,
        'fee': monthlyController.text,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(
                  title: "Home Page",
                )),
      );
    }
  }

  Future<void> generateAndSharePdf(
      String studentRollNumber, Map<String, String> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(children: [
        pw.Text('Emergency Form', style: pw.TextStyle(fontSize: 24)),
        pw.Padding(
          padding: pw.EdgeInsets.all(10),
          child: pw.Column(
            children: data.entries
                .map((entry) => pw.Text('${entry.key}: ${entry.value}'))
                .toList(),
          ),
        ),
      ]);
    }));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$studentRollNumber-admission.pdf');
    await file.writeAsBytes(await pdf.save());

    Share.shareXFiles([XFile(file.path)],
        text: 'Emergency form for $studentRollNumber');
  }
}
