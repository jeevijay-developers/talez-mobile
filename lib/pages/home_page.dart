import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:talez/pages/collection_produtcs_page.dart';
import 'package:talez/widgets/banner_slider.dart';
import 'package:talez/widgets/home_card.dart';
import '../core/shopify_service.dart';
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
                  log("handle ---> ${p["handle"]}");
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
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                price,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF5a372d),
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
                  backgroundColor: Color(0xFF5a372d),
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
                      builder: (_) => CollectionProductsPage(
                        collection: {"id": collectionId, "title": title},
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
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const BannerSlider(),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF5a372d),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: height / 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Baked by",
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: " Talez,",
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: " Loved by",
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: " India",
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "From oven to heart, our cookies are more than just sweet treats. They’re little bundles of joy—organic, crunchy, unforgettable.",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                  _buildCategorySection(
                    "Best Selling",
                    categoryProducts["Best Selling"]!,
                    collectionIds["Best Selling"],
                  ),
                  SizedBox(height: 16),
                  HomeCard(
                    imagePath: 'assets/images/powerseed.png',
                    subtitle: 'POWER SEED',
                    mainTitleStart: 'Energize your day with',
                    mainTitleBold: 'Power Seed',
                    mainTitleEnd: 'Cookies',
                    description:
                        'A delicious, wholesome treat packed with a powerhouse of seeds, all crafted in a 100% butter and palm oil-free recipe.',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                            handle: 'power-seed',
                          ), // 👈 product handle
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  HomeCard(
                    imagePath: 'assets/images/coconutcookies.jpg',
                    subtitle: 'COCONUT MACROON COOKIES',
                    mainTitleStart: 'Delight in Every Bite with',
                    mainTitleBold: 'Coconut Macroon',
                    mainTitleEnd: 'Cookies',
                    description:
                        'Handmade with care, these cholesterol-free cookies offer a perfect crunch with a soft, chewy center ',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                            handle: 'talez-coconut-macaroons-cookies',
                          ), // 👈 product handle
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
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
      ),
    );
  }
}
