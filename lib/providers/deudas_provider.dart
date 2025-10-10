import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class DeudasProvider with ChangeNotifier {
  double _totalEnDeudas = 0.0;

  double get totalEnDeudas => _totalEnDeudas;

  Future<void> cargarTotal() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'deudas',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      _totalEnDeudas = (result.first['total'] as num).toDouble();
    } else {
      _totalEnDeudas = 0.0;
    }

    notifyListeners();
  }

  Future<void> setTotalEnDeudas(double nuevoTotal) async {
    _totalEnDeudas = nuevoTotal;

    final db = await DatabaseHelper.instance.database;
    await db.insert('deudas', {
      'total': _totalEnDeudas,
      'fecha': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

}