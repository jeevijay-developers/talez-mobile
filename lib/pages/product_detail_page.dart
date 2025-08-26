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
  String? selectedVariantId;
  int quantity = 1;
  bool loading = true;
  bool showFullDescription = false;

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  Future<void> loadProduct() async {
    try {
      final data = await ShopifyService.getProductByHandle(widget.handle);
      final variants = data?["variants"]?["edges"] ?? [];

      setState(() {
        product = data;
        if (variants.isNotEmpty) {
          selectedVariantId = variants[0]["node"]["id"];
        }
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading product: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      return const Scaffold(body: Center(child: Text("❌ Product not found")));
    }

    final title = product?["title"] ?? "No Title";
    final description = product?["descriptionHtml"] ?? ""; // ✅ fixed
    final images = (product?["images"] ?? [])
        .map<String>((img) => img["url"] as String)
        .toList(); // ✅ fixed

    final variants = product?["variants"]?["edges"] ?? [];
    final selectedVariant = variants.firstWhere(
      (v) => v["node"]["id"] == selectedVariantId,
      orElse: () => variants.isNotEmpty ? variants[0] : null,
    );

    final price = selectedVariant?["node"]?["price"]?["amount"] ?? "--";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Image Carousel (uses first if none)
            if (images.isNotEmpty)
              Hero(
                tag: widget.handle,
                child: Image.network(
                  images.first,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            else
              Image.network(
                "https://placehold.co/600x400.png",
                fit: BoxFit.cover,
                width: double.infinity,
              ),

            const SizedBox(height: 12),

            // 🔹 Title + Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    "₹$price",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Variants
            if (variants.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: variants.map<Widget>((v) {
                    final node = v["node"];
                    final isSelected = node["id"] == selectedVariantId;
                    return ChoiceChip(
                      label: Text(node["title"]),
                      selected: isSelected,
                      checkmarkColor: Colors.white,
                      selectedColor: Colors.brown,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      onSelected: (_) {
                        setState(() => selectedVariantId = node["id"]);
                      },
                    );
                  }).toList(),
                ),
              ),

            if (variants.length > 1) const SizedBox(height: 16),

            // 🔹 Quantity Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    "Quantity",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => quantity++);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Add to Cart Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: selectedVariantId == null
                      ? null
                      : () async {
                          await Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).addItem(selectedVariantId!, quantity: quantity);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("✅ $title added to cart"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  label: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Description (trimmed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Product Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  AnimatedCrossFade(
                    firstChild: Html(
                      data: description,
                      style: {
                        "body": Style(
                          maxLines: 3,
                          textOverflow: TextOverflow.ellipsis,
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(14),
                          lineHeight: LineHeight.number(1.4),
                        ),
                      },
                    ),
                    secondChild: Html(
                      data: description,
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(14),
                          lineHeight: LineHeight.number(1.4),
                        ),
                      },
                    ),
                    crossFadeState: showFullDescription
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),

                  Center(
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showFullDescription = !showFullDescription;
                          });
                        },
                        child: Text(
                          showFullDescription ? "View Less" : "View More",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
