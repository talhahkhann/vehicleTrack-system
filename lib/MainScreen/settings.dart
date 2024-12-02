// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SettingsScreen extends StatefulWidget {
//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _notificationsEnabled = true;
//   bool _darkModeEnabled = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Settings"),
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             leading: Icon(Icons.lock),
//             title: Text("Change Password"),
//             onTap: () => _changePasswordDialog(),
//           ),
//           SwitchListTile(
//             title: Text("Enable Notifications"),
//             value: _notificationsEnabled,
//             onChanged: (value) {
//               setState(() {
//                 _notificationsEnabled = value;
//               });
//             },
//           ),
//           SwitchListTile(
//             title: Text("Enable Dark Mode"),
//             value: _darkModeEnabled,
//             onChanged: (value) {
//               setState(() {
//                 _darkModeEnabled = value;
//               });
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.support),
//             title: Text("Contact Support"),
//             onTap: () => _contactSupport(),
//           ),
//           ListTile(
//             leading: Icon(Icons.logout),
//             title: Text("Logout"),
//             onTap: () => _logout(),
//           ),
//         ],
//       ),
//     );
//   }

//   void _changePasswordDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final _passwordController = TextEditingController();
//         return AlertDialog(
//           title: Text("Change Password"),
//           content: TextField(
//             controller: _passwordController,
//             obscureText: true,
//             decoration: InputDecoration(
//               labelText: "New Password",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _changePassword(_passwordController.text);
//                 Navigator.pop(context);
//               },
//               child: Text("Change"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _changePassword(String newPassword) async {
//     try {
//       await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Password changed successfully!")),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $error")),
//       );
//     }
//   }

//   void _contactSupport() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Contact Support"),
//         content: Text("Email: support@enaich_technologies.com\nPhone: +1 234 567 890"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _logout() async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacementNamed(context, "/login"); // Adjust based on your routing setup
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) toggleTheme; // This will accept the function to toggle the theme

  SettingsScreen({required this.toggleTheme}); // Constructor to accept the toggle function

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false; // To store the dark mode state locally

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
            onTap: () => _changePasswordDialog(),
          ),
          SwitchListTile(
            title: Text("Enable Notifications"),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: Text("Enable Dark Mode"),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              widget.toggleTheme(value); // Call the passed function to toggle the theme
            },
          ),
          ListTile(
            leading: Icon(Icons.support),
            title: Text("Contact Support"),
            onTap: () => _contactSupport(),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () => _logout(),
          ),
        ],
      ),
    );
  }

  void _changePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final _passwordController = TextEditingController();
        return AlertDialog(
          title: Text("Change Password"),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "New Password",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _changePassword(_passwordController.text);
                Navigator.pop(context);
              },
              child: Text("Change"),
            ),
          ],
        );
      },
    );
  }

  void _changePassword(String newPassword) async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password changed successfully!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Contact Support"),
        content: Text("Email: support@enaich_technologies.com\nPhone: +1 234 567 890"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/login"); // Adjust based on your routing setup
  }
}
