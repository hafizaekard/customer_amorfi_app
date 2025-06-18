import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/confirm_order.dart';
import 'package:customer_app/routes/custom_page_route.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';

class DetailedOrder extends StatefulWidget {
  const DetailedOrder({super.key});

  @override
  State<DetailedOrder> createState() => _DetailedOrderState();
}

class _DetailedOrderState extends State<DetailedOrder> {
  final List<TextEditingController> _itemControllers = [
    TextEditingController()
  ];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('temp_order_data')
          .doc('current_customer')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final List<String> items = List<String>.from(data['orderItems'] ?? []);
        final String? dateStr = data['pickupDate'];

        setState(() {
          _itemControllers.clear();
          for (final item in items) {
            _itemControllers.add(TextEditingController(text: item));
          }

          if (_itemControllers.isEmpty) {
            _itemControllers.add(TextEditingController());
          }

          if (dateStr != null && dateStr.contains('/')) {
            final parts = dateStr.split('/');
            final int day = int.tryParse(parts[0]) ?? 1;
            final int month = int.tryParse(parts[1]) ?? 1;
            final int year = int.tryParse(parts[2]) ?? 2000;
            _selectedDate = DateTime(year, month, day);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading saved order: $e');
    }
  }

  void _addItem() {
    setState(() {
      _itemControllers.add(TextEditingController());
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _itemControllers.removeAt(index);
    });
  }

  Future<void> _navigateToConfirmOrder() async {
    try {
      final List<String> items = _itemControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final String? dateString = _selectedDate != null
          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
          : null;

      await FirebaseFirestore.instance
          .collection('temp_order_data')
          .doc('current_customer')
          .set({
        'orderItems': items,
        'pickupDate': dateString,
      }, SetOptions(merge: true));

      Navigator.of(context).push(
        CustomPageRoute(
          page: const ConfirmOrderPage(),
        ),
      );
    } catch (e) {
      debugPrint('Error saving detailed order: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildItemField(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                border: Border.all(color: blackColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _itemControllers[index],
                decoration: InputDecoration(
                  hintText: 'Produk ${index + 1}',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          if (index != 0) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _deleteItem(index),
              child: Icon(Icons.delete, color: redColor),
            ),
          ],
        ],
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Pesanan Anda',
                style:
                    blackTextStyle.copyWith(fontSize: 20, fontWeight: normal),
              ),
              const SizedBox(height: 20),

              ..._itemControllers
                  .asMap()
                  .entries
                  .map((entry) => _buildItemField(entry.key)),

              Center(
                child: TextButton(
                  onPressed: _addItem,
                  child: Text('Tambah',
                      style: blackTextStyle.copyWith(
                          fontSize: 14, fontWeight: bold)),
                ),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    border: Border.all(color: blackColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Tanggal Pengambilan',
                          style: blackTextStyle.copyWith(
                              fontSize: 14, fontWeight: semiBold)),
                      Icon(Icons.calendar_today, color: blackColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _navigateToConfirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
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
      ),
    );
  }
}
