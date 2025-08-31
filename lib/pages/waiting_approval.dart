import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/payment_approved.dart';
import 'package:customer_app/pages/payment_rejected.dart';
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
  late String _customerPhone;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _loadCustomerPhoneAndListenStatus();
    _sendOrderNotification();
  }

  Future<void> _loadCustomerPhoneAndListenStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection('temp_order_data')
        .doc('current_customer')
        .get();

    if (!doc.exists) return;

    final data = doc.data();
    if (data == null) return;

    _customerPhone = data['customerNumber'] ?? '';
    if (_customerPhone.isEmpty) return;

    final docId = _customerPhone.replaceAll(' ', '_');

    FirebaseFirestore.instance
        .collection('order_notifications')
        .doc(docId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      final status = snapshot.data()?['status'];
      if (status == null || status == '') return;

      await FirebaseFirestore.instance
          .collection('temp_order_data')
          .doc('current_customer')
          .delete();

      if (!mounted) return;

      if (status == 'approved') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PaymentApprovedPage()),
        );
      } else if (status == 'rejected') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PaymentRejectedPage()),
        );
      }
    });
  }

  Future<void> _sendOrderNotification() async {
    final doc = await FirebaseFirestore.instance
        .collection('temp_order_data')
        .doc('current_customer')
        .get();

    if (!doc.exists) return;

    final data = doc.data();
    if (data == null) return;

    final String name = data['customerName'] ?? 'Tanpa Nama';
    final String date = data['pickupDate'] ?? 'Tanpa Tanggal';
    final List<dynamic> items = data['orderItems'] ?? [];

    final String itemList = items.map((item) {
      final title = item['title'] ?? 'Item';
      final qty = item['quantity'] ?? 0;
      return '$title x$qty';
    }).join(', ');

    int totalPrice = 0;
    for (var item in items) {
      final int price = item['price'] ?? 0;
      final int qty = item['quantity'] ?? 0;
      totalPrice += price * qty;
    }

    await FirebaseFirestore.instance
        .collection('notification')
        .doc('notification')
        .set({
      'title': 'Pesanan dari $name',
      'body': 'Tanggal: $date\nItem: $itemList\nTotal: Rp $totalPrice',
    });
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
                style: blackTextStyle.copyWith(fontSize: 20, fontWeight: bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
