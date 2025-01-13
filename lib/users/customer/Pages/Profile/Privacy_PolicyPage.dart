import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.raleway(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.raleway(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  text: "1. Personal Information: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "When you register for an account, we may collect personal information such as your name, email address, phone number, and other contact details.\n\n",
                ),
                TextSpan(
                  text: "2. Usage Data: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "We automatically collect information about your use of the App, including the services you use, your interactions with other users, and your device information (such as IP address, device ID, and browser type).\n\n",
                ),
                TextSpan(
                  text: "How We Use Your Information\n\n",
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const TextSpan(
                  text:
                      "We use the information we collect for various purposes, including:\n\n",
                ),
                TextSpan(
                  text: "1. To Provide and Maintain our Service: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "To operate and maintain our App, provide customer support, and communicate with you about your account and the services you use.\n\n",
                ),
                TextSpan(
                  text: "2. To Improve our Service: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "To analyze usage and trends to improve the functionality and user experience of our App.\n\n",
                ),
                TextSpan(
                  text: "3. To Communicate with You: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "To send you updates, newsletters, marketing materials, and other information that may be of interest to you.\n\n",
                ),
                TextSpan(
                  text: "4. To Ensure Security: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "To protect against and prevent fraud, unauthorized transactions, and other liabilities.\n\n",
                ),
                TextSpan(
                  text: "Sharing Your Information\n\n",
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const TextSpan(
                  text: "We may share your information with:\n\n",
                ),
                TextSpan(
                  text: "1. Service Providers: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "We may share your information with third-party service providers who perform services on our behalf, such as payment processing, data analysis, email delivery, and hosting services.\n\n",
                ),
                TextSpan(
                  text: "2. Legal Obligations: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "We may disclose your information if required to do so by law or in response to valid requests by public authorities.\n\n",
                ),
                TextSpan(
                  text: "3. Business Transfers: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "If we are involved in a merger, acquisition, or asset sale, your personal information may be transferred as part of that transaction.\n\n",
                ),
                TextSpan(
                  text: "Your Choices\n\n",
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const TextSpan(
                  text:
                      "You have several choices regarding your information:\n\n",
                ),
                TextSpan(
                  text: "1. Access and Update: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "You can access and update your personal information through your account settings.\n\n",
                ),
                TextSpan(
                  text: "2. Opt-Out: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "You can opt-out of receiving promotional communications from us by following the instructions in those communications or by contacting us directly.\n\n",
                ),
                TextSpan(
                  text: "3. Delete Your Information: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      "You can request that we delete your personal information by contacting us. Please note that we may retain certain information as required by law or for legitimate business purposes.\n\n",
                ),
                TextSpan(
                  text: "Security\n\n",
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const TextSpan(
                  text:
                      "We implement appropriate security measures to protect your information from unauthorized access, alteration, disclosure, or destruction. However, no security measure is perfect, and we cannot guarantee the absolute security of your information.\n\n",
                ),
                TextSpan(
                  text: "Changes to This Privacy Policy\n\n",
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const TextSpan(
                  text:
                      "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last updated\" date. You are advised to review this Privacy Policy periodically for any changes.\n\n",
                ),
                TextSpan(
                  text: "Contact Us\n\n",
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const TextSpan(
                  text:
                      "If you have any questions about this Privacy Policy, please contact us at:\n\n",
                ),
                TextSpan(
                  text: "Email: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: "[Your Contact Email]\n\n",
                ),
                TextSpan(
                  text: "Address: ",
                  style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: "[Your Contact Address]\n\n",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
