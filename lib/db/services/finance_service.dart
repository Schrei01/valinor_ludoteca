import '../daos/finance_dao.dart';

class FinanceService {
  final FinanceDao _dao = FinanceDao();

  Future<void> registrarIngreso({
    required String cuenta,
    required double monto,
    required String motivo,
  }) async {
    await _dao.insertMovimiento(
      tipo: 'ingreso',
      cuenta: cuenta,
      monto: monto,
      motivo: motivo,
    );
  }

  Future<void> registrarEgreso({
    required String cuenta,
    required double monto,
    required String motivo,
  }) async {
    await _dao.insertMovimiento(
      tipo: 'egreso',
      cuenta: cuenta,
      monto: monto,
      motivo: motivo,
    );
  }

  Future<List<Map<String, dynamic>>> getMovimientos() {
    return _dao.getLastMovimientos();
  }

  Future<Map<String, double>> getResumen() {
    return _dao.getFinancialSummary();
  }

  Future<double> getCajaBefore(DateTime date) async {
    return await _dao.getCajaBefore(date);
  }

  Future<double> getNequiBefore(DateTime date) async {
    return await _dao.getNequiBefore(date);
  }

  Future<double> getEgresos(DateTime start, DateTime end) async {
    return await _dao.getEgresos(start, end);
  }
}