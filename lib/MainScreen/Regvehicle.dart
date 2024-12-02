import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AddDataScreen extends StatefulWidget {
  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController monthlyController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  late DateTime selectedDate = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Form'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(nameController, 'Name', Icons.person),
              buildTextField(ageController, 'Age', Icons.calendar_today,
                  isNumeric: true),
              buildTextField(phoneController, 'Phone', Icons.phone),
              buildTextField(positionController, 'Position', Icons.class_,
                  isNumeric: true),
              buildTextField(addressController, 'Address', Icons.home),
              buildTextField(monthlyController, 'Security Fee', Icons.money,
                  isNumeric: true),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                        null,
                        'visit Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                        Icons.date_range,
                        enabled: false),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: addDataToFirestore,
                child: Text('Submit Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController? controller, String label, IconData icon,
      {bool isNumeric = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
          enabled: enabled,
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          return null;
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void addDataToFirestore() async {
    if (_formKey.currentState!.validate()) {
      DocumentReference ref =
          FirebaseFirestore.instance.collection('trust').doc();

      await ref.set({
        'name': nameController.text,
        'age': int.parse(ageController.text),
        'phone': phoneController.text,
        'Position': positionController.text,
        'address': addressController.text,
        'fee': double.parse(monthlyController.text),
        'visitDate': Timestamp.fromDate(selectedDate),
        'isvisit': false,
        'id': ref.id,
      });

      generateAndSharePdf(ref.id, {
        'name': nameController.text,
        'age': ageController.text,
        'phone': phoneController.text,
        'position': positionController.text,
        'address': addressController.text,
        'fee': monthlyController.text,
        'visitDate': DateFormat('yyyy-MM-dd').format(selectedDate),
      });
    }
  }

  Future<void> generateAndSharePdf(
      String studentRollNumber, Map<String, String> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(children: [
        pw.Text('Emergency Form', style: pw.TextStyle(fontSize: 24)),
        pw.Padding(
          padding: pw.EdgeInsets.all(10),
          child: pw.Column(
            children: data.entries
                .map((entry) => pw.Text('${entry.key}: ${entry.value}'))
                .toList(),
          ),
        ),
      ]);
    }));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$studentRollNumber-admission.pdf');
    await file.writeAsBytes(await pdf.save());
    Share.shareXFiles(XFile(file.path) as List<XFile>,
        text: 'Emergency form for $studentRollNumber');
  }
}
