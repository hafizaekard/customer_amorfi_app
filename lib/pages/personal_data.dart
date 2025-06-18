import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/detailed_order.dart';
import 'package:customer_app/routes/custom_page_route.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({super.key});

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    // Listener untuk auto-save ke Firestore
    _nameController.addListener(() {
      _saveField('customerName', _nameController.text);
    });

    _phoneController.addListener(() {
      _saveField('customerNumber', _phoneController.text);
    });

    _addressController.addListener(() {
      _saveField('customerAddress', _addressController.text);
    });

    // Opsional: Muat data sebelumnya jika ada
    _loadTempCustomerData();
  }

  // Simpan field individual ke Firestore
  Future<void> _saveField(String field, String value) async {
    try {
      await _firestore
          .collection('temp_order_data')
          .doc('current_customer')
          .set({field: value}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving $field: $e');
    }
  }

  // Memuat data yang sebelumnya disimpan (jika ada)
  Future<void> _loadTempCustomerData() async {
    try {
      final doc = await _firestore
          .collection('temp_order_data')
          .doc('current_customer')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['customerName'] ?? '';
        _phoneController.text = data['customerNumber'] ?? '';
        _addressController.text = data['customerAddress'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading customer data: $e');
    }
  }

  void _navigateToDetailedOrder() {
    Navigator.of(context).push(
      CustomPageRoute(
        page: const DetailedOrder(),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lengkapi data anda ya! 😊',
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField('Nama', _nameController),
            const SizedBox(height: 16),
            _buildInputField('Nomor Telepon', _phoneController),
            const SizedBox(height: 16),
            _buildInputField('Alamat', _addressController),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _navigateToDetailedOrder,
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        border: Border.all(color: blackColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
