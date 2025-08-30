import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onEdit;
  const ProfileAvatar({Key? key, this.imageUrl, this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
              : null,
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.edit, size: 20, color: Colors.blueAccent),
              onPressed: onEdit ?? () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}
