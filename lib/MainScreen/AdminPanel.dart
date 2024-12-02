import 'package:flutter/material.dart';
import 'package:vehitrack/MainScreen/AdminNotificationPanel.dart';
import 'package:vehitrack/RetrevieAllUser.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 60, left: 30, right: 30),
        child: GridView.count(
          crossAxisCount: 2, // Number of columns in the grid
          padding: const EdgeInsets.all(16.0),
          crossAxisSpacing: 16.0, // Space between columns
          mainAxisSpacing: 16.0, // Space between rows
          children: [
            _buildGridItem(
              context,
              Icons.notifications,
              'Notifications',
              () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminNotificationPanel()));
              },
            ),
            _buildGridItem(
              context,
              Icons.settings,
              'Settings',
              () {
                // Navigate to Settings screen
              },
            ),
            _buildGridItem(
              context,
              Icons.chat,
              'Messages',
              () {
                // Navigate to Messages screen
              },
            ),
            _buildGridItem(
              context,
              Icons.people,
              'Users',
              () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RetrevieAllUser()));
                // Navigate to Users screen
              },
            ),
            _buildGridItem(
              context,
              Icons.analytics,
              'Analytics',
              () {
                // Navigate to Analytics screen
              },
            ),
            _buildGridItem(
              context,
              Icons.lock,
              'Security',
              () {
                // Navigate to Security screen
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build a grid item
  Widget _buildGridItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
