import 'package:flutter/material.dart';
import 'package:talez/pages/product_detail_page.dart';
import '../core/shopify_service.dart';
import 'package:provider/provider.dart';
import '../core/cart_provider.dart';

class ProductsGrid extends StatefulWidget {
  final bool shrinkWrap;
  final bool scrollable;

  const ProductsGrid({
    super.key,
    this.shrinkWrap = false,
    this.scrollable = true,
  });

  @override
  State<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  bool loading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final list = await ShopifyService.getAllProducts(pageSize: 20);
    setState(() {
      items = list;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (loading) return const Center(child: CircularProgressIndicator());

    return GridView.builder(
      physics: widget.scrollable ? null : const NeverScrollableScrollPhysics(),
      shrinkWrap: widget.shrinkWrap,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: .72,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final node = items[i]["node"];
        final img = node["featuredImage"]?["url"];
        final variants = node["variants"]?["edges"] as List? ?? [];
        final firstVariant = variants.isNotEmpty ? variants[0]["node"] : null;

        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(handle: node["handle"]),
            ),
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: img != null
                      ? Image.network(img, fit: BoxFit.cover, width: double.infinity)
                      : const ColoredBox(color: Colors.black12),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    node["title"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (firstVariant != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${firstVariant["price"]["amount"]} ${firstVariant["price"]["currencyCode"]}"),
                        IconButton(
                          tooltip: "Add to cart",
                          onPressed: () => cart.addVariant(firstVariant["id"]),
                          icon: const Icon(Icons.add_shopping_cart),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
