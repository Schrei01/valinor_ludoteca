import 'package:valinor_ludoteca_desktop/db/database_helper.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';

class ProductDao {
  Future<Product?> getByName(String name) async {
    final db = await DatabaseHelper.instance.database;

    final maps = await db.query(
      'products',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  Future<int> insert(Product product) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('products', product.toMap(includeId: true));
  }

  Future<int> update(Product product) async {
    final db = await DatabaseHelper.instance.database;

    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<Product>> getAvailable() async {
    final db = await DatabaseHelper.instance.database;

    final maps = await db.query(
      'products',
      where: 'quantity > 0',
    );

    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<List<Product>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;

    return db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}