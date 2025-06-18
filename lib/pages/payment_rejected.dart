import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentRejectedPage extends StatelessWidget {
  const PaymentRejectedPage({super.key});
  final String whatsappNumber = '6283189630547';

  Future<void> _openWhatsApp() async {
    final url = Uri.parse("https://wa.me/$whatsappNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak bisa membuka WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: newBlueColor,
        shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
        automaticallyImplyLeading: false,
        leading: BackButtonCustom(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
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
              ),
              const SizedBox(height: 20),
              Text(
                'Maaf, pembayaran anda\ntidak disetujui oleh admin',
                textAlign: TextAlign.center,
                style: blueTextStyle.copyWith(fontSize: 20, fontWeight: bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Mungkin terjadi kesalahan sistem.\nJika anda ingin mengajukan keluhan,\nsilakan kunjungi toko kami atau\nhubungi kami melalui WhatsApp.',
                textAlign: TextAlign.center,
                style: blueTextStyle.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _openWhatsApp,
                icon: FaIcon(FontAwesomeIcons.whatsapp,
                    color: whiteColor),
                label: Text(
                  'Hubungi Kami',
                  style: whiteTextStyle.copyWith(fontWeight: bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
