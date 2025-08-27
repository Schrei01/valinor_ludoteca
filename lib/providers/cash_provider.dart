import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/db/database_helper.dart'; // tu clase de conexión a BD

class CashProvider with ChangeNotifier {
  double _totalEnCaja = 0;

  double get totalEnCaja => _totalEnCaja;

  

  /// Cargar el valor desde la BD al iniciar
  Future<void> cargarCaja() async {
    final db = await DatabaseHelper.instance.database;

    // Traer el último registro insertado (id más alto)
    final result = await db.query(
      'cash',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      _totalEnCaja = (result.first['total'] as num).toDouble();
    } else {
      _totalEnCaja = 0;
      await db.insert('cash', {
        'total': 0,
        'fecha': DateTime.now().toIso8601String(),
      });
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

  // 1. Obtener el último registro (el más reciente)
  final result = await db.query(
    'cash',
    orderBy: 'id DESC',
    limit: 1,
  );

  if (result.isNotEmpty) {
      double currentTotal = (result.first['total'] as num).toDouble();

      // 2. Restar 40,000
      double newTotal = currentTotal - 40000;

      // 3. Insertar un NUEVO registro con el nuevo total y fecha actual
      await db.insert('cash', {
        'total': newTotal,
        'fecha': DateTime.now().toIso8601String(),
      });

      // 4. Actualizar variable local
      _totalEnCaja = newTotal;

      notifyListeners();
    }
  }

}
