import 'package:flutter/material.dart';
import 'package:talez/widgets/products_grid.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: ProductsGrid(),
    );
  }
}
