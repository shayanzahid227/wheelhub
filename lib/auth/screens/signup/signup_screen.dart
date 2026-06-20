import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/auth/viewmodels/auth_viewmodel.dart';
import 'package:wheelhub/auth/widgets/auth_gradient_background.dart';
import 'package:wheelhub/auth/widgets/auth_logo.dart';
import 'package:wheelhub/auth/widgets/auth_primary_button.dart';
import 'package:wheelhub/auth/widgets/auth_text_field.dart';
import 'package:wheelhub/core/constant/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AuthViewModel>();
    _nameController = TextEditingController(text: vm.fullName);
    _emailController = TextEditingController(text: vm.email);
    _phoneController = TextEditingController(text: vm.phoneNumber);
    _passwordController = TextEditingController(text: vm.password);
    _confirmPasswordController = TextEditingController(
      text: vm.confirmPassword,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final vm = context.read<AuthViewModel>();
    final result = await vm.signup();

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Account created'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (result.message != null &&
        vm.fullNameError == null &&
        vm.emailError == null &&
        vm.phoneError == null &&
        vm.passwordError == null &&
        vm.confirmPasswordError == null) {
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: AuthLogo(size: 72)),
                const SizedBox(height: 24),
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    color: whiteColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join WheelHub and start buying or selling vehicles today.',
                  style: GoogleFonts.poppins(color: greyColor, height: 1.5),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Full Name',
                  hint: 'Shayan Zahid',
                  controller: _nameController,
                  errorText: vm.fullNameError,
                  onChanged: vm.updateFullName,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Email',
                  hint: 'example@example.com',
                  controller: _emailController,
                  errorText: vm.emailError,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: vm.updateEmail,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Phone Number',
                  hint: '+92 300 1234567',
                  controller: _phoneController,
                  errorText: vm.phoneError,
                  keyboardType: TextInputType.phone,
                  onChanged: vm.updatePhoneNumber,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Password',
                  hint: 'Minimum 6 characters',
                  controller: _passwordController,
                  errorText: vm.passwordError,
                  obscureText: vm.obscurePassword,
                  onChanged: vm.updatePassword,
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
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter password',
                  controller: _confirmPasswordController,
                  errorText: vm.confirmPasswordError,
                  obscureText: vm.obscureConfirmPassword,
                  onChanged: vm.updateConfirmPassword,
                  suffixIcon: IconButton(
                    onPressed: vm.toggleConfirmPasswordVisibility,
                    icon: Icon(
                      vm.obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: greyColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: 'Sign Up',
                  isLoading: vm.isLoading,
                  onPressed: _handleSignup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
