import 'package:valinor_ludoteca_desktop/db/services/sales_service.dart';
import 'package:valinor_ludoteca_desktop/screens/sales/models/account.dart';

class SalesController{
  final SalesService _salesService = SalesService();

  // 🔹 Validación
  String? validateAccount(Account account) {
    for (var line in account.saleLines) {
      final quantity = int.tryParse(line.quantityController.text.trim());
      final product = line.product;
      final paymentMethod = line.paymentMethod;

      if (product == null) return 'Selecciona un producto en todas las líneas';
      if (quantity == null || quantity <= 0) return 'Cantidad inválida en alguna línea';
      if (quantity > product.quantity) {
        return 'Cantidad mayor al stock disponible en ${product.name}';
      }
      if (paymentMethod == null) return 'Selecciona un medio de pago en todas las líneas';
    }
    return null;
  }

  // 🔹 Guardar ventas
  Future<List<double>> saveSales(Account account) async {
    List<double> lineTotals = [];

    for (var line in account.saleLines) {
      final quantity = int.parse(line.quantityController.text.trim());
      final product = line.product!;
      final paymentMethod = line.paymentMethod!;
      final totalLine = quantity * product.price;

      lineTotals.add(totalLine);

      await _salesService.registerSale(
        productId: product.id!,
        quantity: quantity,
        paymentMethod: paymentMethod,
      );
    }

    return lineTotals;
  }

  // 🔹 Limpieza
  void clearAccount(Account account) {
    for (var line in account.saleLines) {
      line.quantityController.clear();
      line.product = null;
    }
    account.total = 0;
  }

  // 🔹 Método principal
  Future<Map<String, dynamic>> registerSale(Account account) async {
    final error = validateAccount(account);

    if (error != null) {
      return {
        'hasError': true,
        'message': error,
        'totals': [],
      };
    }

    final totals = await saveSales(account);

    clearAccount(account);

    return {
      'hasError': false,
      'message': 'Venta registrada correctamente',
      'totals': totals,
    };
  }
}

