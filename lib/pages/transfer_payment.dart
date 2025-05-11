import 'dart:io';

import 'package:customer_app/shared/sharedvalues.dart';
import 'package:customer_app/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TransferPayment extends StatefulWidget {
  const TransferPayment({super.key});

  @override
  State<TransferPayment> createState() => _TransferPaymentState();
}

class _TransferPaymentState extends State<TransferPayment> {
   File? _image;

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
              'Pembayaran Transfer',
              style: blackTextStyle.copyWith(fontSize: 20, fontWeight: normal),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: whiteColor,
                border: Border.all(color:blackColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Pilih akun pembayaran:\nAccount 1\nAccount 2\nAccount 3',
                style: blackTextStyle.copyWith(fontSize: 16, fontWeight: normal),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Upload Bukti Pembayaran',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: normal),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _showImageSourceActionSheet,
              child: Container(
                height: 300,
                width: 250,
                decoration: BoxDecoration(
                  color: whiteColor,
                  border: Border.all(color: blackColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40),
                          SizedBox(height: 8),
                          Text('Pick Image'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: () {
                  if (_image != null) {
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tolong isi bukti pembayaran terlebih dahulu')),
                    );
                  }
                },
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
            
          ],
        ),
      ),
    );
  }             
}