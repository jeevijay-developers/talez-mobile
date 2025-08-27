import 'package:flutter/material.dart';
import 'package:talez/widgets/login_button.dart';

class ProfilePageBody extends StatefulWidget {
  const ProfilePageBody({super.key});

  @override
  State<ProfilePageBody> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoginWebView(url: "https://shopify.com/66303361066/account"),
      ),
    );
  }
}
