import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String username;
  final String memberSince;
  final String contributions;
  const ProfileInfo({
    Key? key,
    this.username = 'adnane',
    this.memberSince = 'Member since 2025',
    this.contributions = '0 contribution',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          username,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          memberSince,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          contributions,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
