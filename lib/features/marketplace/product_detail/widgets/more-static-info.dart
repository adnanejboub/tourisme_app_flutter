import 'package:flutter/material.dart';

class MoreStaticInfo extends StatelessWidget {
  const MoreStaticInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            const Text(
              'More product info and reviews\ncoming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
