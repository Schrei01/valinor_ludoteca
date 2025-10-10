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

    await db.insert('cash', {
      'total': _totalEnCaja,
      'fecha': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  /// Establecer un nuevo total (por ejemplo, para transferencias)
  Future<void> setTotalEnCaja(double nuevoTotal) async {
    _totalEnCaja = nuevoTotal;

    final db = await DatabaseHelper.instance.database;
    await db.insert('cash', {
      'total': _totalEnCaja,
      'fecha': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

}
