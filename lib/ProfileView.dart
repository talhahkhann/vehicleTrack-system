import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Fetch the profile data using the UID from Firestore
  Future<Map<String, dynamic>> fetchProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final uid = user.uid;
    print('Fetching profile for UID: $uid');

    // Query the collection to find the document with the matching 'uid'
    final querySnapshot = await FirebaseFirestore.instance
        .collection('trust')
        .where('uid', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document from the query snapshot
      final doc = querySnapshot.docs.first;
      print('Document data: ${doc.data()}');
      return doc.data() as Map<String, dynamic>;
    } else {
      print('No document found for UID: $uid');
      return {}; // Return an empty map if no document is found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Profile View',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchProfileData(), // Fetch profile data from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No profile data found'));
          }

          final data = snapshot.data!; // Data fetched from Firestore
          final imageUrl = data['imageUrl'] ?? '';
          print("Image Url $imageUrl"); // Default to empty if no image

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl) // Load image from URL
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider, // Default avatar if no image
                  ),
                ),
                const SizedBox(height: 16), // Add spacing below avatar
                ProfileField(label: 'Name', value: data['name']),
                ProfileField(label: 'Phone', value: data['phone']),
                ProfileField(label: 'Age', value: data['age'].toString()),
                ProfileField(label: 'Fee', value: data['fee'].toString()),
                ProfileField(label: 'ID', value: data['id']),
                ProfileField(
                    label: 'Is Visit', value: data['isVisit'] ? 'Yes' : 'No'),
                ProfileField(label: 'Address', value: data['address']),
                ProfileField(label: 'Position', value: data['position']),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        readOnly: true, // Make the text field read-only
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        controller: TextEditingController(text: value), // Set value
      ),
    );
  }
}
