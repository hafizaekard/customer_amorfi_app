import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Memperbarui data order berdasarkan ID
  Future<void> editOrderData(Map<String, dynamic> orderData, String id) async {
    await firestore.collection('order_data').doc(id).update(orderData);
  }

  /// Mengambil semua data order dari koleksi 'order_data'
  Future<List<Map<String, dynamic>>> getOrderData() async {
    try {
      final snapshot = await firestore
          .collection('order_data')
          .orderBy('customerName', descending: false)
          .get();

      return snapshot.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id, // Menambahkan document ID untuk keperluan edit/delete
          }).toList();
    } catch (error) {
      print('Failed to fetch order data: $error');
      rethrow;
    }
  }

  /// Mengambil gambar dari koleksi 'image' berdasarkan document ID
  Future<String> getImage(String docId) async {
    final imageRef = firestore.collection('image');
    final snapshot = await imageRef.doc(docId).get();
    return snapshot['image'];
  }

  /// ✅ Menyimpan field individual dari customer secara otomatis ke Firestore
  Future<void> saveTempCustomerField(String field, String value) async {
    try {
      await firestore
          .collection('temp_order_data')
          .doc('current_customer') // Bisa diganti dengan UID jika login
          .set({field: value}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving $field: $e');
      rethrow;
    }
  }
}
