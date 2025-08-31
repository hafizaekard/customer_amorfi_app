import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  
  Future<void> editOrderData(Map<String, dynamic> orderData, String id) async {
    try {
      if (id.trim().isEmpty) {
        throw ArgumentError('Document ID tidak boleh kosong');
      }
      await firestore.collection('order_data').doc(id).update(orderData);
    } catch (error) {
      print('Failed to update order: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrderData() async {
    try {
      final snapshot = await firestore
          .collection('order_data')
          .orderBy('customerName', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (error) {
      print('Failed to fetch order data: $error');
      rethrow;
    }
  }

  Future<String> getImage(String docId) async {
    try {
      final imageRef = firestore.collection('image');
      final snapshot = await imageRef.doc(docId).get();
      
      if (!snapshot.exists) {
        throw Exception('Image document tidak ditemukan');
      }

      final data = snapshot.data();
      if (data == null || !data.containsKey('image')) {
        throw Exception('Field image tidak ditemukan');
      }

      return snapshot['image'];
    } catch (error) {
      print('Failed to get image: $error');
      rethrow;
    }
  }

  Future<void> saveOrderToFirestore({
    required String customerName,
    required String customerAddress,
    required String customerNumber,
    required List<Map<String, dynamic>> newOrderItems,
  }) async {
    try {
      if (customerName.trim().isEmpty) {
        throw ArgumentError('Customer name tidak boleh kosong');
      }
      if (newOrderItems.isEmpty) {
        throw ArgumentError('Order items tidak boleh kosong');
      }

      final docId = '${customerName}_$customerNumber'.replaceAll(' ', '_');
      final docRef = firestore.collection('order_notifications').doc(docId);

      await firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        List<Map<String, dynamic>> existingItems = [];

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data['orderItems'] != null) {
            existingItems = List<Map<String, dynamic>>.from(data['orderItems']);
          }
        }

        final allOrderItems = [...existingItems, ...newOrderItems];

        transaction.set(docRef, {
          'customerName': customerName,
          'customerAddress': customerAddress,
          'customerNumber': customerNumber,
          'orderItems': allOrderItems,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      print('Failed to save order: $error');
      rethrow;
    }
  }

  Future<void> clearCurrentCustomerData() async {
    try {
      await firestore
          .collection('temp_order_data')
          .doc('current_customer')
          .delete();
    } catch (e) {
      print("Gagal menghapus current_customer: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getOrderDataWithPagination({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = firestore
          .collection('order_data')
          .orderBy('customerName', descending: false)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (error) {
      print('Failed to fetch paginated order data: $error');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> watchOrderData() {
    return firestore
        .collection('order_data')
        .orderBy('customerName', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    });
  }

  Future<void> batchUpdateOrders(List<Map<String, dynamic>> updates) async {
    if (updates.isEmpty) return;

    try {
      final batch = firestore.batch();
      
      for (var update in updates) {
        if (!update.containsKey('id') || !update.containsKey('data')) {
          throw ArgumentError('Update harus memiliki id dan data');
        }
        
        final docRef = firestore.collection('order_data').doc(update['id']);
        batch.update(docRef, update['data'] as Map<String, dynamic>);
      }

      await batch.commit();
    } catch (error) {
      print('Batch update failed: $error');
      rethrow;
    }
  }

  bool validateOrderItem(Map<String, dynamic> item) {
    try {
      // Cek field yang required
      if (!item.containsKey('productName') || 
          item['productName'].toString().trim().isEmpty) {
        return false;
      }
      
      if (!item.containsKey('quantity')) {
        return false;
      }

      final quantity = item['quantity'];
      if (quantity is! num || quantity <= 0) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFirestoreConnected() async {
    try {
      await firestore
          .collection('order_data')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 3));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> exportAllOrderData() async {
    try {
      final snapshot = await firestore
          .collection('order_data')
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
                'exportedAt': DateTime.now().toIso8601String(),
              })
          .toList();
    } catch (error) {
      print('Failed to export order data: $error');
      rethrow;
    }
  }

  Future<void> cleanupOldOrders(DateTime cutoffDate) async {
    try {
      final snapshot = await firestore
          .collection('order_data')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        print('Cleaned up ${snapshot.docs.length} old orders');
      }
    } catch (error) {
      print('Failed to cleanup old orders: $error');
      rethrow;
    }
  }
}