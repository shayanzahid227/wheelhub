import 'package:flutter/material.dart';

class AuthGradientBackground extends StatelessWidget {
  const AuthGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071428),
            Color(0xFF0B1A32),
            Color(0xFF102A45),
          ],
        ),
      ),
      child: child,
    );
  }
}
