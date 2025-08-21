import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:valinor_ludoteca_desktop/models/products.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'valinor.db');

    _database = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2, // subimos versión para que corra onUpgrade
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );

    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        purchasePrice REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
  }

  Future<Product?> getProductByName(String name) async {
    final db = await instance.database;

    final maps = await db.query(
      'products',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    } else {
      return null;
    }
  }


  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN purchasePrice REAL NOT NULL DEFAULT 0');
    }
  
  }

    // Insertar producto
  Future<int> insertOrUpdateProduct(Product product, {String? password}) async {
  final db = await instance.database;

  final existingProduct = await getProductByName(product.name);

  if (existingProduct != null) {
    // Sumar cantidades
    final newQuantity = existingProduct.quantity + product.quantity;

    if (newQuantity < 0) {
      // Si el resultado es negativo también protegemos
      throw Exception("El stock no puede quedar en negativo.");
    }

    return await db.update(
      'products',
      {
        'quantity': newQuantity,
        'price': product.price,
        'purchasePrice': product.purchasePrice,
      },
      where: 'id = ?',
      whereArgs: [existingProduct.id],
    );
  } else {
    // Insertar nuevo producto
    return await db.insert('products', product.toMap());
  }
}



  // Obtener lista de productos
  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final maps = await db.query('products');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insertar venta
  Future<int> insertSale(int productId, int quantity, String date) async {
    final db = await instance.database;

    // 1. Insertar venta
    final id = await db.insert('sales', {
      'productId': productId,
      'quantity': quantity,
      'date': date,
    });

    // 2. Actualizar stock del producto
    await db.rawUpdate('''
      UPDATE products
      SET quantity = quantity - ?
      WHERE id = ? AND quantity >= ?
    ''', [quantity, productId, quantity]);

    return id;
  }

  // Obtener todos los productos con stock > 0 (para vender)
  Future<List<Product>> getAvailableProducts() async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      where: 'quantity > 0',
    );
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> getSalesReport(DateTime start, DateTime end) async {
    final db = await instance.database;

    final reportData = await db.rawQuery('''
      SELECT 
        p.name, 
        SUM(s.quantity) AS total_quantity,
        SUM(s.quantity * p.price) AS total_sales,
        SUM(s.quantity * p.purchasePrice) AS total_cost
      FROM sales s
      JOIN products p ON s.productId = p.id
      WHERE s.date BETWEEN ? AND ?
      GROUP BY p.name
    ''', [start.toIso8601String(), end.toIso8601String()]);

    final totalGeneralQuery = await db.rawQuery('''
      SELECT 
        SUM(s.quantity * p.price) AS totalGeneral,
        SUM(s.quantity * p.purchasePrice) AS totalCost
      FROM sales s
      JOIN products p ON s.productId = p.id
      WHERE s.date BETWEEN ? AND ?
    ''', [start.toIso8601String(), end.toIso8601String()]);

    double totalGeneral = 0;
    double totalCost = 0;

    if (totalGeneralQuery.isNotEmpty) {
      if (totalGeneralQuery.first['totalGeneral'] != null) {
        totalGeneral = (totalGeneralQuery.first['totalGeneral'] as num).toDouble();
      }
      if (totalGeneralQuery.first['totalCost'] != null) {
        totalCost = (totalGeneralQuery.first['totalCost'] as num).toDouble();
      }
    }

    final totalGanancias = totalGeneral - totalCost;

    return {
      'report': reportData,
      'totalGeneral': totalGeneral,
      'totalGanancias': totalGanancias,
    };
  }

  }
