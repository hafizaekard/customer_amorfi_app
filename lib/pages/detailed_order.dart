import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/confirm_order.dart';
import 'package:customer_app/routes/custom_page_route.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailedOrder extends StatefulWidget {
  const DetailedOrder({super.key});

  @override
  State<DetailedOrder> createState() => _DetailedOrderState();
}

class _DetailedOrderState extends State<DetailedOrder> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, int> _quantities = {};
  final Map<String, dynamic> _items = {};
  final Map<String, int> _remainingStock = {};
  final Map<String, TextEditingController> _textControllers = {};
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int _totalPrice = 0;
  DateTime? _selectedDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadRemainingStock();

    _noteController.addListener(() {
      _saveTempOrderData();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _isPickupDateToday() {
    if (_selectedDate == null) return false;
    final today = DateTime.now();
    return _selectedDate!.year == today.year &&
        _selectedDate!.month == today.month &&
        _selectedDate!.day == today.day;
  }

  bool _shouldEnforceStock() {
    return _isPickupDateToday();
  }

  Map<String, dynamic> _getFilteredItems() {
    if (_searchQuery.isEmpty) {
      return _items;
    }

    Map<String, dynamic> filteredItems = {};
    _items.forEach((key, value) {
      final title = (value['title'] ?? '').toString().toLowerCase();
      final label = (value['label'] ?? '').toString().toLowerCase();
      final title2 = (value['title2'] ?? '').toString().toLowerCase();

      if (title.contains(_searchQuery) ||
          label.contains(_searchQuery) ||
          title2.contains(_searchQuery)) {
        filteredItems[key] = value;
      }
    });

    return filteredItems;
  }

  Future<void> _loadRemainingStock() async {
    try {
      final stockDoc =
          await _firestore.collection('remaining_stock').doc('quantity').get();
      if (stockDoc.exists) {
        final data = stockDoc.data() as Map<String, dynamic>;
        setState(() {
          _remainingStock.clear();
          for (var entry in data.entries) {
            _remainingStock[entry.key] = entry.value as int;
          }
        });
      }
    } catch (e) {
      print('Error loading remaining stock: $e');
    }
  }

  Future<void> _loadItems() async {
    final itemSnapshot = await _firestore.collection('input_item').get();
    final tempOrder = await _firestore
        .collection('temp_order_data')
        .doc('current_customer')
        .get();

    setState(() {
      _items.clear();
      _quantities.clear();
      for (var controller in _textControllers.values) {
        controller.dispose();
      }
      _textControllers.clear();

      List<MapEntry<String, dynamic>> itemsWithStock = [];
      for (var doc in itemSnapshot.docs) {
        final data = doc.data();
        final id = doc.id;
        if (data.containsKey('title') && data.containsKey('image')) {
          itemsWithStock.add(MapEntry(id, data));
        }
      }

      if (_shouldEnforceStock()) {
        itemsWithStock.sort((a, b) {
          final stockA = _remainingStock[a.key] ?? 0;
          final stockB = _remainingStock[b.key] ?? 0;
          return stockB.compareTo(stockA);
        });
      }

      for (var entry in itemsWithStock) {
        _items[entry.key] = entry.value;
        _quantities[entry.key] = 0;
        _textControllers[entry.key] = TextEditingController(text: '0');
      }

      if (tempOrder.exists) {
        final data = tempOrder.data();
        if (data != null) {
          List<dynamic>? savedItems = data['orderItems'];
          if (savedItems != null) {
            for (var item in savedItems) {
              final String id = item['id'];
              final int qty = item['quantity'];
              _quantities[id] = qty;
              _textControllers[id]?.text = qty.toString();
              final int price = _getItemPrice(id);
              _totalPrice += price * qty;
            }
          }

          final dateString = data['pickupDate'];
          if (dateString != null && dateString is String) {
            final parts = dateString.split('/');
            if (parts.length == 3) {
              _selectedDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          }

          final savedNote = data['note'];
          if (savedNote != null && savedNote is String) {
            _noteController.text = savedNote;
          }
        }
      }
    });
  }

  int _getItemPrice(String id) {
    if (_items.containsKey(id) && _items[id]['price'] != null) {
      return (_items[id]['price'] as num).toInt();
    }
    return 0;
  }

  Future<void> _saveTempOrderData() async {
    final selectedItems =
        _quantities.entries.where((entry) => entry.value > 0).map((entry) {
      final id = entry.key;
      final itemData = _items[id]!;
      return {
        'id': id,
        'title': itemData['title'] ?? 'Tanpa Nama',
        'label': itemData['label'] ?? '',
        'title2': itemData['title2'] ?? '',
        'image': itemData['image'] ?? '',
        'quantity': entry.value,
        'price': _getItemPrice(id),
      };
    }).toList();

    final String? dateString = _selectedDate != null
        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
        : null;

    await _firestore.collection('temp_order_data').doc('current_customer').set({
      'orderItems': selectedItems,
      'pickupDate': dateString,
      'note': _noteController.text.trim(),
      'isPickupToday': _isPickupDateToday(),
    }, SetOptions(merge: true));
  }

  void _updateQuantityFromText(String id, String value) {
    if (_selectedDate == null) {
      _showSnackBar("Harap pilih tanggal pengambilan terlebih dahulu");
      _textControllers[id]?.text = '0';
      return;
    }

    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) {
      _textControllers[id]?.text = '0';
      _textControllers[id]?.selection = TextSelection.fromPosition(
        TextPosition(offset: _textControllers[id]!.text.length),
      );
      setState(() {
        _totalPrice -= _quantities[id]! * _getItemPrice(id);
        _quantities[id] = 0;
      });
      _saveTempOrderData();
      return;
    }

    final int? newValue = int.tryParse(cleanValue);

    if (newValue != null) {
      if (newValue < 0) {
        _textControllers[id]?.text = '0';
        _textControllers[id]?.selection = TextSelection.fromPosition(
          TextPosition(offset: _textControllers[id]!.text.length),
        );
        _showSnackBar("Kuantitas tidak boleh kurang dari 0");
        return;
      }

      if (_shouldEnforceStock()) {
        final int maxStock = _remainingStock[id] ?? 0;
        if (newValue > maxStock) {
          _textControllers[id]?.text = maxStock.toString();
          _textControllers[id]?.selection = TextSelection.fromPosition(
            TextPosition(offset: _textControllers[id]!.text.length),
          );
          _showSnackBar(
              "Kuantitas melebihi stok yang tersedia. Maksimal: $maxStock");
          setState(() {
            _totalPrice -= _quantities[id]! * _getItemPrice(id);
            _quantities[id] = maxStock;
            _totalPrice += maxStock * _getItemPrice(id);
          });
          _saveTempOrderData();
          return;
        }
      }

      setState(() {
        _totalPrice -= _quantities[id]! * _getItemPrice(id);
        _quantities[id] = newValue;
        _totalPrice += newValue * _getItemPrice(id);
      });
      _textControllers[id]?.text = newValue.toString();
      _textControllers[id]?.selection = TextSelection.fromPosition(
        TextPosition(offset: _textControllers[id]!.text.length),
      );
      _saveTempOrderData();
    } else {
      _textControllers[id]?.text = _quantities[id].toString();
      _textControllers[id]?.selection = TextSelection.fromPosition(
        TextPosition(offset: _textControllers[id]!.text.length),
      );
      _showSnackBar("Masukkan hanya angka yang valid");
    }
  }

  void _increaseQuantity(String id) {
    if (_selectedDate == null) {
      _showSnackBar("Harap pilih tanggal pengambilan terlebih dahulu");
      return;
    }

    final currentQuantity = _quantities[id] ?? 0;

    if (_shouldEnforceStock()) {
      final availableStock = _remainingStock[id] ?? 0;
      if (currentQuantity >= availableStock) {
        _showSnackBar("Stok tidak mencukupi. Stok tersedia: $availableStock");
        return;
      }
    }

    final newQuantity = currentQuantity + 1;
    setState(() {
      _quantities[id] = newQuantity;
      _textControllers[id]?.text = newQuantity.toString();
      _totalPrice += _getItemPrice(id);
    });
    _saveTempOrderData();
  }

  void _decreaseQuantity(String id) {
    if (_selectedDate == null) {
      _showSnackBar("Harap pilih tanggal pengambilan terlebih dahulu");
      return;
    }

    final currentQuantity = _quantities[id] ?? 0;
    if (currentQuantity > 0) {
      final newQuantity = currentQuantity - 1;
      setState(() {
        _quantities[id] = newQuantity;
        _textControllers[id]?.text = newQuantity.toString();
        _totalPrice -= _getItemPrice(id);
      });
      _saveTempOrderData();
    }
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;

        _loadItems();
      });
      _saveTempOrderData();
    }
  }

  Future<void> _navigateToConfirmOrder() async {
    if (_totalPrice == 0) {
      _showSnackBar("Harap tambahkan pesanan terlebih dahulu");
      return;
    }
    if (_selectedDate == null) {
      _showSnackBar("Harap masukkan tanggal pengambilan terlebih dahulu");
      return;
    }
    await _saveTempOrderData();
    Navigator.of(context).push(CustomPageRoute(page: const ConfirmOrderPage()));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: blackColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dateNotSelected = _selectedDate == null;
    final bool enforceStock = _shouldEnforceStock();
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: beigeColor,
        shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
        automaticallyImplyLeading: false,
        leading: BackButtonCustom(onPressed: () {
          _saveTempOrderData();
          Navigator.pop(context);
        }),
      ),
      body: _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Detail Pesanan Anda',
                        style: blackTextStyle.copyWith(
                            fontSize: 20, fontWeight: normal)),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pilih tanggal pengambilan',
                        style: blackTextStyle.copyWith(
                            fontWeight: semiBold, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border.all(
                            color: dateNotSelected ? Colors.red : blackColor,
                            width: dateNotSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Pilih tanggal pengambilan *',
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: semiBold,
                                color:
                                    dateNotSelected ? Colors.red : blackColor,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: dateNotSelected ? Colors.red : blackColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (dateNotSelected) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border.all(color: blackColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: blackColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  'Harap pilih tanggal pengambilan sebelum memilih produk',
                                  style: blackTextStyle.copyWith(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Cari produk',
                        style: blackTextStyle.copyWith(
                            fontWeight: semiBold, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
                        hintStyle: greyTextStyle,
                        prefixIcon: Icon(Icons.search, color: greyColor),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: greyColor),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: whiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: blackColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: blackColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: blackColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      style: blackTextStyle,
                    ),
                    if (_searchQuery.isNotEmpty && filteredItems.isEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: greyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_off, color: greyColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tidak ada produk yang ditemukan untuk pencarian "$_searchQuery"',
                                style: greyTextStyle.copyWith(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pilih produk ${_searchQuery.isNotEmpty ? "(${filteredItems.length} dari ${_items.length} produk)" : ""}',
                        style: blackTextStyle.copyWith(
                            fontWeight: semiBold, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...filteredItems.entries.map((entry) {
                      final id = entry.key;
                      final item = entry.value;
                      final price = _getItemPrice(id);
                      final stock = _remainingStock[id] ?? 0;
                      final isOutOfStock = enforceStock && stock == 0;
                      final isDisabled = dateNotSelected || isOutOfStock;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? greyColor.withOpacity(0.1)
                              : whiteColor,
                          border: Border.all(
                            color: isDisabled
                                ? greyColor.withOpacity(0.3)
                                : blackColor,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Opacity(
                              opacity: isDisabled ? 0.5 : 1.0,
                              child: Image.network(
                                item['image'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image_not_supported,
                                        color: greyColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Opacity(
                                opacity: isDisabled ? 0.5 : 1.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'] ?? 'Tanpa Nama',
                                        style: blackTextStyle.copyWith(
                                            fontWeight: bold,
                                            color: isDisabled
                                                ? greyColor
                                                : blackColor)),
                                    if ((item['label']?.isNotEmpty == true) ||
                                        (item['title2']?.isNotEmpty == true))
                                      Row(
                                        children: [
                                          if (item['label']?.isNotEmpty == true)
                                            Text(item['label'],
                                                style: TextStyle(
                                                    color: isDisabled
                                                        ? greyColor
                                                        : Colors.blue,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          if ((item['label']?.isNotEmpty ==
                                                  true) &&
                                              (item['title2']?.isNotEmpty ==
                                                  true))
                                            const SizedBox(width: 5),
                                          if (item['title2']?.isNotEmpty ==
                                              true)
                                            Text(item['title2'],
                                                style: TextStyle(
                                                    color: isDisabled
                                                        ? greyColor
                                                        : Colors.blue,
                                                    fontSize: 11)),
                                        ],
                                      ),
                                    Text('Harga: Rp $price',
                                        style: greyTextStyle),
                                    if (enforceStock)
                                      Text('Stock: $stock',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: isDisabled
                                                  ? greyColor
                                                  : (stock > 0
                                                      ? Colors.green
                                                      : Colors.red),
                                              fontWeight: FontWeight.w500))
                                    else if (!dateNotSelected)
                                      const Text('Tersedia',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: greyColor.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: isDisabled
                                        ? null
                                        : () => _decreaseQuantity(id),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(Icons.remove,
                                          size: 18,
                                          color: isDisabled
                                              ? greyColor
                                              : redColor),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Center(
                                      child: TextFormField(
                                        controller: _textControllers[id],
                                        enabled: !isDisabled,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(3),
                                        ],
                                        onChanged: (value) =>
                                            _updateQuantityFromText(id, value),
                                        style: blackTextStyle.copyWith(
                                            fontSize: 13,
                                            color: isDisabled
                                                ? greyColor
                                                : blackColor),
                                        decoration:
                                            const InputDecoration.collapsed(
                                                hintText: ''),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: isDisabled
                                        ? null
                                        : () => _increaseQuantity(id),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(Icons.add,
                                          size: 18,
                                          color: isDisabled
                                              ? greyColor
                                              : blueColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tambah catatan untuk pembelian',
                        style: blackTextStyle.copyWith(
                            fontWeight: semiBold, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      enabled: !dateNotSelected,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: dateNotSelected
                            ? 'Pilih tanggal pengambilan terlebih dahulu'
                            : 'Contoh: Custom tart: My Little Pony',
                        hintStyle: greyTextStyle,
                        filled: true,
                        fillColor: dateNotSelected
                            ? greyColor.withOpacity(0.1)
                            : whiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: dateNotSelected
                                ? greyColor.withOpacity(0.3)
                                : blackColor,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      style: blackTextStyle.copyWith(
                        color: dateNotSelected ? greyColor : blackColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Total Harga: Rp $_totalPrice',
                        style: blackTextStyle.copyWith(
                            fontSize: 16, fontWeight: bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _navigateToConfirmOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blackColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                      ),
                      child: Text('Selanjutnya',
                          style: whiteTextStyle.copyWith(
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
