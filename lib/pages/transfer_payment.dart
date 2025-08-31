import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/waiting_approval.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

class TransferPayment extends StatefulWidget {
  final int totalPrice;

  const TransferPayment({super.key, required this.totalPrice});

  @override
  State<TransferPayment> createState() => _TransferPaymentState();
}

class _TransferPaymentState extends State<TransferPayment> {
  File? _image;
  bool _isLoading = false;

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('payment_proofs')
        .child(const Uuid().v4());

    final uploadTask = await storageRef.putFile(image);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  bool _isPickupDateToday(String pickupDateString) {
    try {
      final parts = pickupDateString.split('/');
      if (parts.length == 3) {
        final pickupDate = DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
        final today = DateTime.now();
        return pickupDate.year == today.year &&
            pickupDate.month == today.month &&
            pickupDate.day == today.day;
      }
    } catch (e) {
      print('Error parsing pickup date: $e');
    }
    return false;
  }

  Future<void> _reduceRemainingStock(
      List<Map<String, dynamic>> orderItems) async {
    try {
      final stockRef = FirebaseFirestore.instance
          .collection('remaining_stock')
          .doc('quantity');

      final stockSnapshot = await stockRef.get();

      if (stockSnapshot.exists) {
        final currentStock = Map<String, dynamic>.from(stockSnapshot.data()!);

        for (var item in orderItems) {
          final String itemId = item['id'];
          final int orderedQuantity = item['quantity'] ?? 0;

          if (currentStock.containsKey(itemId)) {
            final int currentQuantity = currentStock[itemId] ?? 0;
            final int newQuantity = (currentQuantity - orderedQuantity)
                .clamp(0, double.infinity)
                .toInt();
            currentStock[itemId] = newQuantity;
          }
        }

        await stockRef.set(currentStock);
        print('Stock reduced successfully for today pickup');
      }
    } catch (e) {
      print('Error reducing stock: $e');
    }
  }

  Future<void> _submitPayment() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tolong isi bukti pembayaran terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final db = FirebaseFirestore.instance;
      final tempDocRef =
          db.collection('temp_order_data').doc('current_customer');
      final tempSnapshot = await tempDocRef.get();

      if (!tempSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pelanggan tidak ditemukan')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final tempData = tempSnapshot.data();
      final customerName = tempData?['customerName'] ?? '';
      final customerAddress = tempData?['customerAddress'] ?? '';
      final customerNumber = tempData?['customerNumber'] ?? '';
      final pickupDate = tempData?['pickupDate'] ?? '';
      final orderItems =
          List<Map<String, dynamic>>.from(tempData?['orderItems'] ?? []);

      int totalPrice = 0;
      for (var item in orderItems) {
        final int quantity = item['quantity'] ?? 0;
        final int price = item['price'] ?? 0;
        totalPrice += quantity * price;
      }

      final proofImageUrl = await _uploadImage(_image!);

      final customerId = customerNumber.replaceAll(' ', '_');
      final notifDocRef = db.collection('order_notifications').doc(customerId);
      final notifSnapshot = await notifDocRef.get();

      List<Map<String, dynamic>> existingItems = [];

      if (notifSnapshot.exists) {
        final notifData = notifSnapshot.data();
        if (notifData != null && notifData['orderItems'] != null) {
          existingItems =
              List<Map<String, dynamic>>.from(notifData['orderItems']);
        }
      }

      final allOrderItems = [...existingItems, ...orderItems];

      await notifDocRef.set({
        'customerName': customerName,
        'customerAddress': customerAddress,
        'customerNumber': customerNumber,
        'pickupDate': pickupDate,
        'totalPrice': totalPrice,
        'orderItems': allOrderItems,
        'note': tempData?['note'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'proofImageUrl': proofImageUrl,
      });

      await db.collection("notification").add({
        "title": "Pesanan Baru",
        "body": "Pesanan dari $customerName menunggu persetujuan.",
        "timestamp": FieldValue.serverTimestamp(),
      });

      await db.collection("notification").doc("notification").set({
        "title": "Pesanan Baru",
        "body": "Pesanan dari $customerName menunggu persetujuan.",
        "timestamp": FieldValue.serverTimestamp(),
      });

      if (_isPickupDateToday(pickupDate)) {
        await _reduceRemainingStock(orderItems);
        print('Stock reduced because pickup date is today');
      } else {
        print('Stock not reduced because pickup date is not today');
      }

      await tempDocRef.set({
        'paymentStatus': 'pending',
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WaitingApprovalPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat mengirim data')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 48;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: whiteColor,
          appBar: AppBar(
            backgroundColor: beigeColor,
            shape:
                Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
            automaticallyImplyLeading: false,
            leading: BackButtonCustom(onPressed: () => Navigator.pop(context)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total pembelian anda: Rp. ${widget.totalPrice}',
                    style: blackTextStyle.copyWith(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  width: containerWidth,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    border: Border.all(color: blackColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pilih metode pembayaran:\n\nBCA: 1170702740 (Edwin Suhendrayani) \nBNI: 0177119221 (Edwin Suhendrayani) \nBRI: 013001000805568 (Farida Berti)',
                    style: blackTextStyle.copyWith(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 25),
                Text('Upload Bukti Pembayaran',
                    style: blackTextStyle.copyWith(fontSize: 16)),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _showImageSourceActionSheet,
                  child: Container(
                    width: containerWidth,
                    height: 300,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      border: Border.all(color: blackColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo, size: 40),
                                SizedBox(height: 8),
                                Text('Pick Image'),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blackColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                    ),
                    child: Text('Konfirmasi',
                        style: whiteTextStyle.copyWith(
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Lottie.asset(
                'assets/animations/loading.json',
                width: 250,
                height: 250,
              ),
            ),
          ),
      ],
    );
  }
}
