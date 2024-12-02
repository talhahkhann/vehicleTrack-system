import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'Regvehicle.dart';
import 'package:pdf_render/pdf_render.dart' as pdf_render_package;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_card/animated_card.dart';
import 'package:animated_flip_card/animated_flip_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flip_card/flip_card.dart';
import 'package:pdf/pdf.dart' as pdfLib;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class DataCollect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List of Access',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseListView(),
    );
  }
}

class FirebaseListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Access  Status',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFAFBFC),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 63, 81, 181),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(105.0),
              bottomRight: Radius.circular(105.0),
            ),
          ),
          elevation: 20, // Set elevation to add a shadow
          shadowColor: Colors.black.withOpacity(1.0),

          bottom: TabBar(
            labelColor: Colors.white, // Set the selected tab text color
            unselectedLabelColor: Colors.white
                .withOpacity(0.6), // Set the unselected tab text color
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.pending,
                    color: const Color.fromARGB(255, 239, 135, 78)),
                text: 'Pending',
              ),
              Tab(
                text: 'Today',
                icon: Icon(Icons.perm_phone_msg, color: Colors.yellow),
              ),
              Tab(
                icon: Icon(Icons.verified, color: Colors.green),
                text: 'Done',
              ),
              Tab(
                icon: Icon(Icons.people, color: Colors.white),
                text: 'All',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AccessList(status: 'Pending'),
            AccessList(status: 'Today'),
            AccessList(status: 'Done'),
            AccessList(status: 'All'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.call),
        ),
      ),
    );
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class AccessList extends StatelessWidget {
  final String status;

  AccessList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('trust').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var filteredStudents = snapshot.data!.docs.where((document) {
          if (status == 'Pending') {
            Timestamp? feedate = document['feedate'];
            bool isFeeNotPaid = document['isvisit'] ?? false;
            return !isFeeNotPaid &&
                feedate != null &&
                feedate.toDate().isBefore(DateTime.now());
          } else if (status == 'Today') {
            Timestamp? feedate = document['feedate'];
            return feedate != null &&
                isSameDay(feedate.toDate(), DateTime.now());
          } else if (status == 'Done') {
            bool isFeePaid = document['isvisit'] ?? false;
            return isFeePaid;
          } else {
            return true;
          }
        }).toList();

        return ListView.builder(
          itemCount: filteredStudents.length,
          itemBuilder: (context, index) {
            var document = filteredStudents[index];
            var name = document['name'];
            var studentRollNumber = document.id;

            return FlipCard(
              direction: FlipDirection.HORIZONTAL,
              front: _buildFrontCard(
                context,
                name,
                document,
              ),
              back: _buildBackCard(context, document, 1),
            );
          },
        );
      },
    );
  }

  Widget _buildFrontCard(
      BuildContext context, String name, DocumentSnapshot<Object?> document) {
    return GestureDetector(
      onTap: () {
        _showActionSheet(context, name, '', false, 0, document);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: const Color.fromARGB(255, 66, 204, 142),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 66, 204, 142),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25),
                    CircleIconWithText(icon: Icons.person, label: name),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 10,
                      child: CustomPaint(
                        painter: SimplePieShapePainter(),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: MediaQuery.of(context).size.width / 2 - 48,
                child: Transform.translate(
                  offset: Offset(0, -25),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromARGB(255, 63, 81, 181),
                        width: 2.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/selena.jpg',
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    // Your date formatting logic here
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildBackCard(
    BuildContext context,
    DocumentSnapshot document,
    int studentRollNumber,
  ) {
    var name = document['name'];
    var age = document['age'];
    var phoneNumber = document['phone'];
    var position = document['position'];
    bool isvisit = document['isvisit'] ?? false;

    return GestureDetector(
      onTap: () {
        _showActionSheet(
          context,
          name,
          phoneNumber,
          isvisit,
          studentRollNumber,
          document,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: isvisit
              ? const Color.fromARGB(255, 66, 204, 142)
              : const Color.fromARGB(255, 239, 135, 78),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isvisit
                  ? const Color.fromARGB(255, 66, 204, 142)
                  : const Color.fromARGB(255, 239, 135, 78),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleIconWithText(icon: Icons.person, label: name),
                SizedBox(height: 5),
                Text(
                  'Age: $age | Class: $position',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Phone: $phoneNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Fee Status: ${isvisit ? 'Paid' : 'Pending'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 10,
                  child: CustomPaint(
                    painter: SimplePieShapePainter(),
                  ),
                ),
                SizedBox(height: 5),
                MonthlyFeeRecords(studentRollNumber: studentRollNumber),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showActionSheet(
  BuildContext context,
  String studentName,
  String phoneNumber,
  bool isvisit,
  int studentRollNumber,
  DocumentSnapshot<Object?> document,
) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Direct Call'),
            onTap: () {
              _makeDirectCall(phoneNumber);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.print),
            title: Text('Wireless Print'),
            onTap: () {
              // Close the action sheet if needed
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('WhatsApp Call'),
            onTap: () {
              _makeWhatsAppCall(phoneNumber);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.print),
            title: Text('Print Detail'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.send),
            title: Text('Send PDF via WhatsApp'),
            onTap: () {
              int fee = document['fee'];
              _sendPDFViaWhatsApp(context, studentName, fee, phoneNumber);
              Navigator.pop(context);
            },
          ),
          if (!isvisit)
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Challan'),
              onTap: () {
                int fee = document['fee'];
                _showPaymentDialog(context, studentName, fee);
                Navigator.pop(context);
              },
            ),
        ],
      );
    },
  );
}

void _sendPDFViaWhatsApp(BuildContext context, String studentName, int fee,
    String phoneNumber) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 1,
                child: pw.Text('LGU Security',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Paragraph(
                text:
                    "This is an Notes for '$studentName' for the Emergency Action.",
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.Container(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(' Name:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(studentName, style: pw.TextStyle(fontSize: 18)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Challan Amount:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Rs.$fee', style: pw.TextStyle(fontSize: 18)),
                ],
              ),
              pw.Divider(),
              pw.Container(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Dated:', style: pw.TextStyle(fontSize: 18)),
                  pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      style: pw.TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/invoice_$studentName.pdf');
  await file.writeAsBytes(await pdf.save());

  try {
    await Share.shareXFiles([XFile(file.path)],
        text: 'Please find the attached invoice for the fee payment.',
        subject: 'Invoice for $studentName');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Invoice shared successfully')));
  } catch (e) {
    print('Error sharing PDF via share dialog: $e');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing invoice via share dialog')));
  }
}

void _makeDirectCall(String phoneNumber) {
  // Add your logic to make a direct call
  launch('tel:$phoneNumber');
}

void _makeWhatsAppCall(String phoneNumber) async {
  // Add your logic to make a WhatsApp call
  await launch('https://wa.me/$phoneNumber');
}

class CircleIconWithText extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  CircleIconWithText({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            icon,
            color: Color.fromARGB(255, 63, 81, 181),
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        if (value != null)
          Text(
            value!,
            style: TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}

class SimplePieShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 63, 81, 181)
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

void _showPaymentDialog(BuildContext context, String studentName, int fee) {
  TextEditingController paymentController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Challan Amount'),
        content: TextFormField(
          controller: paymentController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the payment amount';
            }
            return null;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              int paymentAmount = int.tryParse(paymentController.text) ?? 0;
              _processPayment(context, studentName, fee, paymentAmount);
              Navigator.pop(context);
            },
            child: Text('Pay'),
          ),
        ],
      );
    },
  );
}

void _processPayment(
  BuildContext context,
  String studentName,
  int fee,
  int paymentAmount,
) {
  int pendingAmount = calculatePendingAmountForPayment(fee, paymentAmount);

  // Update the Firestore entry to reflect the payment
  FirebaseFirestore.instance
      .collection('trust')
      .where('name', isEqualTo: studentName)
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      doc.reference.update({
        'isvisit': pendingAmount <= 0,
        'pendingAmount': pendingAmount,
      });
    });
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Payment for $studentName processed')),
  );
}

int calculatePendingAmountForPayment(int fee, int paymentAmount) {
  int pendingAmount = fee - paymentAmount;
  return pendingAmount < 0 ? 0 : pendingAmount;
}

class MonthlyFeeRecords extends StatelessWidget {
  final int studentRollNumber;

  MonthlyFeeRecords({required this.studentRollNumber});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('trust')
          .doc('$studentRollNumber')
          .collection('feeRecords')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var feeRecords = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Fee Records:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            if (feeRecords.isEmpty)
              Text(
                'No fee records available.',
                style: TextStyle(color: Colors.white),
              ),
            for (var record in feeRecords) MonthlyFeeRecordTile(record: record),
          ],
        );
      },
    );
  }
}

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

class MonthlyFeeRecordTile extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> record;

  MonthlyFeeRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    var fee = record['fee'];
    var feedate = record['feedate'] != null
        ? (record['feedate'] as Timestamp).toDate()
        : null;
    var isFeePaid = record['isFeePaid'] ?? false;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fee: $fee',
            style: TextStyle(color: Colors.white),
          ),
          if (feedate != null)
            Text(
              'Date: ${formatDate(feedate)}',
              style: TextStyle(color: Colors.white),
            ),
          Text(
            'Status: ${isFeePaid ? 'Paid' : 'Pending'}',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
