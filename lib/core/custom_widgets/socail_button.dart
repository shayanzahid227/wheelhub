import 'package:flutter/material.dart';

Widget socialButton(String title, String iconPath) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Image.asset(iconPath, width: 20, height: 20),
        const SizedBox(width: 8),
        Text(title),
      ],
    ),
  );
}
