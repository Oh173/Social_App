import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
   MyListTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,

  });

  final IconData icon;
  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 11.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        onTap:onTap ,
        title: Text(
          text,
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }
}
