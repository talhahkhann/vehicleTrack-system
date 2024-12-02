import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RegistrationAndIdentificationPage extends StatefulWidget {
  @override
  _RegistrationAndIdentificationPageState createState() =>
      _RegistrationAndIdentificationPageState();
}

class _RegistrationAndIdentificationPageState
    extends State<RegistrationAndIdentificationPage> {
  late List<CameraDescription> cameras;
  CameraController? _cameraController;
  bool isProcessing = false;
  bool isRegistrationMode = true;

  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _takePictureAndProcess() async {
    if (!_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please wait until the camera is initialized')));
      return;
    }
    if (isProcessing) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Processing the previous request, please wait.')));
      return;
    }
    isProcessing = true;

    final XFile image = await _cameraController!.takePicture();
    _processImage(File(image.path));
  }

  // Future<void> _processImage(File image) async {
  //   final inputImage = InputImage.fromFilePath(image.path);
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  //   try {
  //     final RecognizedText recognizedText =
  //         await textRecognizer.processImage(inputImage);
  //     if (isRegistrationMode) {
  //       String imageUrl = await _uploadImageToFirebase(image);
  //       _saveTextAndImageUrlToFirestore(recognizedText.text, imageUrl);
  //     } else {
  //       _saveVehicleRecord(recognizedText.text); // <-- Called here for Accessed Vehicles
  //     }
  //   } finally {
  //     textRecognizer.close();
  //     isProcessing = false;
  //   }
  // }

  // --- Updated _processImage method with check-in/check-out functionality ---
  Future<void> _processImage(File image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      if (isRegistrationMode) {
        // Logic for registration
        String imageUrl = await _uploadImageToFirebase(image);
        _saveTextAndImageUrlToFirestore(recognizedText.text, imageUrl);
      } else {
        // Logic for identification (vehicle check-in/check-out)
        _compareTextWithRegisteredTexts(recognizedText.text);
        _saveVehicleRecord(recognizedText.text); // Save vehicle record for identification
      }
    } finally {
      textRecognizer.close();
      isProcessing = false;
    }
  }

  // --- New Functionality for Uploading Image to Firebase ---
  Future<String> _uploadImageToFirebase(File imageFile) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String fileName = 'images/${user.uid}/${DateTime.now()}.jpg';
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    }
    throw Exception('User not logged in');
  }

  // --- New Functionality for Saving Text and Image URL to Firestore ---
  Future<void> _saveTextAndImageUrlToFirestore(
      String text, String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save registration details to Firestore
      await FirebaseFirestore.instance
          .collection('registrations')
          .doc(user.uid)
          .set({
        'text': text,
        'imageUrl': imageUrl,
        'uploadTime': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration Successful')));

      // After registration, save the vehicle record (check-in)
      await _saveVehicleRecord(text); // Assuming 'text' is the vehicle number
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User not authenticated')));
    }
  }

  // --- New Functionality for Saving Vehicle Records ---
  Future<void> _saveVehicleRecord(String vehicleNumber) async {
    final now = DateTime.now();
    final recordRef = FirebaseFirestore.instance.collection('vehicleRecords');

    // Check if the vehicle is already checked in
    final existingRecord = await recordRef
        .where('vehicleNumber', isEqualTo: vehicleNumber)
        .where('status', isEqualTo: 'Checked In')
        .get();

    if (existingRecord.docs.isEmpty) {
      // Check-In logic
      await recordRef.add({
        'vehicleNumber': vehicleNumber,
        'checkInTime': now,
        'checkOutTime': null,
        'status': 'Checked In',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle Checked In: $vehicleNumber')),
      );
    } else {
      // Check-Out logic
      final docId = existingRecord.docs.first.id;
      await recordRef.doc(docId).update({
        'checkOutTime': now,
        'status': 'Checked Out',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle Checked Out: $vehicleNumber')),
      );
    }
  }

  // --- New Functionality for Comparing Text with Registered Texts ---
  Future<void> _compareTextWithRegisteredTexts(String extractedText) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .where('text', isEqualTo: extractedText)
        .get();

    String url = 'http://192.168.186.32'; // ESP32's IP address
    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Welcome to LGU')));
      url += '/up';
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Kindly register first')));
      url += '/down';
    }

    // Send the HTTP request to the ESP32
    try {
      final response = await http.get(Uri.parse(url));
      print('ESP32 response status: ${response.statusCode}');
      print('ESP32 response body: ${response.body}');
    } catch (e) {
      print('Failed to send request to ESP32: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to communicate with ESP32')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isRegistrationMode ? 'Registration' : 'Identification'),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () => setState(() {
              isRegistrationMode = !isRegistrationMode;
            }),
          )
        ],
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? CircularProgressIndicator()
          : Column(
              children: [
                Expanded(
                  child: CameraPreview(_cameraController!),
                ),
                if (isRegistrationMode)
                  TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name')),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _takePictureAndProcess,
                    child: Text(isRegistrationMode
                        ? 'Capture for Registration'
                        : 'Capture for Identification'),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
