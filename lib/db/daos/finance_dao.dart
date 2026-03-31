import 'package:valinor_ludoteca_desktop/db/database_helper.dart';

class FinanceDao {
  Future<void> insertMovimiento({
    required String tipo,
    required String cuenta,
    required double monto,
    required String motivo,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert('movimientos', {
      'tipo': tipo,
      'cuenta': cuenta,
      'monto': monto,
      'motivo': motivo,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<double> getEgresos(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT SUM(monto) as total
      FROM movimientos
      WHERE tipo = 'egreso'
      AND fecha BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }

    return 0;
  }

  Future<List<Map<String, dynamic>>> getLastMovimientos() async {
    final db = await DatabaseHelper.instance.database;

    return await db.query(
      'movimientos',
      orderBy: 'fecha DESC',
      limit: 10,
    );
  }

  Future<Map<String, double>> getFinancialSummary() async {
    final db = await DatabaseHelper.instance.database;

    final cash = await db.query('cash', orderBy: 'id DESC', limit: 1);
    final nequi = await db.query('nequi', orderBy: 'id DESC', limit: 1);
    final cajaMayor = await db.query('caja_mayor', orderBy: 'id DESC', limit: 1);
    final deudas = await db.query('deudas', orderBy: 'id DESC', limit: 1);

    return {
      'Caja': (cash.isNotEmpty ? cash.first['total'] as num : 0).toDouble(),
      'Nequi': (nequi.isNotEmpty ? nequi.first['total'] as num : 0).toDouble(),
      'Caja Mayor': (cajaMayor.isNotEmpty ? cajaMayor.first['total'] as num : 0).toDouble(),
      'Deudas': (deudas.isNotEmpty ? deudas.first['total'] as num : 0).toDouble(),
    };
  }

  Future<double> getCajaBefore(DateTime date) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT total FROM cash
      WHERE fecha <= ?
      ORDER BY fecha DESC
      LIMIT 1
    ''', [date.toIso8601String()]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }

    return 0;
  }

  Future<double> getNequiBefore(DateTime date) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT total FROM nequi
      WHERE fecha <= ?
      ORDER BY fecha DESC
      LIMIT 1
    ''', [date.toIso8601String()]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }

    return 0;
  }
}