import 'package:flutter/material.dart';
import '../../../db/database_helper.dart';

class ReportsController extends ChangeNotifier {
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

  Future<void> loadReport() async {
    if (startDate == null || endDate == null) return;

    loading = true;
    notifyListeners();

    final db = DatabaseHelper.instance;

    final data = await db.getSalesReport(startDate!, endDate!);

    reportData = List<Map<String, dynamic>>.from(data['report']);
    totalGeneral = data['totalGeneral'];
    totalGanancias = data['totalGanancias'];

    // 🟡 Caja y Nequi inicial (histórico)
    cajaInicio = await db.getCajaBefore(startDate!);
    nequiInicio = await db.getNequiBefore(startDate!);
    egresos = await db.getEgresos(startDate!, endDate!);

    // 🔥 INGRESOS POR MÉTODO DE PAGO (AQUÍ ESTÁ LA CLAVE)
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