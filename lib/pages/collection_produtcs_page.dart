import 'package:flutter/material.dart';
import 'package:talez/pages/product_detail_page.dart';
import '../core/shopify_service.dart';

class CollectionProductsPage extends StatefulWidget {
  final Map<String, dynamic> collection;
  const CollectionProductsPage({super.key, required this.collection});

  @override
  State<CollectionProductsPage> createState() => _CollectionProductsPageState();
}

class _CollectionProductsPageState extends State<CollectionProductsPage> {
  List<Map<String, dynamic>> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => loading = true);
    try {
      final data = await ShopifyService.getProductsByCollection(
        widget.collection["id"],
      );
      setState(() {
        products = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading products: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.collection["title"] ?? "Collection")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(child: Text("No products found"))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final imageUrl =
                      product["featuredImage"]?["url"] ??
                      "https://placehold.co/200x150.png";

                  // Fix for price
                  final priceNode = product["variants"]?["edges"]?[0]?["node"];
                  final priceText = priceNode != null
                      ? "${priceNode["price"]["amount"]} ${priceNode["price"]["currencyCode"]}"
                      : "";

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailPage(handle: product["handle"]),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    "https://placehold.co/200x150.png",
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  product["title"] ?? "No Title",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  priceText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5a372d),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
