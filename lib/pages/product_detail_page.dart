import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import '../core/cart_provider.dart';
import '../core/shopify_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String handle;
  const ProductDetailPage({super.key, required this.handle});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? product;
  bool loading = true;
  String? selectedVariantId;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await ShopifyService.getProductByHandle(widget.handle);
    setState(() {
      product = data;
      final variants = (data?["variants"]["edges"] as List?) ?? [];
      if (variants.isNotEmpty) {
        selectedVariantId = variants.first["node"]["id"];
      }
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final p = product!;
    final variants = (p["variants"]["edges"] as List)
        .map((e) => e["node"])
        .toList();

    // Get selected variant data
    final selectedVariant = variants.firstWhere(
      (v) => v["id"] == selectedVariantId,
      orElse: () => variants.first,
    );

    final price =
        "${selectedVariant["price"]["amount"]} ${selectedVariant["price"]["currencyCode"]}";

    // All images
    final images =
        (p["images"] as List<dynamic>?)
            ?.map((e) => e["url"] as String)
            .toList() ??
        [];

    Widget imagesWidget;
    if (images.isNotEmpty) {
      imagesWidget = SizedBox(
        height: 400,
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imgUrl = images[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imgUrl, fit: BoxFit.cover),
              ),
            );
          },
        ),
      );
    } else {
      imagesWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          p["featuredImage"]?["url"] ?? "https://placehold.co/400.png",
          fit: BoxFit.contain,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(p["title"]),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/cart"),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Carousel
            imagesWidget,
            const SizedBox(height: 16),

            // Title
            Text(
              p["title"],
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Price
            Text(
              price,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF5a372d),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Tax info
            Text(
              "Tax included. Shipping calculated at checkout.",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Variant selector
            if (variants.length > 1)
              DropdownButtonFormField<String>(
                value: selectedVariantId,
                items: variants.map<DropdownMenuItem<String>>((v) {
                  final vPrice =
                      "${v["price"]["amount"]} ${v["price"]["currencyCode"]}";
                  return DropdownMenuItem(
                    value: v["id"],
                    child: Text("${v["title"]} • $vPrice"),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedVariantId = v),
                decoration: const InputDecoration(
                  labelText: "Select Variant",
                  border: OutlineInputBorder(),
                ),
              ),
            if (variants.length > 1) const SizedBox(height: 16),

            // Quantity
            Row(
              children: [
                IconButton(
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  quantity.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () => setState(() => quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add to Cart
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: selectedVariantId == null
                    ? null
                    : () {
                        cart.addVariant(selectedVariantId!);
                      },
                child: const Text("Add to Cart"),
              ),
            ),
            const SizedBox(height: 24),

            // Description (HTML)
            Text(
              "Product Description",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Html(
              data: p["descriptionHtml"] ?? "",
              style: {
                "table": Style(
                  backgroundColor: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey),
                  padding: HtmlPaddings.all(0),
                ),
                "tr": Style(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                "td": Style(
                  padding: HtmlPaddings.all(8),
                  border: Border.all(color: Colors.grey.shade300),
                  textOverflow: TextOverflow.visible,
                ),
                "th": Style(
                  padding: HtmlPaddings.all(8),
                  backgroundColor: Colors.grey.shade200,
                  fontWeight: FontWeight.bold,
                  border: Border.all(color: Colors.grey),
                ),
                "p": Style(
                  fontSize: FontSize(16),
                  margin: Margins.only(bottom: 12),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
