import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wheelhub/auth/viewmodels/auth_viewmodel.dart';
import 'package:wheelhub/auth/widgets/auth_gradient_background.dart';
import 'package:wheelhub/auth/widgets/auth_primary_button.dart';
import 'package:wheelhub/auth/widgets/auth_text_field.dart';
import 'package:wheelhub/core/constant/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: context.read<AuthViewModel>().forgotEmail,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    final vm = context.read<AuthViewModel>();
    if (!vm.validateForgotPassword()) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: planCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Email Sent',
          style: GoogleFonts.poppins(
            color: whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'A password reset link has been sent to ${vm.forgotEmail.trim()}.',
          style: GoogleFonts.poppins(color: greyColor, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: primaryColor),
            ),
          ),
        ],
      ),
    );
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forgot Password',
                  style: GoogleFonts.poppins(
                    color: whiteColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email and we will send you a reset link.',
                  style: GoogleFonts.poppins(color: greyColor, height: 1.5),
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailController,
                  errorText: vm.forgotEmailError,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: vm.updateForgotEmail,
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: 'Send Reset Link',
                  onPressed: _sendResetLink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
