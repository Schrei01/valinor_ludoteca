import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/db/database_helper.dart';

class MovementsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _movimientos = [];

  List<Map<String, dynamic>> get movimientos => _movimientos;

  Future<void> cargarMovimientos() async {
    _movimientos = await DatabaseHelper.instance.getLastMovimientos();
    notifyListeners();
  }

  Future<void> agregarMovimiento({
    required String tipo,
    required String cuenta,
    required double monto,
    required String motivo,
  }) async {

    final nuevoMovimiento = {
      'tipo': tipo,
      'cuenta': cuenta,
      'monto': monto,
      'motivo': motivo,
      'fecha': DateTime.now().toIso8601String(),
    };

    // 🔥 1. ACTUALIZA UI INMEDIATAMENTE
    _movimientos.insert(0, nuevoMovimiento);
    notifyListeners();

    // 🔹 2. GUARDA EN BD (en segundo plano)
    await DatabaseHelper.instance.insertMovimiento(
      tipo: tipo,
      cuenta: cuenta,
      monto: monto,
      motivo: motivo,
    );
  }
}