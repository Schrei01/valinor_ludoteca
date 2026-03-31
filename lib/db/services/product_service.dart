

import 'package:valinor_ludoteca_desktop/db/daos/product_dao.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';

class ProductService {
  final ProductDao _dao = ProductDao();

  // Insertar o actualizar producto
  Future<int> insertOrUpdate(Product product) async {
    final existing = await _dao.getByName(product.name);

    if (existing != null) {
      final newQuantity = existing.quantity + product.quantity;

      if (newQuantity < 0) {
        throw Exception("Stock no puede quedar en negativo.");
      }

      final updated = existing.copyWith(
        quantity: newQuantity,
        price: product.price,
        purchasePrice: product.purchasePrice,
        lote: product.lote,
      );

      return _dao.update(updated);
    } else {
      return _dao.insert(product);
    }
  }

  // Obtener productos con cantidad > 0
  Future<List<Product>> getAvailable() async {
    return _dao.getAvailable();
  }

  // Obtener todos los productos (para inventario o búsqueda)
  Future<List<Product>> getAll() async {
    return _dao.getAll();
  }

  // Eliminar producto
  Future<int> delete(int id) async {
    return _dao.delete(id);
  }
}