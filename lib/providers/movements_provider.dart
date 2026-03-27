import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/db/database_helper.dart';

class MovementsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _movimientos = [];

  List<Map<String, dynamic>> get movimientos => _movimientos;

  Future<void> cargarMovimientos() async {
    _movimientos = List<Map<String, dynamic>>.from(
      await DatabaseHelper.instance.getLastMovimientos(),
    );
    notifyListeners();
  }

  Future<void> agregarMovimiento({
    required String tipo,
    required String cuenta,
    required double monto,
    required String motivo,
  }) async {
    notifyListeners();
    await DatabaseHelper.instance.insertMovimiento(
      tipo: tipo,
      cuenta: cuenta,
      monto: monto,
      motivo: motivo,
    );
    await cargarMovimientos();
  }
}