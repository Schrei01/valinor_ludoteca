import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SalesDao {

  /// Insertar venta dentro de una transacción
  static Future<int> insert(
    Transaction txn, {
    required int productId,
    required int quantity,
    required String paymentMethod,
    required String date,
  }) async {
    return await txn.insert('sales', {
      'productId': productId,
      'quantity': quantity,
      'paymentMethod': paymentMethod,
      'date': date,
    });
  }

  /// Descontar stock dentro de la misma transacción
  static Future<void> discountStock(
    Transaction txn,
    int productId,
    int quantity,
  ) async {
    final updated = await txn.rawUpdate('''
      UPDATE products
      SET quantity = quantity - ?
      WHERE id = ? AND quantity >= ?
    ''', [quantity, productId, quantity]);

    if (updated == 0) {
      throw Exception("Stock insuficiente");
    }
  }
}