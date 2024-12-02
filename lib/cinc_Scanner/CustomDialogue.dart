import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For ImageSource.camera and ImageSource.gallery

class CustomDialogBox extends StatelessWidget {
  final VoidCallback onCameraBTNPressed;
  final VoidCallback onGalleryBTNPressed;

  CustomDialogBox(
      {required this.onCameraBTNPressed, required this.onGalleryBTNPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select an Option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            onPressed: onCameraBTNPressed,
            child: Text('Take a Picture'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: onGalleryBTNPressed,
            child: Text('Choose from Gallery'),
          ),
        ],
      ),
    );
  }
}

// Usage Example:
void showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialogBox(
        onCameraBTNPressed: () {
          // Call your scanCnic method with ImageSource.camera
          scanCnic(ImageSource.camera);
        },
        onGalleryBTNPressed: () {
          // Call your scanCnic method with ImageSource.gallery
          scanCnic(ImageSource.gallery);
        },
      );
    },
  );
}

void scanCnic(ImageSource source) {
  // Your scanCnic logic here, depending on the image source
  print('Scanning using: $source');
}
