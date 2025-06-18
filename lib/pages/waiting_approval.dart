import 'package:customer_app/shared/sharedvalues.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WaitingApprovalPage extends StatefulWidget {
  const WaitingApprovalPage({super.key});

  @override
  State<WaitingApprovalPage> createState() => _WaitingApprovalPageState();
}

class _WaitingApprovalPageState extends State<WaitingApprovalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward(); // langsung mulai animasi masuk
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeController,
              child: Lottie.asset(
                'assets/animations/hourglass.json',
                width: 120,
                height: 120,
                repeat: true,
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeController,
              child: Text(
                'Menunggu admin\nmenyetujui\npembayaran anda',
                textAlign: TextAlign.center,
                style: blueTextStyle.copyWith(fontSize: 20, fontWeight: bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
