class ApiEndPoints {
  // Production / Vercel
  static String baseUrl = "https://hustler-sync-backend.vercel.app";

  // REAL DEVICE (phone/tablet) – Mac ka IP same WiFi pe use karein:
  // Terminal: ifconfig | grep "inet "  → jo 192.168.x.x dikhe woh yahan likhein
  // static String baseUrl = "http://192.168.18.6:5050"; // ← aapka Mac IP

  // Emulator / Simulator (real device pe run nahi kar rahe to ye use karein):
  // static String baseUrl = "http://10.0.2.2:5050";   // Android emulator
  // static String baseUrl = "http://localhost:5050";  // iOS Simulator

  static String registerClient = "/api/auth/register-client";
  static String registerHustler = "/api/auth/register-hustler";
  static String loginUser = "/api/auth/login";
  static String forgotPassword = "/api/auth/forgot-password";
  static String getProfile = "/api/profile";
  static String updateProfile = "/api/profile";

  // Notifications (FCM) – register token, send to self (testing)
  static String registerFcmToken = "/api/notifications/register-token";
  static String sendNotificationToSelf = "/api/notifications/send";

  ///
  ///. updated profile
  ///
  static String updateClientProfile = "/api/client/profile";
  static String updateHustlerProfile = "/api/hustler/profile";
  static String addHustlerServiceForHustler = "/api/hustlers/hustler-services";
  static String getAllCategories = "/api/hustler-services";
  static String getCategorieId = "/api/hustler-services";
  static String getAllHustlers = "/api/hustlers";
  static String getAllClients = "/api/clients";
  static String getServiceProvidersByCategory =
      "/api/service-provider-by-category";
  static String jobPosts = "/api/hustler-finding-posts";
  static String createSubscriptionSession =
      "/api/payments/subscription-plan/create-session";
  static String currentSubscriptionPlan = "/api/current-subscription-plan";
  static String billingHistory = "/api/billing-history";

  // Booking payment (Stripe Checkout) endpoint
  static String createBookingPaymentSession =
      "/api/payments/booking/create-session";

  /// Backend success callback – call this after Stripe redirects so order is marked paid (required for release-funds).
  static String bookingPaymentSuccessCallback(String sessionId) =>
      "/api/payment/booking/success?session_id=$sessionId";

  // Client orders: pending, release funds, all/completed
  static String getClientOrdersPending = "/api/client/orders/pending";
  static String releaseFunds(String orderId) =>
      "/api/client/orders/$orderId/release-funds";
  static String cancelOrder(String orderId) =>
      "/api/client/orders/$orderId/cancel";
  static String getClientOrders = "/api/client/orders";

  // Hustler orders (tasks): pending + completed, read-only
  static String getHustlerOrdersPending = "/api/hustler/orders/pending";
  static String getHustlerOrders = "/api/hustler/orders";

  // Hustler earnings + withdraw request (manual payout)
  static String hustlerEarnings = "/api/hustler/earnings";
  static String hustlerWithdrawRequest = "/api/hustler/earnings/withdraw-request";

  // Reviews (client + public)
  static String createReview = "/api/client/reviews";
  static String getMyReviews = "/api/client/reviews/my";
  static String hustlerReviews(String hustlerId) =>
      "/api/reviews/hustlers/$hustlerId";
  static String serviceReviews(String serviceId) =>
      "/api/reviews/services/$serviceId";

  // Chat endpoints (role-based: client or hustler)
  static String chatSend(String role) => "/api/$role/chat/send";
  static String chatConversations(String role) =>
      "/api/$role/chat/conversations";
  static String chatMessages(String role, String otherUserId) =>
      "/api/$role/chat/messages/$otherUserId";
  static String chatMarkRead(String role, String conversationId) =>
      "/api/$role/chat/read/$conversationId";
  static String chatDeleteConversation(String role, String conversationId) =>
      "/api/$role/chat/conversation/$conversationId";

  // Delete account endpoint (role-based: client or hustler)
  static String deleteAccount(String role) => "/api/$role/account";
}
