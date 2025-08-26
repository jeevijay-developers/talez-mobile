import 'package:flutter/material.dart';
import 'shopify_service.dart';

class CartProvider extends ChangeNotifier {
  String? _cartId;
  String? _checkoutUrl;
  Map<String, dynamic>? _cart;

  Map<String, dynamic>? get cart => _cart;
  String? get checkoutUrl => _checkoutUrl;

  /// Ensure cart exists
  Future<void> _ensureCart() async {
    if (_cartId != null) return;
    final newCart = await ShopifyService.createCart();
    _cartId = newCart["id"];
    _checkoutUrl = newCart["checkoutUrl"];
    _cart = newCart;
    notifyListeners();
  }

  /// Refresh cart state from Shopify
  Future<void> refresh() async {
    await _ensureCart();
    final latest = await ShopifyService.getCart(_cartId!);
    if (latest != null) {
      _cart = latest;
      _checkoutUrl = latest["checkoutUrl"];
      notifyListeners();
    }
  }

  /// Add product variant
  Future<void> addItem(String variantId, {int quantity = 1}) async {
    await _ensureCart();
    await ShopifyService.addToCart(
      cartId: _cartId!,
      variantId: variantId,
      quantity: quantity,
    );
    await refresh();
  }

  /// Change quantity of an existing line
  Future<void> changeQty(String lineId, int quantity) async {
    if (_cartId == null) return;
    await ShopifyService.updateLine(
      cartId: _cartId!,
      lineId: lineId,
      quantity: quantity,
    );
    await refresh();
  }

  /// Remove line item
  Future<void> removeLine(String lineId) async {
    if (_cartId == null) return;
    await ShopifyService.removeLines(cartId: _cartId!, lineIds: [lineId]);
    await refresh();
  }
}
