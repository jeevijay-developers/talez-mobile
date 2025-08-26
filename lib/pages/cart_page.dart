import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/cart_provider.dart';

class CartPageBody extends StatefulWidget {
  const CartPageBody({super.key});

  @override
  State<CartPageBody> createState() => _CartPageBodyState();
}

class _CartPageBodyState extends State<CartPageBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().refresh();
    });
  }

  Future<void> _openCheckout(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Open in default browser
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot open checkout URL")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error opening checkout: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    final checkoutUrl = cartProvider.checkoutUrl;

    if (cart == null || cart["lines"]["edges"].isEmpty) {
      return const Center(child: Text("Your cart is empty"));
    }

    return ListView(
      padding: const EdgeInsets.all(12).copyWith(bottom: 12),
      children: [
        ...((cart["lines"]["edges"] as List).map((e) {
          final node = e["node"];
          final lineId = node["id"];
          final qty = node["quantity"];
          final merch = node["merchandise"];
          final title = merch["product"]["title"];
          final vTitle = merch["title"];
          final img = merch["product"]["featuredImage"]?["url"];
          final price =
              "${merch["price"]["amount"]} ${merch["price"]["currencyCode"]}";

          return Card(
            child: ListTile(
              leading: img != null
                  ? Image.network(img, width: 56, height: 56, fit: BoxFit.cover)
                  : const Icon(Icons.image),
              title: Text(title),
              subtitle: Text("$vTitle • $price"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      final newQty = qty > 1 ? qty - 1 : 1;
                      context.read<CartProvider>().changeQty(lineId, newQty);
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text("$qty"),
                  IconButton(
                    onPressed: () {
                      context.read<CartProvider>().changeQty(lineId, qty + 1);
                    },
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: () =>
                        context.read<CartProvider>().removeLine(lineId),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          );
        })),
        const SizedBox(height: 12),
        if (cart["cost"] != null)
          Text(
            "Subtotal: ${cart["cost"]["subtotalAmount"]["amount"]} ${cart["cost"]["subtotalAmount"]["currencyCode"]}",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: checkoutUrl == null
              ? null
              : () => _openCheckout(checkoutUrl),
          icon: const Icon(Icons.lock),
          label: const Text("Checkout (Secure)"),
        ),
      ],
    );
  }
}
