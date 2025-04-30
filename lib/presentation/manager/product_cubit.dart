import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_app/domain/use_cases/get_all_products.dart';
import 'package:product_app/domain/use_cases/get_product_details.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetAllProducts getAllProducts;
  final GetProductDetails getProductDetails;

  ProductCubit({
    required this.getAllProducts,
    required this.getProductDetails,
  }) : super(ProductInitial());

  Future<void> fetchProducts() async {
    emit(ProductsLoading());

    final result = await getAllProducts();
    result.fold(
          (failure) => emit(ProductError(failure.message)),
          (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> fetchProductDetails(int productId) async {
    emit(ProductDetailsLoading());

    final result = await getProductDetails(productId);
    result.fold(
          (failure) => emit(ProductError(failure.message)),
          (product) => emit(ProductDetailsLoaded(product)),
    );
  }
}