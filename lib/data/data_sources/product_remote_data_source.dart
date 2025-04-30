import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductDetails(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await dio.get(ApiConstants.productsEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to load products');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    try {
      final response = await dio.get('${ApiConstants.productDetailsEndpoint}$id');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to load product details');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: ${e.toString()}');
    }
  }
}
