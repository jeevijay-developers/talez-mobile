import 'package:flutter/material.dart';
import 'package:talez/pages/collection_produtcs_page.dart';

import '../core/shopify_service.dart';

class ProductsPage extends StatefulWidget {
  final String collectionId;
  final String title;

  const ProductsPage({
    super.key,
    required this.collectionId,
    required this.title,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final result = await ShopifyService.getProductsByCollection(
      widget.collectionId,
    );
    setState(() {
      products = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) {
                

                return CollectionProductsPage(collection: {},
                  
                );
              },
            ),
    );
  }
}
