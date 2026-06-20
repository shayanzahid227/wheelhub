import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/auth/models/user.dart';
import 'package:wheelhub/auth/screens/login/login_screen.dart';
import 'package:wheelhub/auth/screens/onboarding/onboarding_screen.dart';
import 'package:wheelhub/auth/viewmodels/auth_viewmodel.dart';
import 'package:wheelhub/auth/widgets/auth_gradient_background.dart';
import 'package:wheelhub/auth/widgets/auth_logo.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/screens/root/root_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final destination =
        await context.read<AuthViewModel>().getInitialDestination();

    if (!mounted) return;

    final Widget nextScreen = switch (destination) {
      AuthDestination.onboarding => const OnboardingScreen(),
      AuthDestination.login => const LoginScreen(),
      AuthDestination.home => const RootScreen(),
    };

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AuthLogo(size: 110),
                  const SizedBox(height: 24),
                  Text(
                    'WheelHub',
                    style: GoogleFonts.poppins(
                      color: whiteColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buy & Sell Vehicles',
                    style: GoogleFonts.poppins(
                      color: greyColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
