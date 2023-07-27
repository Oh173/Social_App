import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  const CommentButton({super.key, this.onTap});
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.comment,
        color: Colors.grey,
        size: 22,
      ),
    );
  }
}
