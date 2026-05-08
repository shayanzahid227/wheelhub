import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hustler_syn/core/constant/colors.dart';
import 'package:hustler_syn/core/services/data_base_services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebViewScreen extends StatefulWidget {
  final String url;
  final String successUrl;
  final String cancelUrl;

  const StripeWebViewScreen({
    super.key,
    required this.url,
    this.successUrl = 'payment/booking/success',
    this.cancelUrl = 'payment/booking/cancel',
  });

  @override
  State<StripeWebViewScreen> createState() => _StripeWebViewScreenState();
}

class _StripeWebViewScreenState extends State<StripeWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);
            if (url.contains(widget.successUrl)) {
              final uri = Uri.tryParse(url);
              final sessionId = uri?.queryParameters['session_id'];
              if (sessionId != null && sessionId.isNotEmpty) {
                await DatabaseServices().notifyBookingPaymentSuccess(sessionId);
              }
              if (mounted) Get.back(result: 'success');
            } else if (url.contains(widget.cancelUrl)) {
              if (mounted) Get.back(result: 'cancel');
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains(widget.successUrl)) {
              return NavigationDecision.navigate;
            }
            if (request.url.contains(widget.cancelUrl)) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        backgroundColor: backGroundColor,
        elevation: 0,
        title: const Text(
          "Secure Payment",
          style: TextStyle(color: whiteColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: whiteColor),
          onPressed: () => Get.back(result: 'cancel'),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
        ],
      ),
    );
  }
}
