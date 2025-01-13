import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingsPage extends StatefulWidget {
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Bookings', style: GoogleFonts.raleway(
          color: Colors.black, fontWeight: FontWeight.bold),)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found.',style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final bookingData = doc.data() as Map<String, dynamic>;
              final bookingId = doc.id;
              final category = bookingData['category'];
              final subCategory = bookingData['subCategory'];
              final refId = bookingData['refId'];
              final date = bookingData['date'];
              final time = bookingData['time'];
              final address = bookingData['address'];
              String status = bookingData['status'] ?? 'Pending';

              Color statusColor;
              if (status == 'Accepted') {
                statusColor = Colors.green;
              } else if (status == 'Declined') {
                statusColor = Colors.red;
              } else if (status == 'Cancelled') {
                statusColor = Colors.blue;
              } else {
                statusColor = Colors.grey;
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(bookingData['acceptedTechnicianId'])
                    .get(),
                builder: (context, technicianSnapshot) {
                  String technicianName = '';
                  String technicianMobile = '';

                  // Only show technician details if the booking is accepted
                  if (status == 'Accepted' && technicianSnapshot.hasData) {
                    final technicianData = technicianSnapshot.data?.data() as Map<String, dynamic>?;
                    technicianName = technicianData?['name'] ?? 'Unknown Technician';
                    technicianMobile = technicianData?['mobile'] ?? 'Unknown Mobile';
                  } else if (technicianSnapshot.hasError) {
                    technicianName = 'Error fetching technician details';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBAE5F4).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text(
                          category ?? 'Unknown Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sub-Service: $subCategory',style: GoogleFonts.raleway()),
                            Text('REF ID: $refId', style: GoogleFonts.raleway(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.purple)),
                            Text('Technician Name: $technicianName',style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
                            Text('Technician Mobile: $technicianMobile',style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
                            Text('Date: $date',style: GoogleFonts.raleway()),
                            Text('Time: $time',style: GoogleFonts.raleway()),
                            Text('Address: $address',style: GoogleFonts.raleway()),
                            Text('Status: $status',style: GoogleFonts.raleway(color: statusColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: status == 'Pending'
                            ? IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _cancelBooking(bookingId),
                        )
                            : null,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      // Update the status to "Cancelled" for the customer and "Cancelled by Customer" for the technician
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'Cancelled',
        'technicianStatus': 'Cancelled by Customer',
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking cancelled.',style: GoogleFonts.raleway())));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cancelling booking: $e',style: GoogleFonts.raleway())));
    }
  }
}