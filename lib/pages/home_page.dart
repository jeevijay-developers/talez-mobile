import 'package:flutter/material.dart';
import 'package:talez/widgets/banner_slider.dart';
import 'package:talez/widgets/category_card.dart';
import 'package:talez/widgets/products_grid.dart';
import '../core/shopify_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> collections = [];
  bool loadingCollections = true;

  @override
  void initState() {
    super.initState();
    loadCollections();
  }

  Future<void> loadCollections() async {
    try {
      final result = await ShopifyService.getCollections(first: 6);
      setState(() {
        collections = result;
        loadingCollections = false;
      });
    } catch (e) {
      debugPrint("Error loading collections: $e");
      setState(() => loadingCollections = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Talez"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, "/cart"),
          ),
        ],
      ),
      body: ListView(
        children: [
          // 🔹 Hero Banner Slider
          const BannerSlider(),

          // 🔹 Categories
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Shop by Category",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 120,
            child: loadingCollections
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: collections.length,
                    itemBuilder: (context, i) {
                      final col = collections[i];

                      // ✅ If collection has image, use it. Otherwise, show placeholder from network
                      final imageUrl =
                          (col["image"] != null && col["image"].isNotEmpty)
                          ? col["image"]
                          : "https://placehold.co/150.png";

                      return CategoryCard(
                        title: col["title"] ?? "No Title",
                        img: imageUrl,
                      );
                    },
                  ),
          ),

          // 🔹 Products Grid (latest / featured)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Featured Products",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const ProductsGrid(shrinkWrap: true, scrollable: false),
        ],
      ),

      // 🔹 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, "/categories");
          if (i == 2) Navigator.pushNamed(context, "/profile");
          if (i == 3) Navigator.pushNamed(context, "/cart");
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Categories",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
        ],
      ),
    );
  }
}
