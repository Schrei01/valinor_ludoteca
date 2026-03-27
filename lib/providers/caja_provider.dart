import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class CajaMayorProvider with ChangeNotifier {
  double _totalEnCajaMayor = 0.0;

  double get totalEnCajaMayor => _totalEnCajaMayor;

  Future<void> cargarTotal() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'caja_mayor',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      _totalEnCajaMayor = (result.first['total'] as num).toDouble();
    } else {
      _totalEnCajaMayor = 0.0;
    }

    notifyListeners();
  }

  Future<void> agregarVenta(double monto) async {
    final db = await DatabaseHelper.instance.database;
    _totalEnCajaMayor += monto;

    await db.insert('caja_mayor', {
      'total': _totalEnCajaMayor,
      'fecha': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  Future<void> setTotalEnCajaMayor(double nuevoTotal) async {
    _totalEnCajaMayor = nuevoTotal;

    final db = await DatabaseHelper.instance.database;
    await db.insert('caja_mayor', {
      'total': _totalEnCajaMayor,
      'fecha': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }
}
