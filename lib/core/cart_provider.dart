import 'package:flutter/foundation.dart';
import 'shopify_service.dart';

class CartProvider extends ChangeNotifier {
  String? _cartId;
  String? _checkoutUrl;
  Map<String, dynamic>? _cart;

  String? get cartId => _cartId;
  String? get checkoutUrl => _checkoutUrl;
  Map<String, dynamic>? get cart => _cart;

  Future<void> ensureCart() async {
    if (_cartId != null) return;
    final cart = await ShopifyService.createCart();
    _cartId = cart["id"];
    _checkoutUrl = cart["checkoutUrl"];
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_cartId == null) return;
    _cart = await ShopifyService.getCart(_cartId!);
    _checkoutUrl = _cart?["checkoutUrl"] ?? _checkoutUrl;
    notifyListeners();
  }

  Future<void> addVariant(String variantId, {int qty = 1}) async {
    await ensureCart();
    await ShopifyService.addToCart(cartId: _cartId!, variantId: variantId, quantity: qty);
    await refresh();
  }

  Future<void> changeQty(String lineId, int qty) async {
    await ShopifyService.updateLine(cartId: _cartId!, lineId: lineId, quantity: qty);
    await refresh();
  }

  Future<void> removeLine(String lineId) async {
    await ShopifyService.removeLines(cartId: _cartId!, lineIds: [lineId]);
    await refresh();
  }
}
