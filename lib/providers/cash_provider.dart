import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/db/database_helper.dart'; // tu clase de conexión a BD

class CashProvider with ChangeNotifier {
  double _totalEnCaja = 0;

  double get totalEnCaja => _totalEnCaja;

  

  /// Cargar el valor desde la BD al iniciar
  Future<void> cargarCaja() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query('cash', limit: 1);

    if (result.isNotEmpty) {
      _totalEnCaja = result.first['total'] as double;
    } else {
      _totalEnCaja = 0;
      await db.insert('cash', {'total': 0});
    }
    notifyListeners();
  }

  /// Sumar una venta
  Future<void> agregarVenta(double monto) async {
    _totalEnCaja += monto;

    final db = await DatabaseHelper.instance.database;

    await db.update(
      'cash',
      {'total': _totalEnCaja},
      where: 'id = 1',
    );

    notifyListeners();
  }

  /// Resetear caja si lo necesitas
  Future<void> discountByHosting() async {
    final db = await DatabaseHelper.instance.database;

    // 1. Obtener el valor actual en caja
    final result = await db.query('cash', where: 'id = ?', whereArgs: [1], limit: 1);

    if (result.isNotEmpty) {
      double currentTotal = (result.first['total'] as num).toDouble();

      // 2. Restar 40,000
      double newTotal = currentTotal - 40000;

      // 3. Actualizar en base de datos
      await db.update(
        'cash',
        {'total': newTotal},
        where: 'id = ?',
        whereArgs: [1],
      );

      // 4. Refrescar variable local si la tienes (ejemplo: _totalEnCaja)
      _totalEnCaja = newTotal;

      notifyListeners();
    }
  }
}
