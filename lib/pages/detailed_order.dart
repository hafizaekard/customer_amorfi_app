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

  void _navigateToConfirmOrder() {
    Navigator.of(context).push(
      CustomPageRoute(
        page: const ConfirmOrder(),
      ),
    );
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

              // Select Date
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
