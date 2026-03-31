import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/db/services/finance_service.dart';

class MovementsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _movimientos = [];

  List<Map<String, dynamic>> get movimientos => _movimientos;

  Future<void> cargarMovimientos() async {
    final financeService = FinanceService();
    _movimientos = List<Map<String, dynamic>>.from(
      await financeService.getMovimientos(),
    );
    notifyListeners();
  }

  Future<void> agregarMovimiento({
    required String tipo,
    required String cuenta,
    required double monto,
    required String motivo,
  }) async {
    final financeService = FinanceService();
    notifyListeners();
    await financeService.registrarIngreso(
      cuenta: cuenta,
      monto: monto,
      motivo: motivo,
    );
    await cargarMovimientos();
  }
}