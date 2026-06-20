import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/auth/screens/login/login_screen.dart';
import 'package:wheelhub/auth/viewmodels/auth_viewmodel.dart';
import 'package:wheelhub/auth/widgets/auth_gradient_background.dart';
import 'package:wheelhub/auth/widgets/auth_primary_button.dart';
import 'package:wheelhub/core/constant/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.directions_car_filled_rounded,
      gradient: [Color(0xFF0A2342), Color(0xFF00AEEF)],
      title: 'Buy Your Dream Vehicle',
      subtitle:
          'Browse thousands of verified cars, bikes, buses and SUVs.',
    ),
    _OnboardingPageData(
      icon: Icons.sell_rounded,
      gradient: [Color(0xFF10273D), Color(0xFF3EE0CF)],
      title: 'Sell Your Vehicle Easily',
      subtitle: 'Post your vehicle in minutes and connect with genuine buyers.',
    ),
    _OnboardingPageData(
      icon: Icons.chat_bubble_rounded,
      gradient: [Color(0xFF17253E), Color(0xFF00AEEF)],
      title: 'Chat With Buyers & Sellers',
      subtitle: 'Communicate instantly through the built-in messaging system.',
    ),
    _OnboardingPageData(
      icon: Icons.hub_rounded,
      gradient: [Color(0xFF0B1A32), Color(0xFF3EE0CF)],
      title: 'Welcome to WheelHub',
      subtitle: 'Everything you need to buy and sell vehicles in one place.',
    ),
  ];

  Future<void> _finishOnboarding() async {
    await context.read<AuthViewModel>().completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return AuthGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(color: greyColor),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Padding(
                        key: ValueKey(index),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 12, bottom: 28),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: page.gradient,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.12),
                                      blurRadius: 30,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  page.icon,
                                  size: 120,
                                  color: whiteColor.withValues(alpha: 0.92),
                                ),
                              ),
                            ),
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: whiteColor,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: greyColor,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 28 : 8,
                    decoration: BoxDecoration(
                      color: active ? primaryColor : borderColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: AuthPrimaryButton(
                  label: isLast ? 'Get Started' : 'Next',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;

  const _OnboardingPageData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });
}
