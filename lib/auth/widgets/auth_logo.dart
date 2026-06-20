import 'package:flutter/material.dart';
import 'package:wheelhub/core/constant/colors.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.25),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: primaryColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'images/icons_assets/app_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.directions_car_filled_rounded,
            color: primaryColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
