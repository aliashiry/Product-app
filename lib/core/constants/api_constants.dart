import 'package:flutter/foundation.dart';

@immutable
class ApiConstants {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '/products';
  static const String productDetailsEndpoint = '/products/';

  // Database constants
  static const String databaseName = 'products_database.db';
  static const int databaseVersion = 1;
  static const String productsTable = 'products';

  const ApiConstants._();
}