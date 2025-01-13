import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingSchedule extends StatefulWidget {
  @override
  _BookingScheduleState createState() => _BookingScheduleState();
}

class _BookingScheduleState extends State<BookingSchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Schedule',
          style: GoogleFonts.raleway(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final technicianName = userData['name'] ?? 'Technician';
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text(technicianName)),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('technicianIds',
                arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found.'));
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
              String status = bookingData['technicianStatus'] ??
                  bookingData['status'] ??
                  'Pending';
              final customerId = bookingData['userId'];

              status = bookingData['technicianStatus'] ??
                  bookingData['status'] ??
                  'Pending';

              Color statusColor = Colors.grey;

              // Check the status for the current technician
              if (status == 'Declined' &&
                  !bookingData['declinedTechnicians']
                      .contains(FirebaseAuth.instance.currentUser!.uid)) {
                // If this technician has not declined, show "Pending" for them
                status = 'Pending';
              } else if (bookingData['declinedTechnicians'] != null &&
                  bookingData['declinedTechnicians']
                      .contains(FirebaseAuth.instance.currentUser!.uid)) {
                // If the technician has declined, ensure their status remains as "Declined"
                status = 'Declined';
                statusColor = Colors.red;
              } else if (status == 'Accepted' &&
                  bookingData['acceptedTechnicianId'] ==
                      FirebaseAuth.instance.currentUser!.uid) {
                // If this technician has accepted, show the status as "Accepted"
                statusColor = Colors.green;
              } else if (status == 'Accepted') {
                // If another technician has accepted, show "Already Accepted" for this technician
                statusColor = Colors.orange;
                status = 'Already Accepted';
              } else if (status == 'Cancelled by Customer') {
                // Set color to blue when the status is "Cancelled by Customer"
                statusColor = Colors.blue;
              } else if (status == 'Pending') {
                // Show pending if neither declined nor accepted
                statusColor = Colors.grey;
              }

              /*// Set color based on status
              Color statusColor;
              if (status == 'Pending') {
                statusColor = Colors.grey;
              } else if (status == 'Cancelled by Customer') {
                statusColor = Colors.blue;
              } else if (status == 'Declined') {
                statusColor = Colors.red;
              } else if (status == 'Accepted' && bookingData['acceptedTechnicianId'] == FirebaseAuth.instance.currentUser!.uid) {
                statusColor = Colors.green;
              } else if (status == 'Accepted') {
                statusColor = Colors.orange; // "Already Accepted" by another technician
                status = 'Already Accepted';
              } else {
                statusColor = Colors.black;
              }*/

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(customerId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final customerName = userData['name'] ?? 'Unknown Customer';
                  final customerMobile = userData['mobile'] ?? 'Unknown Mobile';

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric( horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBAE5F4).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          category ?? 'Unknown Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sub-Service: $subCategory',
                                style: GoogleFonts.raleway()),
                            Text('REF ID: $refId',
                                style: GoogleFonts.raleway(
                                    fontWeight: FontWeight.bold, color:Colors.purple)),
                            Text('Customer Name: $customerName',
                                style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
                            Text('Customer Mobile: $customerMobile',
                                style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
                            Text('Date: $date', style: GoogleFonts.raleway()),
                            Text('Time: $time', style: GoogleFonts.raleway()),
                            Text('Address: $address',
                                style: GoogleFonts.raleway()),
                            Text(
                              'Status: $status',
                              style: GoogleFonts.raleway(color: statusColor,fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: status == 'Pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon:
                                        Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _updateBookingStatus(
                                        bookingId, 'Accepted'),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _updateBookingStatus(
                                        bookingId, 'Declined'),
                                  ),
                                ],
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

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    final technicianId = FirebaseAuth.instance.currentUser!.uid;

    try {
      if (status == 'Accepted') {
        // Update the booking with the accepted technician's ID and set the status accordingly
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .update({
          'status': 'Accepted',
          'technicianStatus': 'Accepted', // This is the technician's own status
          'acceptedTechnicianId': technicianId,
        });
      } else if (status == 'Declined') {
        // If declined, add the technician ID to the declined list
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .update({
          'declinedTechnicians': FieldValue.arrayUnion([technicianId]),
          'technicianStatus': 'Declined', // This is the technician's own status
        });

        // Check if all technicians have declined the booking
        final bookingSnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .get();
        final bookingData = bookingSnapshot.data() as Map<String, dynamic>;

        List<dynamic> technicianIds = bookingData['technicianIds'] ?? [];
        List<dynamic> declinedTechnicians =
            bookingData['declinedTechnicians'] ?? [];

        // Only update the overall booking status if all technicians have declined
        if (technicianIds.length == declinedTechnicians.length) {
          await FirebaseFirestore.instance
              .collection('bookings')
              .doc(bookingId)
              .update({
            'status': 'Declined',
          });
        }
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Booking $status.')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating booking: $e')));
    }
  }
}
