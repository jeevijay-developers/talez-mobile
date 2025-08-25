import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final checkoutUrl = context.watch<CartProvider>().checkoutUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart == null
          ? const Center(child: Text("Cart is empty"))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ...((cart["lines"]["edges"] as List).map((e) {
                  final node = e["node"];
                  final lineId = node["id"];
                  final qty = node["quantity"];
                  final merch = node["merchandise"];
                  final title = merch["product"]["title"];
                  final vTitle = merch["title"];
                  final img = merch["product"]["featuredImage"]?["url"];
                  final price = "${merch["price"]["amount"]} ${merch["price"]["currencyCode"]}";

                  return Card(
                    child: ListTile(
                      leading: img != null ? Image.network(img, width: 56, height: 56, fit: BoxFit.cover) : null,
                      title: Text(title),
                      subtitle: Text("$vTitle • $price"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () {
                            final newQty = qty > 1 ? qty - 1 : 1;
                            context.read<CartProvider>().changeQty(lineId, newQty);
                          }, icon: const Icon(Icons.remove)),
                          Text("$qty"),
                          IconButton(onPressed: () {
                            context.read<CartProvider>().changeQty(lineId, qty + 1);
                          }, icon: const Icon(Icons.add)),
                          IconButton(onPressed: () => context.read<CartProvider>().removeLine(lineId),
                            icon: const Icon(Icons.delete_outline)),
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
                  onPressed: checkoutUrl == null ? null : () async {
                    final uri = Uri.parse(checkoutUrl);
                    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.lock),
                  label: const Text("Checkout (Secure)"),
                ),
              ],
            ),
    );
  }
}
