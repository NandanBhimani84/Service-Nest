import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewService extends StatelessWidget {
   ViewService({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('Booking Details')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return  Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return  Center(child: Text('No bookings found.'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              // Safely cast the booking data to a Map<String, dynamic>
              final bookingData = bookings[index].data() as Map<String, dynamic>;

              // Safely access the fields, providing defaults as needed
              final refId = bookingData['refId'] as String? ?? 'N/A';
              final categoryName = bookingData['category'] as String? ?? 'N/A';
              final subServiceName = bookingData['subCategory'] as String? ?? 'N/A';
              final address = bookingData['address'] as String? ?? 'N/A';
              String status = bookingData['status'] as String? ?? 'N/A';

              // Change status from "Cancelled" to "Cancelled by Customer"
              if (status == 'Cancelled') {
                status = 'Cancelled by Customer';
              }

              // Example date handling
              DateTime date = (bookingData['date'] is Timestamp)
                  ? (bookingData['date'] as Timestamp).toDate()
                  : DateTime.now();

              // Use acceptedTechnicianId to fetch the correct technician name
              String acceptedTechnicianId = bookingData['acceptedTechnicianId'] as String? ?? '';

              // Fetch customer and technician names
              return FutureBuilder<Map<String, String>>(
                future: _fetchNames(bookingData['userId'], acceptedTechnicianId, status),
                builder: (context, namesSnapshot) {
                  if (!namesSnapshot.hasData) {
                    return  Center(child: CircularProgressIndicator());
                  }

                  final customerName = namesSnapshot.data?['customerName'] ?? 'Unknown Customer';
                  final technicianName = namesSnapshot.data?['technicianName'] ?? 'Unknown Technician';

                  // Status color based on value
                  Color statusColor;
                  switch (status) {
                    case 'Accepted':
                      statusColor = Colors.green;
                      break;
                    case 'Declined':
                      statusColor = Colors.red;
                      break;
                    case 'Pending':
                      statusColor = Colors.grey;
                      break;
                    case 'Cancelled by Customer':
                      statusColor = Colors.blue;
                      break;
                    default:
                      statusColor = Colors.black;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBAE5F4).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(categoryName, style:  GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Sub-Service: $subServiceName', style:  GoogleFonts.raleway(fontSize: 16)),
                            // Always display customer name
                            Text('Customer: $customerName', style:  GoogleFonts.raleway(fontSize: 16)),
                            // Display technician name only if the status is Accepted
                            if (status == 'Accepted')
                              Text('Technician: $technicianName', style:  GoogleFonts.raleway(fontSize: 16)),
                            Text('REF ID: $refId', style:  GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Date: ${date.day}-${date.month}-${date.year}', style:  GoogleFonts.raleway(fontSize: 16)),
                            Text('Time: ${bookingData['time']}', style:  GoogleFonts.raleway(fontSize: 16)),
                            Text('Address: $address', style:  GoogleFonts.raleway(fontSize: 16)),
                            Text('Status: $status', style: GoogleFonts.raleway(fontSize: 16, color: statusColor)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, String>> _fetchNames(String customerId, String technicianId, String status) async {
    String customerName = 'Unknown Customer';
    String technicianName = 'Unknown Technician';

    // Fetch the customer name
    final customerDoc = await FirebaseFirestore.instance.collection('users').doc(customerId).get();
    if (customerDoc.exists) {
      customerName = customerDoc.data()?['name'] as String? ?? 'Unknown Customer';
    }

    // Fetch the technician name only if the status is Accepted
    if (status == 'Accepted' && technicianId.isNotEmpty) {
      final technicianDoc = await FirebaseFirestore.instance.collection('users').doc(technicianId).get();
      if (technicianDoc.exists) {
        technicianName = technicianDoc.data()?['name'] as String? ?? 'Unknown Technician';
      }
    }

    return {
      'customerName': customerName,
      'technicianName': technicianName,
    };
  }
}
