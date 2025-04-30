import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_app/core/utils/di.dart';
import 'package:product_app/presentation/manager/product_cubit.dart';
import 'package:product_app/presentation/manager/product_state.dart';
import 'package:product_app/presentation/pages/product_details_page.dart';
import '../widgets/product_list_item.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) =>  sl<ProductCubit>()..fetchProducts(),
        child: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            if (state is ProductInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProductCubit>().fetchProducts();
                },
                child: ListView.builder(
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return ProductListItem(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BlocProvider.value(
                                  value: sl<ProductCubit>(),
                                  child: ProductDetailsPage(
                                    productId: product.id,
                                  ),
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            } else if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductCubit>().fetchProducts();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }
}