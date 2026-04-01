import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:valinor_ludoteca_desktop/db/database_helper.dart';

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

  static Future<Map<String, dynamic>> getSalesReport(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.database;

    final reportData = await db.rawQuery('''
      SELECT 
        p.name, 
        SUM(s.quantity) AS total_quantity,
        SUM(s.quantity * p.price) AS total_sales,
        SUM(s.quantity * p.purchasePrice) AS total_cost
      FROM sales s
      JOIN products p ON s.productId = p.id
      WHERE s.date BETWEEN ? AND ?
      GROUP BY p.name
    ''', [start.toIso8601String(), end.toIso8601String()]);

    final totalGeneralQuery = await db.rawQuery('''
      SELECT 
        SUM(s.quantity * p.price) AS totalGeneral,
        SUM(s.quantity * p.purchasePrice) AS totalCost
      FROM sales s
      JOIN products p ON s.productId = p.id
      WHERE s.date BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    final paymentReport = await db.rawQuery('''
      SELECT 
        s.paymentMethod,
        SUM(s.quantity * p.price) AS total
      FROM sales s
      JOIN products p ON s.productId = p.id
      WHERE s.date BETWEEN ? AND ?
      GROUP BY s.paymentMethod
    ''', [start.toIso8601String(), end.toIso8601String()]);

    double totalGeneral = 0;
    double totalCost = 0;

    if (totalGeneralQuery.isNotEmpty) {
      totalGeneral = (totalGeneralQuery.first['totalGeneral'] as num?)?.toDouble() ?? 0;
      totalCost = (totalGeneralQuery.first['totalCost'] as num?)?.toDouble() ?? 0;
    }

    final totalGanancias = totalGeneral - totalCost;

    return {
      'report': reportData,
      'totalGeneral': totalGeneral,
      'totalGanancias': totalGanancias,
      'paymentReport': paymentReport,
    };
  }
}