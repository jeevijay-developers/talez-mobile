import 'package:flutter/material.dart';
import 'package:talez/widgets/banner_slider.dart';
import '../core/shopify_service.dart';
import 'products_page.dart';
import 'product_detail_page.dart'; // 👈 make sure you have this

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  Map<String, List<Map<String, dynamic>>> categoryProducts = {
    "Best Selling": [],
    "Cookies": [],
    "Sticks": [],
  };

  Map<String, String?> collectionIds = {
    "Best Selling": null,
    "Cookies": null,
    "Sticks": null,
  };

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final collections = await ShopifyService.getCollections(first: 20);

      for (final c in collections) {
        final title = (c["title"] ?? "").toString().toLowerCase();

        if (title.contains("best")) {
          collectionIds["Best Selling"] = c["id"];
          categoryProducts["Best Selling"] =
              await ShopifyService.getProductsByCollection(c["id"], first: 5);
        }
        if (title.contains("cookie")) {
          collectionIds["Cookies"] = c["id"];
          categoryProducts["Cookies"] =
              await ShopifyService.getProductsByCollection(c["id"], first: 5);
        }
        if (title.contains("stick")) {
          collectionIds["Sticks"] = c["id"];
          categoryProducts["Sticks"] =
              await ShopifyService.getProductsByCollection(c["id"], first: 5);
        }
      }

      setState(() => loading = false);
    } catch (e) {
      debugPrint("Error loading categories: $e");
      setState(() => loading = false);
    }
  }

  Widget _buildCategorySection(
    String title,
    List<Map<String, dynamic>> products,
    String? collectionId,
  ) {
    final displayProducts = products.take(4).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Grid of products (2x2)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final p = displayProducts[index];
              final priceNode =
                  p["variants"]?['edges']?[0]?['node']?['price'] ?? {};
              final price = "From Rs. ${priceNode["amount"] ?? "--"}";

              return GestureDetector(
                onTap: () {
                  // 👈 Navigate to product detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        handle: p["handle"], // pass product handle
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Expanded(
                        flex: 7,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            p["featuredImage"]?["url"] ??
                                "https://placehold.co/200x150.png",
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Title + price
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p["title"] ?? "No Title",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                price,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.brown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // View all button
          if (collectionId != null)
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductsPage(
                        collectionId: collectionId,
                        title: title,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "View all",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const BannerSlider(),
                _buildCategorySection(
                  "Best Selling",
                  categoryProducts["Best Selling"]!,
                  collectionIds["Best Selling"],
                ),
                _buildCategorySection(
                  "Cookies",
                  categoryProducts["Cookies"]!,
                  collectionIds["Cookies"],
                ),
                _buildCategorySection(
                  "Sticks",
                  categoryProducts["Sticks"]!,
                  collectionIds["Sticks"],
                ),
              ],
            ),
    );
  }
}
