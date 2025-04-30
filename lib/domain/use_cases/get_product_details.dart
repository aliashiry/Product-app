import 'package:dartz/dartz.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../core/errors/failures.dart';

class GetProductDetails {
  final ProductRepository repository;

  GetProductDetails(this.repository);

  Future<Either<Failure, Product>> call(int id) {
    return repository.getProductDetails(id);
  }
}
