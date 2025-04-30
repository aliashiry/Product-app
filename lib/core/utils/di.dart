import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:product_app/core/network/dio_client.dart';
import 'package:product_app/core/network/network.dart';
import 'package:product_app/data/data_sources/product_remote_data_source.dart';
import 'package:product_app/data/data_sources/roduct_local_data_source.dart';
import 'package:product_app/data/repositories/product_repository_impl.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/domain/use_cases/get_all_products.dart';
import 'package:product_app/domain/use_cases/get_product_details.dart';
import 'package:product_app/presentation/manager/product_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton<Dio>(() => DioClient.instance.dio);

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<ProductLocalDataSource>(() => ProductLocalDataSourceImpl());

  // Repository
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetAllProducts(sl()));
  sl.registerLazySingleton(() => GetProductDetails(sl()));

  // Cubit
  sl.registerFactory(() => ProductCubit(
    getAllProducts: sl(),
    getProductDetails: sl(),
  ));
}
