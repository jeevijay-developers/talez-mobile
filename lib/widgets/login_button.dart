import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginWebView extends StatefulWidget {
  final String url; // e.g. https://<your-store>.myshopify.com/account
  const LoginWebView({super.key, required this.url});

  @override
  State<LoginWebView> createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // ✅ Create controller synchronously
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            // 👀 If redirected to /account (after logout), force /login
            if (url.contains("/account") && !url.contains("/login")) {
              _controller.loadRequest(Uri.parse("${widget.url}/login"));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) async {
            setState(() => isLoading = false);

            // Debug: print Shopify HTML to console
            final html = await _controller.runJavaScriptReturningResult(
              "document.body.innerHTML",
            );
            debugPrint("Shopify page HTML: $html");

            // 🧼 Inject cleanup JS
            await _controller.runJavaScript('''
              (function() {
                // Hide Shopify header
                const header = document.querySelector('header, .header, .site-header');
                if (header) header.style.display = 'none';

                // Hide nav/drawer
                const nav = document.querySelector('nav, .drawer, .site-nav');
                if (nav) nav.style.display = 'none';

                // Hide elements with text = "Shop"
                document.querySelectorAll('*').forEach(el => {
                  if (el.innerText && el.innerText.trim().toLowerCase() === 'shop') {
                    el.style.display = 'none';
                  }
                });
              })();
            ''');
          },
        ),
      );

    // ✅ Do async cleanup after controller is ready
    _prepareWebView();
  }

  Future<void> _prepareWebView() async {
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    // Load the initial login page
    await _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
