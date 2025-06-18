import 'package:customer_app/pages/payment_rejected.dart';
import 'package:customer_app/pages/transfer_payment.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';

class DetailPayment extends StatefulWidget {
  const DetailPayment({super.key});

  @override
  State<DetailPayment> createState() => _DetailPaymentState();
}

class _DetailPaymentState extends State<DetailPayment> {
  String _selectedPayment = '';

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pembayaran',
              style: blackTextStyle.copyWith(fontSize: 20, fontWeight: normal),
            ),
            const SizedBox(height: 24),
            _buildRadioOption('Transfer'),
            const SizedBox(height: 16),
            _buildRadioOption('Bayar di Toko'),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedPayment == 'Transfer') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransferPayment(),
                      ),
                    );
                  } else if (_selectedPayment == 'Bayar di Toko') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentRejectedPage(),
                      ),
                    );
                  } else {
                    // Tampilkan pesan jika belum pilih salah satu
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Silakan pilih metode pembayaran terlebih dahulu.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
                child: Text(
                  'Selanjutnya',
                  style: whiteTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: blackColor),
        borderRadius: BorderRadius.circular(32),
      ),
      child: RadioListTile(
        activeColor: blueColor,
        title: Text(title),
        value: title,
        groupValue: _selectedPayment,
        onChanged: (value) {
          setState(() {
            _selectedPayment = value!;
          });
        },
        shape: const StadiumBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
