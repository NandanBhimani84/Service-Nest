import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final List<SupportOption> supportOptions = [
    SupportOption(
      title: 'Live Chat',
      subtitle: 'Chat time 9am - 9pm',
      icon: Icons.chat,
    ),
    SupportOption(
      title: 'Phone Call',
      subtitle: 'Calling hour 9am - 9pm',
      icon: Icons.phone_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Support',
          style: GoogleFonts.raleway(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: supportOptions.length,
                itemBuilder: (context, index) {
                  return SupportCard(option: supportOptions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportOption {
  final String title;
  final String subtitle;
  final IconData icon;

  SupportOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class SupportCard extends StatelessWidget {
  final SupportOption option;

  SupportCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Color(0xFFBAE5F4).withOpacity(0.6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.black.withOpacity(0.8),
                child: Icon(
                  option.icon,
                  size: 30,
                  color: Color(0xFFBAE5F4),
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    option.subtitle,
                    style: GoogleFonts.raleway(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              )
            ],
          ),
        ),
      ),
    );
  }
}
