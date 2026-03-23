import 'package:flutter/material.dart';
import '../../../db/database_helper.dart';

class ReportsController extends ChangeNotifier {
  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> reportData = [];
  double totalGeneral = 0;
  double totalGanancias = 0;

  bool loading = false;

  Future<void> loadReport() async {
    if (startDate == null || endDate == null) return;

    loading = true;
    notifyListeners();

    final data = await DatabaseHelper.instance
        .getSalesReport(startDate!, endDate!);

    reportData = List<Map<String, dynamic>>.from(data['report']);
    totalGeneral = data['totalGeneral'];
    totalGanancias = data['totalGanancias'];

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