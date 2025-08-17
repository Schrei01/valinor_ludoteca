import 'package:flutter/material.dart';
import 'package:valinor_ludoteca_desktop/models/saleline.dart';
import 'package:valinor_ludoteca_desktop/screens/ventas_screen.dart';

// ✅ Asegúrate de importar tus modelos
// import 'models/account.dart';
// import 'models/sale_line.dart';
// import 'models/product.dart';

class AccountsProvider extends ChangeNotifier {
  final List<Account> _accounts = [Account()];

  List<Account> get accounts => _accounts;

  /// Agregar nueva cuenta
  void addAccount() {
    _accounts.add(Account());
    notifyListeners();
  }

  /// Eliminar una cuenta
  void removeAccount(int index) {
    if (index >= 0 && index < _accounts.length) {
      _accounts.removeAt(index);
      notifyListeners();
    }
  }

  /// Agregar línea de venta a una cuenta
  void addSaleLine(int accountIndex) {
    if (accountIndex >= 0 && accountIndex < _accounts.length) {
      _accounts[accountIndex].saleLines.add(SaleLine());
      updateTotal(accountIndex); // recalcular total
    }
  }

  /// Eliminar línea de venta
  void removeSaleLine(int accountIndex, int saleLineIndex) {
    if (accountIndex >= 0 && accountIndex < _accounts.length) {
      if (saleLineIndex >= 0 &&
          saleLineIndex < _accounts[accountIndex].saleLines.length) {
        _accounts[accountIndex].saleLines.removeAt(saleLineIndex);
        updateTotal(accountIndex); // recalcular total
      }
    }
  }

  /// Recalcular total de una cuenta
  void updateTotal(int accountIndex) {
    if (accountIndex >= 0 && accountIndex < _accounts.length) {
      final account = _accounts[accountIndex];
      account.total = _calculateTotal(account.saleLines);
      notifyListeners();
    }
  }

  /// Función privada para calcular totales
  double _calculateTotal(List<SaleLine> saleLines) {
    return saleLines.fold(
      0.0,
      (sum, line) {
        final quantity = int.tryParse(line.quantityController.text) ?? 0;
        return sum + (quantity * (line.product?.price ?? 0));
      },
    );
  }

}
