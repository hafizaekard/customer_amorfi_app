import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/detail_payment.dart';
import 'package:customer_app/routes/custom_page_route.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';

class ConfirmOrderPage extends StatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      final doc = await _firestore
          .collection('temp_order_data')
          .doc('current_customer')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['customerName'] ?? '';
          _phoneController.text = data['customerNumber'] ?? '';
          _addressController.text = data['customerAddress'] ?? '';
          _itemController.text = data['orderItems']?.join(', ') ?? ''; 
          _dateController.text = data['pickupDate'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading customer data: $e');
    }
  }

  void _navigateToDetailPayment() {
    Navigator.of(context).push(
      CustomPageRoute(
        page: const DetailPayment(),
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
              _buildTextField('Name', _nameController),
              const SizedBox(height: 10),
              _buildTextField('Phone Number', _phoneController),
              const SizedBox(height: 10),
              _buildTextField('Address', _addressController),
              const SizedBox(height: 10),
              _buildTextField('Item', _itemController),
              const SizedBox(height: 10),
              _buildTextField('Date', _dateController),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
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

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: whiteColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
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
