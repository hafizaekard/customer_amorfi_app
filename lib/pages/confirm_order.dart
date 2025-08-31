import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/transfer_payment.dart';
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
  final TextEditingController _dateController = TextEditingController();

  String _itemListText = '';
  String _noteText = '';
  int _totalPrice = 0;

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
        final List<dynamic> orderItems = data['orderItems'] ?? [];

        int total = 0;
        String itemList = '';
        for (var item in orderItems) {
          final String title = item['title'] ?? 'Unknown';
          final int quantity = item['quantity'] ?? 0;
          final int price = item['price'] ?? 0;
          total += quantity * price;
          itemList += '- $title x$quantity\n';
        }

        setState(() {
          _nameController.text = data['customerName'] ?? '';
          _phoneController.text = data['customerNumber'] ?? '';
          _addressController.text = data['customerAddress'] ?? '';
          _dateController.text = data['pickupDate'] ?? '';
          _itemListText = itemList.trim();
          _totalPrice = total;
          _noteText = data['note'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading customer data: $e');
    }
  }

  void _navigateToTransferPayment() {
    Navigator.of(context).push(
      CustomPageRoute(
        page: TransferPayment(totalPrice: _totalPrice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: beigeColor,
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
                style:
                    blackTextStyle.copyWith(fontSize: 20, fontWeight: normal),
              ),
              const SizedBox(height: 20),
              _buildLabel('Nama'),
              _buildTextField(_nameController),
              const SizedBox(height: 10),
              _buildLabel('Nomor Telepon'),
              _buildTextField(_phoneController),
              const SizedBox(height: 10),
              _buildLabel('Alamat'),
              _buildTextField(_addressController),
              const SizedBox(height: 10),
              _buildLabel('Detail Pesanan'),
              _buildMultilineField(_itemListText),
              const SizedBox(height: 10),
              if (_noteText.isNotEmpty) ...[
                _buildLabel('Catatan'),
                _buildMultilineField(_noteText),
                const SizedBox(height: 10),
              ],
              _buildLabel('Tanggal Pengambilan'),
              _buildTextField(_dateController),
              const SizedBox(height: 10),
              Text(
                'Total Harga: Rp $_totalPrice',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: bold,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: _navigateToTransferPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blackColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                  ),
                  child: Text(
                    'Konfirmasi',
                    style: whiteTextStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 17),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: blackTextStyle.copyWith(fontWeight: semiBold),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
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

  Widget _buildMultilineField(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: blackColor),
        borderRadius: BorderRadius.circular(10),
        color: whiteColor,
      ),
      child: Text(
        content.isNotEmpty ? content : '-',
        style: blackTextStyle,
      ),
    );
  }
}
