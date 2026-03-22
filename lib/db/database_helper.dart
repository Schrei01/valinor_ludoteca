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
        version: 13,
        onCreate: (db, version) async {
          await _createDB(db, version);
          await _createDBCaja(db, version);
          await _createDBNequi(db, version);
          await _createDBCajaMayor(db, version);
          await _createDBDeudas(db, version);
          await _createDBMovimientos(db, version);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _upgradeDB(db, oldVersion, newVersion);
        },
      ),
    );

    return _database!;
  }

  Future _createDBMovimientos(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT, -- ingreso / egreso / transferencia
        cuenta TEXT,
        monto REAL,
        motivo TEXT,
        fecha TEXT
      )
    ''');
  }

  Future _createDBNequi(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS nequi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL
      )
    ''');

    // Insertar registro inicial con total 4000
    await db.insert('nequi', {'total': 4000.0});
  }

  Future _createDBCajaMayor(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS caja_mayor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        fecha TEXT
      )
    ''');
  }

  Future _createDBDeudas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS deudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        fecha TEXT
      )
    ''');
  }

  Future _createDBCaja(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cash (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL
      )
    ''');

    // Insertar registro inicial con total 0
    await db.insert('cash', {'total': 167000.0});
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        purchasePrice REAL NOT NULL DEFAULT 0,
        lote TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        paymentMethod TEXT NOT NULL,
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
      await db.execute(
        'ALTER TABLE products ADD COLUMN purchasePrice REAL NOT NULL DEFAULT 0'
      );
    }

    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE products ADD COLUMN lote TEXT NOT NULL DEFAULT '''
      );
    }

    if (oldVersion < 6) {
      // 👇 1. crear la tabla si no existe
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cash (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          total REAL NOT NULL
        )
      ''');

      // 👇 2. verificar si hay registros
      final result = await db.query('cash');
      if (result.isEmpty) {
        await db.insert('cash', {'total': 167000});
      } else {
        await db.update('cash', {'total': 167000}, where: 'id = 1');
      }
    }

    if (oldVersion < 7) {
      // Agregar columna "fecha" a la tabla cash
      await db.execute('ALTER TABLE cash ADD COLUMN fecha TEXT');

      // Actualizar los registros existentes con fecha actual
      await db.update('cash', {
        'fecha': DateTime.now().toIso8601String(),
      });
    }

    if (oldVersion < 8) {
      // Crear la tabla nequi si vienes de una versión anterior
      await _createDBNequi(db, newVersion);
    }

    if (oldVersion < 9) {
      await db.update('nequi', {
        'fecha': DateTime.now().toIso8601String(),
      });
    }

    if (oldVersion < 10) {
      // Crear nueva tabla "caja_mayor"
      await _createDBCajaMayor(db, newVersion);
    }

    // Insertar registro inicial si está vacía
    final result = await db.query('caja_mayor');
    if (result.isEmpty) {
      await db.insert('caja_mayor', {
        'total': 0,
        'fecha': DateTime.now().toIso8601String(),
      });
    }

    if (oldVersion < 11) {
      // Crear nueva tabla "caja_mayor"
      await _createDBDeudas(db, newVersion);
    }

    if (oldVersion < 12) {
      await db.execute(
        'ALTER TABLE sales ADD COLUMN paymentMethod TEXT DEFAULT "Efectivo"'
      );
    }

    if (oldVersion < 13) {
      await _createDBMovimientos(db, newVersion);
    }

    // Insertar registro inicial si está vacía
    final result1 = await db.query('deudas');
    if (result1.isEmpty) {
      await db.insert('deudas', {
        'total': 0,
        'fecha': DateTime.now().toIso8601String(),
      });
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
        'lote': product.lote,
      },
      where: 'id = ?',
      whereArgs: [existingProduct.id],
    );
  } else {
    // Insertar nuevo producto
    return await db.insert('products', product.toMap(includeId: true));
  }
}

  // Obtener lista de productos (solo los que tienen cantidad > 0)
  Future<List<Product>> getProducts() async {
    final db = await instance.database;

    final maps = await db.query(
      'products',
      where: 'quantity > ?',
      whereArgs: [0],
    );

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

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products'); // 👈 sin WHERE quantity > 0
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // Insertar venta
  Future<int> insertSale(
      int productId, 
      int quantity, 
      String paymentMethod,
      String date, 
    ) async {
    final db = await instance.database;

    // 1. Insertar venta
    final id = await db.insert('sales', {
      'productId': productId,
      'quantity': quantity,
      'paymentMethod': paymentMethod,
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

  Future<void> insertMovimiento({
    required String tipo,
    required String cuenta,
    required double monto,
    required String motivo,
  }) async {
    final db = await instance.database;

    await db.insert('movimientos', {
      'tipo': tipo,
      'cuenta': cuenta,
      'monto': monto,
      'motivo': motivo,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getLastMovimientos() async {
    final db = await instance.database;

    final result = await db.query(
      'movimientos',
      orderBy: 'fecha DESC',
      limit: 10,
    );

    return result;
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

    final paymentReport = await db.rawQuery('''
      SELECT 
        s.paymentMethod,
        SUM(s.quantity * p.price) AS total
      FROM sales s
      JOIN products p ON s.productId = p.id
      WHERE s.date BETWEEN ? AND ?
      GROUP BY s.paymentMethod
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
      'paymentReport': paymentReport,
    };
  }

}
