import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';

class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  FlutterVision vision = FlutterVision();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await vision.loadTesseractModel(
      args: {
        'psm': '11',
        'oem': '1',
        'preserve_interword_spaces': '1',
      },
      language: 'eng',
    );
  }

  Future<void> _recognizeText() async {
    final file = File('path/to/your/image.png');
    final bytes = await file.readAsBytes();

    final result = await vision.tesseractOnImage(
      bytesList: bytes,
    );

    print(result);  // Display recognized text
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OCR Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: _recognizeText,
          child: Text("Start OCR"),
        ),
      ),
    );
  }
}
