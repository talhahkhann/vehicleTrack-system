import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccessedVehiclesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accessed Vehicles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicleRecords')
            .orderBy('checkInTime', descending: true) // Sort by check-in time
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final records = snapshot.data!.docs;

          if (records.isEmpty) {
            return Center(
              child: Text('No vehicle records found.'),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text('Vehicle: ${record['vehicleNumber']}'),
                subtitle: Text(
                  'Check-In: ${record['checkInTime'].toDate()}\n'
                  'Check-Out: ${record['checkOutTime'] != null ? record['checkOutTime'].toDate() : 'N/A'}\n'
                  'Status: ${record['status']}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
