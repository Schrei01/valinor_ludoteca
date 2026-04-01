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
    double? monto,
    String? motivo,
    String? cuentaDestino, 
  }) async {
    final financeService = FinanceService();
    notifyListeners();

    final tipoLower = tipo.toLowerCase();

    if (tipoLower == 'egreso') {
      await financeService.registrarEgreso(
        cuenta: cuenta,
        monto: monto!,
        motivo: motivo!,
      );
    } else if (tipoLower == 'ingreso') {
      await financeService.registrarIngreso(
        cuenta: cuenta,
        monto: monto!,
        motivo: motivo!,
      );
    } else if (tipoLower == 'transferencia') {
      if (cuentaDestino == null) {
        throw Exception('Para transferencias se requiere la cuenta destino');
      }
      await financeService.registerTransfer(
        cuentaOrigen: cuenta,
        cuentaDestino: cuentaDestino,
        monto: monto!,
        motivo: motivo!,
      );
    } else {
      throw Exception('Tipo de movimiento desconocido: $tipo');
    }

    await cargarMovimientos();
  }
}