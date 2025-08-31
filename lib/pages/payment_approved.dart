import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/welcome_page.dart';
import 'package:customer_app/routes/custom_page_route.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class PaymentApprovedPage extends StatelessWidget {
  const PaymentApprovedPage({super.key});

  Future<void> _navigateToWelcomePage(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('temp_order_data')
          .doc('current_customer')
          .delete();
    } catch (e) {
      debugPrint('Gagal hapus data temp_order_data: $e');
    }

    Navigator.of(context).pushAndRemoveUntil(
      CustomPageRoute(page: const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/approved.json',
              width: 150,
              height: 150,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              'Pembayaran anda telah\ndisetujui oleh admin',
              textAlign: TextAlign.center,
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Terimakasih atas pesanan anda,\nkami akan menyiapkan\ndengan sepenuh hati😊',
              textAlign: TextAlign.center,
              style: blackTextStyle.copyWith(fontSize: 19),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _navigateToWelcomePage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blackColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Pesan Lagi',
                    style: whiteTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: beigeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: blackColor, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Keluar',
                    style: blackTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
