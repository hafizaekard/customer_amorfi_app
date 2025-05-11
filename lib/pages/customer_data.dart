import 'package:customer_app/pages/personal_data.dart';
import 'package:customer_app/routes/custom_page_route.dart';
import 'package:customer_app/shared/sharedvalues.dart';
import 'package:flutter/material.dart';

class CustomerData extends StatefulWidget {
  const CustomerData({super.key});

  @override
  State<CustomerData> createState() => _CustomerDataState();
}

class _CustomerDataState extends State<CustomerData> {
  void _navigateToPersonalData() {
    Navigator.of(context).push(
      CustomPageRoute(
        page: const PersonalData(
         
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          Positioned(top: 150, left: 20, child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selamat Datang,", style: blackTextStyle.copyWith(fontSize: 25, fontWeight: normal),),
              const SizedBox(height: 10),
              Text("Pelanggan setia Amorfi Cake!", style: blackTextStyle.copyWith(fontSize: 20, fontWeight: normal)),
              const SizedBox(height: 70),
              Text("Silahkan lanjutkan pesanan anda 😊", style: blackTextStyle.copyWith(fontSize: 20, fontWeight: normal)),
              const SizedBox(height: 50),
              
            ],
          ),
          ),
            Center(
              child: ElevatedButton(
                onPressed: _navigateToPersonalData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
                child: Text(
                  'Lanjut Pesan',
                  style: blackTextStyle.copyWith(fontWeight: FontWeight.bold, color: whiteColor),
                ),
              ),
            )
        ],
        
      ),
    );
  }
}
