import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talez/pages/main_screen.dart';
import 'core/cart_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talez',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Color(0xFF5a372d)),
      routes: {
        "/": (_) => const MainScreen(),
        
      },
    );
  }
}
