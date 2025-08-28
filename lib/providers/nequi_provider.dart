import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/db/database_helper.dart';

class NequiProvider with ChangeNotifier {
  double _totalEnNequi = 0;

  double get totalEnNequi => _totalEnNequi;

  /// Cargar el valor desde la BD al iniciar
  Future<void> cargarNequi() async {
    final db = await DatabaseHelper.instance.database;

    // Traer el último registro insertado (id más alto)
    final result = await db.query(
      'nequi',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      _totalEnNequi = (result.first['total'] as num).toDouble();
    } else {
      _totalEnNequi = 4000; // valor inicial
      await db.insert('nequi', {
        'total': _totalEnNequi,
        'fecha': DateTime.now().toIso8601String(),
      });
    }

    notifyListeners();
  }

  /// Sumar una venta
  Future<void> agregarVenta(double monto) async {
    _totalEnNequi += monto;

    final db = await DatabaseHelper.instance.database;

    await db.insert('nequi', {
      'total': _totalEnNequi,
      'fecha': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }
}
