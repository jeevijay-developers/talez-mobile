import 'package:flutter/material.dart';
import 'package:talez/pages/collection_produtcs_page.dart';
import '../core/shopify_service.dart';

class CategoriesPageBody extends StatefulWidget {
  const CategoriesPageBody({super.key});

  @override
  State<CategoriesPageBody> createState() => _CategoriesPageBodyState();
}

class _CategoriesPageBodyState extends State<CategoriesPageBody> {
  List<Map<String, dynamic>> collections = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCollections();
  }

  Future<void> loadCollections() async {
    try {
      final data = await ShopifyService.getCollections(first: 50);
      setState(() {
        collections = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading collections: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (collections.isEmpty) {
      return const Center(child: Text("No categories found"));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final col = collections[index];

          final imageUrl = (col["image"] != null && col["image"]["url"] != null)
              ? col["image"]["url"]
              : null;

          return GestureDetector(
            onTap: () {
              // Navigate to CollectionProductsPage directly
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CollectionProductsPage(collection: col),
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
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // On network error, fallback to asset image
                                return Image.asset(
                                  "assets/images/placeholder.png",
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              "assets/images/logo.png",
                              fit: BoxFit.cover,
                              color: Colors.grey.shade800,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      col["title"] ?? "No Title",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
