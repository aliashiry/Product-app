import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getLastProducts();

  Future<ProductModel> getLastProductDetails(int id);

  Future<void> cacheProducts(List<ProductModel> products);

  Future<void> cacheProductDetails(ProductModel product);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, ApiConstants.databaseName);

    return await openDatabase(
      path,
      version: ApiConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${ApiConstants.productsTable} (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        image TEXT NOT NULL,
        rating TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<List<ProductModel>> getLastProducts() async {
    try {
      final db = await database;
      final maps = await db.query(ApiConstants.productsTable);

      if (maps.isNotEmpty) {
        return maps.map((map) => ProductModel.fromMap(map)).toList();
      } else {
        throw CacheException(message: 'No cached products found');
      }
    } catch (e) {
      throw CacheException(message: 'Failed to get cached products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getLastProductDetails(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        ApiConstants.productsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return ProductModel.fromMap(maps.first);
      } else {
        throw CacheException(message: 'No cached product found with id: $id');
      }
    } catch (e) {
      throw CacheException(message: 'Failed to get cached product details: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final db = await database;
      final batch = db.batch();

      // Clear existing products
      batch.delete(ApiConstants.productsTable);

      // Insert new products
      for (var product in products) {
        batch.insert(
          ApiConstants.productsTable,
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException(message: 'Failed to cache products: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheProductDetails(ProductModel product) async {
    try {
      final db = await database;
      await db.insert(
        ApiConstants.productsTable,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache product details: ${e.toString()}');
    }
  }
}