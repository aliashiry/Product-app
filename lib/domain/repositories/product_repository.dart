import 'package:dartz/dartz.dart';
import 'package:product_app/core/errors/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, Product>> getProductDetails(int id);
}