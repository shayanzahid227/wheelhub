import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/auth/repository/auth_repository.dart';
import 'package:wheelhub/auth/screens/forgot_password/forgot_password_screen.dart';
import 'package:wheelhub/auth/screens/signup/signup_screen.dart';
import 'package:wheelhub/auth/viewmodels/auth_viewmodel.dart';
import 'package:wheelhub/auth/widgets/auth_gradient_background.dart';
import 'package:wheelhub/auth/widgets/auth_logo.dart';
import 'package:wheelhub/auth/widgets/auth_primary_button.dart';
import 'package:wheelhub/auth/widgets/auth_text_field.dart';
import 'package:wheelhub/core/constant/colors.dart';
import 'package:wheelhub/screens/root/root_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AuthViewModel>();
    _emailController = TextEditingController(text: vm.email);
    _passwordController = TextEditingController(text: vm.password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final vm = context.read<AuthViewModel>();
    final result = await vm.login();

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Login successful'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const RootScreen()));
    } else if (result.message != null &&
        vm.emailError == null &&
        vm.passwordError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message!),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return AuthGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Center(child: AuthLogo(size: 84)),
                const SizedBox(height: 28),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.poppins(
                    color: whiteColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue exploring vehicles on WheelHub.',
                  style: GoogleFonts.poppins(color: greyColor, height: 1.5),
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  label: 'Email',
                  hint: 'example@example.com',
                  controller: _emailController,
                  errorText: vm.emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: vm.updateEmail,
                ),
                const SizedBox(height: 18),
                AuthTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  errorText: vm.passwordError,
                  obscureText: vm.obscurePassword,
                  textInputAction: TextInputAction.done,
                  onChanged: vm.updatePassword,
                  onSubmitted: (_) => _handleLogin(),
                  suffixIcon: IconButton(
                    onPressed: vm.togglePasswordVisibility,
                    icon: Icon(
                      vm.obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: greyColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: vm.rememberMe,
                      onChanged: (value) => vm.setRememberMe(value ?? false),
                      activeColor: primaryColor,
                      side: const BorderSide(color: borderColor),
                    ),
                    Text(
                      'Remember Me',
                      style: GoogleFonts.poppins(color: whiteColor),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(color: primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AuthPrimaryButton(
                  label: 'Login',
                  isLoading: vm.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: lightBackGroundColor.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    'Demo: ${AuthRepository.demoEmail} / ${AuthRepository.demoPassword}',
                    style: GoogleFonts.poppins(color: greyColor, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(color: borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: GoogleFonts.poppins(color: greyColor),
                      ),
                    ),
                    const Expanded(child: Divider(color: borderColor)),
                  ],
                ),
                const SizedBox(height: 24),
                AuthSocialButton(
                  label: 'Continue with Google',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Google sign-in is UI only for this MVP.',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(color: greyColor),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign Up',
                            style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
