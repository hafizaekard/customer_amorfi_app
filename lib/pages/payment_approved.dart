import 'package:customer_app/shared/sharedvalues.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PaymentApprovedPage extends StatelessWidget {
  const PaymentApprovedPage({super.key});

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
              style: blueTextStyle.copyWith(fontSize: 20, fontWeight: bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Terimakasih atas pesanan anda,\nkami akan menyiapkan\ndengan sepenuh hati😊',
              textAlign: TextAlign.center,
              style: blueTextStyle.copyWith(fontSize: 19),
            ),
          ],
        ),
      ),
    );
  }
}
