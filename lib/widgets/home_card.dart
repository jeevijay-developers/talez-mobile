import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String imagePath;
  final String subtitle;
  final String mainTitleStart;
  final String mainTitleBold;
  final String mainTitleEnd;
  final String description;
  final VoidCallback onPressed;
  final String buttonText;

  const HomeCard({
    super.key,
    required this.imagePath,
    required this.subtitle,
    required this.mainTitleStart,
    required this.mainTitleBold,
    required this.mainTitleEnd,
    required this.description,
    required this.onPressed,
    this.buttonText = 'Order Now',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // Subtitle
            Text(
              subtitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Title with RichText
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$mainTitleStart\n",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: mainTitleBold,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: " $mainTitleEnd",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Button
            Center(
              child: OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
