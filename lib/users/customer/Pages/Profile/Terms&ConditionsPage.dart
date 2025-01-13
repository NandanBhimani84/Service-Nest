import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Terms_conditionsPage extends StatelessWidget {
  const Terms_conditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Terms & Condition',
          style: GoogleFonts.raleway(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.raleway(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  text: '1. Introduction\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'Welcome to Service Nest. These Terms and Conditions ("Terms") govern your use of our service. By accessing or using the App, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the App.\n\n',
                ),
                TextSpan(
                  text: '2. Services\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'Service Nest provides. We reserve the right to modify or discontinue the service at any time without prior notice.\n\n',
                ),
                TextSpan(
                  text: '3. User Accounts\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'To use certain features of the App, you must register for an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete. You are responsible for safeguarding your password and agree not to disclose your password to any third party.\n\n',
                ),
                TextSpan(
                  text: '4. User Conduct\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'You agree not to:\n'
                      '- Use the App for any unlawful purpose.\n'
                      '- Violate any local, state, national, or international law or regulation.\n'
                      '- Engage in any activity that could damage, disable, overburden, or impair the App.\n'
                      '- Transmit any material that is defamatory, offensive, or otherwise objectionable.\n\n',
                ),
                TextSpan(
                  text: '5. Intellectual Property\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'The App and its original content, features, and functionality are and will remain the exclusive property of [Company Name] and its licensors. The App is protected by copyright, trademark, and other laws of both the [country] and foreign countries.\n\n',
                ),
                TextSpan(
                  text: '6. Termination\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'We may terminate or suspend your account and bar access to the App immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.\n\n',
                ),
                TextSpan(
                  text: '7. Limitation of Liability\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'In no event shall [Company Name], nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your use of or inability to use the App; (ii) any unauthorized access to or use of our servers and/or any personal information stored therein.\n\n',
                ),
                TextSpan(
                  text: '8. Governing Law\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'These Terms shall be governed and construed in accordance with the laws of [Country], without regard to its conflict of law provisions.\n\n',
                ),
                TextSpan(
                  text: '9. Changes to Terms\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days\' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.\n\n',
                ),
                TextSpan(
                  text: '10. Contact Us\n',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'If you have any questions about these Terms, please contact us at [contact information].',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
