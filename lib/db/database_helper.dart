import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    sqfliteFfiInit();
    final factory = databaseFactoryFfi;

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'valinor.db');

    _database = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 13,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );

    return _database!;
  }

  // ========================
  // 🟢 CREATE DATABASE
  // ========================
  Future<void> _onCreate(Database db, int version) async {
    await _createProducts(db);
    await _createSales(db);
    await _createCash(db);
    await _createNequi(db);
    await _createCajaMayor(db);
    await _createDeudas(db);
    await _createMovimientos(db);
  }

  // ========================
  // 🟡 UPGRADE DATABASE
  // ========================
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE products ADD COLUMN purchasePrice REAL NOT NULL DEFAULT 0'
      );
    }

    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE products ADD COLUMN lote TEXT NOT NULL DEFAULT ""'
      );
    }

    if (oldVersion < 6) {
      await _createCash(db);
    }

    if (oldVersion < 7) {
      await db.execute('ALTER TABLE cash ADD COLUMN fecha TEXT');
    }

    if (oldVersion < 8) {
      await _createNequi(db);
    }

    if (oldVersion < 9) {
      await db.execute('ALTER TABLE nequi ADD COLUMN fecha TEXT');
    }

    if (oldVersion < 10) {
      await _createCajaMayor(db);
    }

    if (oldVersion < 11) {
      await _createDeudas(db);
    }

    if (oldVersion < 12) {
      await db.execute(
        'ALTER TABLE sales ADD COLUMN paymentMethod TEXT DEFAULT "Efectivo"'
      );
    }

    if (oldVersion < 13) {
      await _createMovimientos(db);
    }
  }

  // ========================
  // 🔵 TABLES
  // ========================

  Future<void> _createProducts(Database db) async {
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
  }

  Future<void> _createSales(Database db) async {
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

  Future<void> _createCash(Database db) async {
    await db.execute('''
      CREATE TABLE cash (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        fecha TEXT
      )
    ''');

    await db.insert('cash', {
      'total': 167000.0,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _createNequi(Database db) async {
    await db.execute('''
      CREATE TABLE nequi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        fecha TEXT
      )
    ''');

    await db.insert('nequi', {
      'total': 4000.0,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _createCajaMayor(Database db) async {
    await db.execute('''
      CREATE TABLE caja_mayor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        fecha TEXT
      )
    ''');

    await db.insert('caja_mayor', {
      'total': 0,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _createDeudas(Database db) async {
    await db.execute('''
      CREATE TABLE deudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        fecha TEXT
      )
    ''');

    await db.insert('deudas', {
      'total': 0,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _createMovimientos(Database db) async {
    await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        cuenta TEXT,
        monto REAL,
        motivo TEXT,
        fecha TEXT
      )
    ''');
  }

  Future<Map<String, dynamic>> getSalesReport(DateTime start, DateTime end) async {
    final db = await database;

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
      totalGeneral = (totalGeneralQuery.first['totalGeneral'] as num?)?.toDouble() ?? 0;
      totalCost = (totalGeneralQuery.first['totalCost'] as num?)?.toDouble() ?? 0;
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