import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotificationPanel extends StatefulWidget {
  const UserNotificationPanel({Key? key}) : super(key: key);

  @override
  State<UserNotificationPanel> createState() => _UserNotificationPanelState();
}

class _UserNotificationPanelState extends State<UserNotificationPanel> {
  late Future<List<String>> notifications;
  late Future<int> unreadCount;

  @override
  void initState() {
    super.initState();
    notifications = getNotifications();
    unreadCount = getUnreadCount();
  }

  // Fetch notifications from SharedPreferences
  Future<List<String>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notifications') ?? [];
  }

  // Fetch unread notifications count
  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unreadCount') ?? 0;
  }

  // Mark all notifications as read
  Future<void> markNotificationsAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unreadCount', 0); // Reset unread count
    setState(() {
      unreadCount = getUnreadCount();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  }

  // Mark individual notification as read
  Future<void> markNotificationAsRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    // Ensure we don't access an out-of-bounds index
    if (index < 0 || index >= notifications.length) {
      return;
    }

    // Mark the clicked notification as read by appending "(Read)"
    notifications[index] = notifications[index] + ' (Read)';
    await prefs.setStringList('notifications', notifications);

    // Optionally update unread count
    int unreadCount = prefs.getInt('unreadCount') ?? 0;
    if (unreadCount > 0) {
      await prefs.setInt('unreadCount', unreadCount - 1);
    }

    setState(() {
      this.notifications = getNotifications(); // Refresh the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Notifications"),
        actions: [
          FutureBuilder<int>(
            future: unreadCount,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final count = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    count > 0 ? 'Unread: $count' : 'No Unread',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notificationList = snapshot.data ?? [];

          if (notificationList.isEmpty) {
            return const Center(
              child: Text('No notifications available.'),
            );
          }

          return ListView.builder(
            itemCount: notificationList.length,
            itemBuilder: (context, index) {
              final notification = notificationList[index];
              final isRead = notification.contains("(Read)");

              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Mark as read
                    notificationList[index] = notification + ' (Read)';
                  });
                  markNotificationAsRead(index); // Update in SharedPreferences
                },
                child: Container(
                  color: isRead
                      ? Colors.grey[300]
                      : Colors.white, // Highlight if read
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          color: isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: markNotificationsAsRead,
        child: const Icon(Icons.check),
        tooltip: 'Mark all as read',
      ),
    );
  }
}
