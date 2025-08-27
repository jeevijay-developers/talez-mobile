// Fetch shop metafield for banner image URL

import 'dart:convert';
import 'package:http/http.dart' as http;

class ShopifyService {
  static const _shopDomain = "4q5r21-1n.myshopify.com";
  static const _apiVersion = "2024-07";
  static const _token = "f75e033d31ed97b47fd6115947c28f65";

  static Uri get _endpoint =>
      Uri.https(_shopDomain, "/api/$_apiVersion/graphql.json");

  static Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "X-Shopify-Storefront-Access-Token": _token,
  };

  static Future<Map<String, dynamic>> _post(String body) async {
    final res = await http.post(_endpoint, headers: _headers, body: body);
    if (res.statusCode != 200) {
      throw Exception("Shopify error ${res.statusCode}: ${res.body}");
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json["errors"] != null) {
      throw Exception(json["errors"]);
    }
    return json;
  }

  static Future<Map<String, dynamic>> runQuery(
    String query, {
    Map<String, dynamic>? variables,
  }) {
    return _post(jsonEncode({"query": query, "variables": variables}));
  }

  // -------- PRODUCTS --------

  static const _productsQuery = r'''
  query Products($first: Int!, $cursor: String) {
    products(first: $first, after: $cursor) {
      edges {
        cursor
        node {
          id
          title
          descriptionHtml   # CHANGED
          handle
          featuredImage { url }
          variants(first: 10) {
            edges {
              node {
                id
                title
                availableForSale
                price { amount currencyCode }
              }
            }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
''';

  static Future<List<dynamic>> getAllProducts({int pageSize = 20}) async {
    List<dynamic> allProducts = [];
    String? cursor;
    bool hasNextPage = true;

    while (hasNextPage) {
      final data = await runQuery(
        _productsQuery,
        variables: {"first": pageSize, "cursor": cursor},
      );

      final products = data["data"]["products"]["edges"] as List;
      allProducts.addAll(products);

      final pageInfo = data["data"]["products"]["pageInfo"];
      hasNextPage = pageInfo["hasNextPage"];
      cursor = pageInfo["endCursor"];
    }

    return allProducts;
  }


  static Future<Map<String, dynamic>?> getProductByHandle(String handle) async {
    const query = r'''
    query Product($handle: String!, $imagesCursor: String) {
      product(handle: $handle) {
        id
        title
        descriptionHtml
        featuredImage { url }
        images(first: 50, after: $imagesCursor) {
          edges { node { url } cursor }
          pageInfo { hasNextPage endCursor }
        }
        variants(first: 10) {
          edges {
            node {
              id
              title
              availableForSale
              price { amount currencyCode }
            }
          }
        }
      }
    }
  ''';

    List<Map<String, dynamic>> allImages = [];
    String? cursor;
    bool hasNextPage = true;
    Map<String, dynamic>? product;

    while (hasNextPage) {
      final data = await runQuery(
        query,
        variables: {"handle": handle, "imagesCursor": cursor},
      );
      product ??= data["data"]["product"];
      final imagesData = product!["images"];
      final edges = imagesData["edges"] as List<dynamic>;
      allImages.addAll(edges.map((e) => e["node"] as Map<String, dynamic>));
      final pageInfo = imagesData["pageInfo"];
      hasNextPage = pageInfo["hasNextPage"];
      cursor = pageInfo["endCursor"];
    }

    if (product != null) {
      product["images"] = allImages; // replace images with all fetched
    }

    return product;
  }

  // -------- COLLECTIONS --------

  static const _collectionsQuery = r'''
  query Collections($first: Int!) {
    collections(first: $first) {
      edges {
        node {
          id
          title
          handle
          image{
          url
          altText
          }
        }
      }
    }
  }
''';

  static Future<List<Map<String, dynamic>>> getCollections({
    int first = 10,
  }) async {
    final data = await runQuery(_collectionsQuery, variables: {"first": first});

    final collections = data["data"]["collections"]["edges"] as List;
    return collections
        .map((edge) => edge["node"] as Map<String, dynamic>)
        .toList();
  }

  // -------- CART & CHECKOUT --------

  static const _cartCreateMutation = r'''
    mutation CreateCart {
      cartCreate {
        cart {
          id
          checkoutUrl
        }
        userErrors { field message }
      }
    }
  ''';

  static Future<Map<String, dynamic>> createCart() async {
    final data = await runQuery(_cartCreateMutation);
    return data["data"]["cartCreate"]["cart"];
  }

  static const _cartQuery = r'''
    query Cart($cartId: ID!) {
      cart(id: $cartId) {
        id
        checkoutUrl
        cost { subtotalAmount { amount currencyCode } totalAmount { amount currencyCode } }
        lines(first: 50) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
                  id
                  title
                  product { title featuredImage { url } }
                  price { amount currencyCode }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static Future<Map<String, dynamic>?> getCart(String cartId) async {
    final data = await runQuery(_cartQuery, variables: {"cartId": cartId});
    return data["data"]["cart"];
  }

  static const _cartLinesAdd = r'''
    mutation CartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
      cartLinesAdd(cartId: $cartId, lines: $lines) {
        cart { id checkoutUrl }
        userErrors { field message }
      }
    }
  ''';

  static Future<void> addToCart({
    required String cartId,
    required String variantId,
    int quantity = 1,
  }) async {
    await runQuery(
      _cartLinesAdd,
      variables: {
        "cartId": cartId,
        "lines": [
          {"merchandiseId": variantId, "quantity": quantity},
        ],
      },
    );
  }

  static const _cartLinesUpdate = r'''
    mutation CartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
      cartLinesUpdate(cartId: $cartId, lines: $lines) {
        cart { id }
        userErrors { field message }
      }
    }
  ''';

  static Future<void> updateLine({
    required String cartId,
    required String lineId,
    required int quantity,
  }) async {
    await runQuery(
      _cartLinesUpdate,
      variables: {
        "cartId": cartId,
        "lines": [
          {"id": lineId, "quantity": quantity},
        ],
      },
    );
  }

  static const _cartLinesRemove = r'''
    mutation CartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
      cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
        cart { id }
        userErrors { field message }
      }
    }
  ''';

  static Future<void> removeLines({
    required String cartId,
    required List<String> lineIds,
  }) async {
    await runQuery(
      _cartLinesRemove,
      variables: {"cartId": cartId, "lineIds": lineIds},
    );
  }

  static const _productsByCollectionQuery = r'''
query ProductsByCollection($collectionId: ID!, $first: Int!) {
  collection(id: $collectionId) {
    products(first: $first) {
      edges {
        node {
          id
          title
          handle
          featuredImage { url }
          variants(first: 10) {
            edges {
              node {
                id
                title
                price { amount currencyCode }
              }
            }
          }
        }
      }
    }
  }
}
''';

  static Future<List<Map<String, dynamic>>> getProductsByCollection(
    String collectionId, {
    int first = 50,
  }) async {
    final data = await runQuery(
      _productsByCollectionQuery,
      variables: {"collectionId": collectionId, "first": first},
    );

    final edges =
        data["data"]["collection"]?["products"]?["edges"] as List? ?? [];
    return edges.map((e) => e["node"] as Map<String, dynamic>).toList();
  }

  static Future<String?> getShopBannerImageUrl({
    String namespace = "custom",
    String key = "banner_image_url",
  }) async {
    const String query = r'''
      query GetShopBannerImageMetafield($namespace: String!, $key: String!) {
        shop {
          metafield(namespace: $namespace, key: $key) {
            value
          }
        }
      }
    ''';
    final variables = {"namespace": namespace, "key": key};
    final response = await runQuery(query, variables: variables);
    return response['data']?['shop']?['metafield']?['value'];
  }
}
