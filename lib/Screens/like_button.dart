import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
   LikeButton({super.key, required this.isLiked,required this.onTap});

  final bool isLiked;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked ? Icons.favorite: Icons.favorite_border,
        size: 22,
        color: isLiked ? Colors.red : Colors.grey,
      ),
    );
  }
}
