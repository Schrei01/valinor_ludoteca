import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/db/services/finance_service.dart';
import 'package:valinor_ludoteca_desktop/db/services/sales_service.dart';

class ReportsController extends ChangeNotifier {
  final SalesService _salesService = SalesService();
  final FinanceService _financeService = FinanceService();

  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> reportData = [];
  double totalGeneral = 0;
  double totalGanancias = 0;
  double cajaInicio = 0;
  double nequiInicio = 0;

  double ingresosCaja = 0;
  double ingresosNequi = 0;

  double egresos = 0;

  bool loading = false;

  /// 🔹 Carga todo el reporte
  Future<void> loadReport() async {
    if (startDate == null || endDate == null) return;

    loading = true;
    notifyListeners();

    // 🔹 Traer datos de ventas
    final data = await _salesService.getReport(startDate!, endDate!);

    reportData = List<Map<String, dynamic>>.from(data['report']);
    totalGeneral = data['totalGeneral'];
    totalGanancias = data['totalGanancias'];

    // 🔹 Caja y Nequi inicial (histórico)
    cajaInicio = await _financeService.getCajaBefore(startDate!);
    nequiInicio = await _financeService.getNequiBefore(startDate!);

    // 🔹 Egresos
    egresos = await _financeService.getEgresos(startDate!, endDate!);

    // 🔹 INGRESOS POR MÉTODO DE PAGO
    double efectivo = 0;
    double nequi = 0;

    if (data['paymentReport'] != null) {
      for (var row in data['paymentReport']) {
        final rawMethod = row['paymentMethod'];
        if (rawMethod == null) continue;

        final method = rawMethod.toString().trim().toLowerCase();
        final total = (row['total'] as num?)?.toDouble() ?? 0;

        if (method == 'efectivo') {
          efectivo += total;
        } else if (method == 'nequi') {
          nequi += total;
        }
      }
    }

    ingresosCaja = efectivo;
    ingresosNequi = nequi;

    loading = false;
    notifyListeners();
  }

  /// 🔹 Setters con validación de fechas
  void setStartDate(DateTime date) {
    startDate = date;
    if (endDate != null && endDate!.isBefore(date)) {
      endDate = date;
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    if (startDate != null && startDate!.isAfter(date)) {
      startDate = date;
    }
    notifyListeners();
  }
}