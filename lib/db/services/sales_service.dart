import 'package:valinor_ludoteca_desktop/db/daos/sales_dao.dart';
import 'package:valinor_ludoteca_desktop/db/database_helper.dart';

class SalesService {
  final dbHelper = DatabaseHelper.instance;

  Future<void> registerSale({
    required int productId,
    required int quantity,
    required String paymentMethod,
  }) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      await SalesDao.insert(
        txn,
        productId: productId,
        quantity: quantity,
        paymentMethod: paymentMethod,
        date: DateTime.now().toIso8601String(),
      );

      await SalesDao.discountStock(txn, productId, quantity);
    });
  }

  Future<Map<String, dynamic>> getReport(DateTime start, DateTime end) async {
    return await dbHelper.getSalesReport(start, end);
  }
}