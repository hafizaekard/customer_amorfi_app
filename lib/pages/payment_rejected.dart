import 'package:customer_app/pages/welcome_page.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentRejectedPage extends StatelessWidget {
  const PaymentRejectedPage({super.key});

  final String whatsappNumber = '6282234568029';

  Future<void> _openWhatsApp(BuildContext context) async {
    const String message =
        'Halo, saya ingin mengajukan keluhan terkait pembayaran yang tidak disetujui.';
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri url =
        Uri.parse('https://wa.me/6282234568029?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog(context);
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstall di perangkat Anda.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToWelcomePage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _navigateToWelcomePage(context);
        }
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/rejected.json',
                    width: 120,
                    height: 120,
                    repeat: false,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Maaf, pembayaran anda\ntidak disetujui oleh admin',
                    textAlign: TextAlign.center,
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mungkin terjadi kesalahan sistem.\nJika anda ingin mengajukan keluhan,\nsilakan kunjungi toko kami atau\nhubungi kami melalui WhatsApp.',
                    textAlign: TextAlign.center,
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      height: 1.4,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 180,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () => _openWhatsApp(context),
                      icon: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: whiteColor,
                        size: 20,
                      ),
                      label: Text(
                        'Hubungi Kami',
                        style: whiteTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: whiteColor,
                        elevation: 2,
                        shadowColor: const Color(0xFF25D366).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
