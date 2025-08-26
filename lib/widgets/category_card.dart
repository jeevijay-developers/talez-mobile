import 'package:flutter/material.dart';
import 'package:talez/pages/collection_produtcs_page.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String img;
  final Map<String, dynamic> collection; // pass the entire collection map

  const CategoryCard({
    super.key,
    required this.title,
    required this.img,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to CollectionProductsPage and pass collection
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollectionProductsPage(
              collection: collection,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                img,
                height: 70,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    "https://placehold.co/150.png",
                    height: 70,
                    width: 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
