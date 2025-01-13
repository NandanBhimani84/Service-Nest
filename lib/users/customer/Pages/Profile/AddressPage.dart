import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Addresspage extends StatefulWidget {
  @override
  _AddresspageState createState() => _AddresspageState();
}

class _AddresspageState extends State<Addresspage> {
  final _newAddressController = TextEditingController();
  final _updateAddressController = TextEditingController();
  List<String> _addresses = [];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && userDoc['addresses'] != null) {
        setState(() {
          _addresses = List<String>.from(userDoc['addresses']);
        });
      }
    }
  }

  Future<void> _addAddress() async {
    String newAddress = _newAddressController.text.trim();

    if (newAddress.isEmpty) {
      _showError('Please enter an address.');
      return;
    }

    if (_addresses.contains(newAddress)) {
      _showError('This address is already added.');
      return;
    }

    setState(() {
      _addresses.add(newAddress);
      _newAddressController.clear();
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'addresses': _addresses});
    }
  }

  Future<void> _deleteAddress(String address) async {
    bool confirm = await _showDeleteConfirmationDialog(address);
    if (!confirm) return; // Exit if user cancels

    setState(() {
      _addresses.remove(address);
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'addresses': _addresses});
    }
  }

  Future<bool> _showDeleteConfirmationDialog(String address) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Delete Address',style: GoogleFonts.raleway(),),
          content: Text('Are you sure you want to delete this address?',style: GoogleFonts.raleway(),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel',style: GoogleFonts.raleway(),),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete',style: GoogleFonts.raleway(),),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _updateAddress(String oldAddress, String newAddress) async {
    if (newAddress.isEmpty || newAddress == oldAddress) {
      _showError('Please update the address.');
      return;
    }

    if (_addresses.contains(newAddress)) {
      _showError('This address is already added.');
      return;
    }

    // Show confirmation dialog
    bool confirm = await _showUpdateConfirmationDialog(oldAddress, newAddress);
    if (!confirm) return; // Exit if user cancels

    setState(() {
      int index = _addresses.indexOf(oldAddress);
      if (index != -1) {
        _addresses[index] = newAddress;
      }
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'addresses': _addresses});
    }

    Navigator.of(context).pop(); // Close the dialog after update
  }

  void _showUpdateDialog(String oldAddress) {
    _updateAddressController.text = oldAddress;

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Update Address',style: GoogleFonts.raleway(),),
          content: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: CupertinoTextField(
              controller: _updateAddressController,
              placeholder: 'Enter new address',
              style: GoogleFonts.raleway(),
              maxLines: 4,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white70

              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',style: GoogleFonts.raleway(),),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                String newAddress = _updateAddressController.text.trim();

                // Show confirmation dialog before updating the address
                bool confirm =
                    await _showUpdateConfirmationDialog(oldAddress, newAddress);
                if (confirm) {
                  _updateAddress(oldAddress, newAddress);
                  Navigator.of(context)
                      .pop(); // Close the update dialog after confirmation
                }
              },
              child: Text('Update',style: GoogleFonts.raleway(),),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showUpdateConfirmationDialog(
      String oldAddress, String newAddress) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Confirm Update',style: GoogleFonts.raleway(),),
          content: Text('Are you sure you want to update the address?',style: GoogleFonts.raleway(),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Update'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _newAddressController.dispose();
    _updateAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Addresses',style: GoogleFonts.raleway(),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              maxLines: 4,
              controller: _newAddressController,
              decoration: InputDecoration(
                hintText: 'Enter your address',
                helperStyle: GoogleFonts.raleway(),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addAddress,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Add Address',style: GoogleFonts.raleway() ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _addresses.isEmpty
                  ? Center(child: Text('Please add an address.'))
                  : ListView.builder(
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        String address = _addresses[index];
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container( decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFBAE5F4)),
                            child: ListTile(
                              title: Text(address,style: GoogleFonts.raleway(),),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _showUpdateDialog(address),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteAddress(address),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
