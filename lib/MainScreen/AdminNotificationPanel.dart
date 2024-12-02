import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminNotificationPanel extends StatefulWidget {
  const AdminNotificationPanel({Key? key}) : super(key: key);

  @override
  State<AdminNotificationPanel> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminNotificationPanel> {
  final TextEditingController _notificationController = TextEditingController();
  late Future<List<String>> sentNotifications;

  @override
  void initState() {
    super.initState();
    sentNotifications = getNotifications();
  }

  // Send notification message
  Future<void> sendNotification(String message) async {
    if (message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty!')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    notifications.add(message); // Add the new notification message

    // Save the updated list of notifications
    await prefs.setStringList('notifications', notifications);

    // Update the unread count
    int unreadCount = prefs.getInt('unreadCount') ?? 0;
    await prefs.setInt('unreadCount', unreadCount + 1);

    // Refresh the list
    setState(() {
      sentNotifications = getNotifications();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent successfully!')),
    );

    // Clear the input field after sending the notification
    _notificationController.clear();
  }

  // Fetch notifications from SharedPreferences
  Future<List<String>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notifications') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Send Notification",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notificationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter notification message',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => sendNotification(_notificationController.text),
              child: const Text("Send Notification"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sent Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: sentNotifications,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  final notifications = snapshot.data ?? [];
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text('No notifications sent yet.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(notifications[
                            index]), // Just display the notification message
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
