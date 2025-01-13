import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// Extension to add isToday method to DateTime
extension DateTimeExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return this.year == now.year &&
        this.month == now.month &&
        this.day == now.day;
  }
}

class BookServicePage extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedSubCategory;

  const BookServicePage({
    Key? key,
    this.selectedCategory,
    this.selectedSubCategory,
  }) : super(key: key);

  @override
  _BookServicePageState createState() => _BookServicePageState();
}

class _BookServicePageState extends State<BookServicePage> {
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedAddress;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? refId;

  final _formKey = GlobalKey<FormState>();
  List<String> _addresses = [];
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    selectedSubCategory = widget.selectedSubCategory;
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc['addresses'] != null) {
          setState(() {
            _addresses = List<String>.from(userDoc['addresses']);
          });
        }
      } catch (e) {
        print('Error fetching addresses: $e');
      } finally {
        setState(() {
          _isLoadingAddresses = false;
        });
      }
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    // Adjust initial date if today’s time slots are over
    if (initialDate.isToday() && !_hasAvailableTimeSlotsForToday()) {
      initialDate = initialDate.add(Duration(days: 1));
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 60)),
      selectableDayPredicate: (DateTime date) =>
          date.weekday != DateTime.sunday,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _hasAvailableTimeSlotsForToday() {
    final now = DateTime.now();
    return now.hour < 19 || (now.hour == 19 && now.minute == 0);
  }

  Future<void> _pickTime(BuildContext context) async {
    final now = DateTime.now();
    final allowedTimes = <TimeOfDay>[];
    for (int hour = 9; hour <= 19; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
        if (selectedDate != null && selectedDate!.isToday()) {
          if (time.hour > now.hour ||
              (time.hour == now.hour && time.minute > now.minute)) {
            allowedTimes.add(time);
          }
        } else {
          allowedTimes.add(time);
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Time', style: GoogleFonts.raleway()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allowedTimes.map((time) {
                return ListTile(
                  title:
                      Text(time.format(context), style: GoogleFonts.raleway()),
                  onTap: () {
                    setState(() {
                      selectedTime = time;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: GoogleFonts.raleway()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategory == null) {
        _showAlertDialog('Please select the Category');
        return;
      }

      if (selectedSubCategory == null) {
        _showAlertDialog('Please select the Sub-Category');
        return;
      }

      if (_addresses.isEmpty) {
        _showAlertDialog('Please add at least one address');
        return;
      }

      if (selectedAddress == null) {
        _showAlertDialog('Please select the Address');
        return;
      }

      if (selectedDate == null) {
        _showAlertDialog('Please select the date');
        return;
      }

      if (selectedTime == null) {
        _showAlertDialog('Please select the Time');
        return;
      }

      // Debugging: Print selected category and sub-category
      //print('Selected Category: $selectedCategory');
      //print('Selected Sub-Category: $selectedSubCategory');

      // Fetch technicians for the selected category
      List<String> technicianIds;
      try {
        QuerySnapshot techniciansSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'technician')
            .where('category', isEqualTo: selectedCategory)
            .get();

        // Debugging: Check if we have any technicians
        print(
            'Fetched technicians: ${techniciansSnapshot.docs.map((doc) => doc.data()).toList()}');

        if (techniciansSnapshot.docs.isEmpty) {
          _showAlertDialog('No technicians available for this category');
          return;
        }

        technicianIds = techniciansSnapshot.docs.map((doc) => doc.id).toList();
      } catch (e) {
        _showAlertDialog('Error fetching technicians: $e');
        return;
      }

      // Generate a new REF ID
      refId = _generateRefId();

      // Add the booking with the list of technician IDs
      try {
        await FirebaseFirestore.instance.collection('bookings').add({
          'category': selectedCategory,
          'subCategory': selectedSubCategory,
          'technicianIds': technicianIds,
          'date': DateFormat('dd-MM-yyyy').format(selectedDate!),
          'time': selectedTime!.format(context),
          'address': selectedAddress,
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'status': 'Pending',
          'refId': refId,
        });

        showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Booking Successful!'),
            content: Text('Your service has been booked with REF ID: $refId.',
                style: GoogleFonts.raleway(fontWeight:FontWeight.bold, color: Colors.purple)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    selectedAddress = null;
                    selectedDate = null;
                    selectedTime = null;
                    refId = null;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: GoogleFonts.raleway()),
              ),
            ],
          ),
        );
      } catch (e) {
        _showAlertDialog('Error submitting booking: $e');
      }
    } else {
      _showAlertDialog('Please fill all the details');
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: GoogleFonts.raleway()),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: GoogleFonts.raleway()),
            ),
          ],
        );
      },
    );
  }

  String _generateRefId() {
    Random random = Random();
    String letters = String.fromCharCodes(
        Iterable.generate(3, (_) => random.nextInt(26) + 65));
    return '${(1 + random.nextInt(999)).toString().padLeft(3, '0')}$letters';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Service', style: GoogleFonts.raleway())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected Category: ',
                    style: GoogleFonts.raleway(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 8,
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: Text("${selectedCategory ?? "None"}",
                          style: GoogleFonts.raleway(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                ),
                SizedBox(height: 20),
                Text('Selected Sub-Category: ',
                    style: GoogleFonts.raleway(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 8,
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: Text("${selectedSubCategory ?? "None"}",
                          style: GoogleFonts.raleway(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                ),
                SizedBox(height: 20),
                Text('Select Address',
                    style: GoogleFonts.raleway(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                if (_isLoadingAddresses)
                  Center(child: CircularProgressIndicator())
                else if (_addresses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8),
                    child: Text(
                        'No addresses found. Please add an address in your profile.',
                        style: GoogleFonts.raleway()),
                  )
                else
                  ..._addresses.map((address) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 2),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RadioListTile(
                          title: Text(address, style: GoogleFonts.raleway()),
                          value: address,
                          groupValue: selectedAddress,
                          onChanged: (value) {
                            setState(() {
                              selectedAddress = value as String?;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                SizedBox(height: 20),
                Text('Select Date',
                    style: GoogleFonts.raleway(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                        selectedDate != null
                            ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                            : 'Choose Date',
                        style: GoogleFonts.raleway()),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _pickDate(context),
                  ),
                ),
                SizedBox(height: 20),
                Text('Select Time',
                    style: GoogleFonts.raleway(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : 'Choose Time',
                        style: GoogleFonts.raleway()),
                    trailing: Icon(Icons.access_time),
                    onTap: () => _pickTime(context),
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: Text('Book Now', style: GoogleFonts.raleway()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
