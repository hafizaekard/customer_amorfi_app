import 'package:customer_app/pages/detail_payment.dart';
import 'package:customer_app/routes/custom_page_route.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';

class ConfirmOrder extends StatefulWidget {
  const ConfirmOrder({super.key});

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  void _navigateToDetailPayment() {
    Navigator.of(context).push(
      CustomPageRoute(
        page: const DetailPayment(
        ),
      ),
    );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Konfirmasi Pesanan Anda',
                style: blackTextStyle.copyWith(fontSize: 20, fontWeight: normal),
              ),
              const SizedBox(height: 20),
              _buildTextField('Name'),
              const SizedBox(height: 10),
              _buildTextField('Phone Number'),
              const SizedBox(height: 10),
              _buildTextField('Address'),
              const SizedBox(height: 10),
              _buildTextField('Item'),
              const SizedBox(height: 10),
              _buildTextField('Date'),
              const SizedBox(height: 30),
              Center(
                child:  ElevatedButton(
                  onPressed: _navigateToDetailPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  child: Text(
                    'Konfirmasi',
                    style: whiteTextStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: whiteColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: blackColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: blackColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
