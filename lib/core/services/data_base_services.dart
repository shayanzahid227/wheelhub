import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hustler_syn/core/end_points.dart/end_points.dart';
import 'package:hustler_syn/core/enums/user_role.dart';
import 'package:hustler_syn/core/model/app_user_model.dart';
import 'package:hustler_syn/core/model/service_category_model.dart';
import 'package:hustler_syn/core/model/request_services.dart';
import 'package:hustler_syn/core/model/job_post.dart';
import 'package:hustler_syn/core/model/chat_model.dart';
import 'package:hustler_syn/core/model/order_model.dart';
import 'package:hustler_syn/core/model/review_model.dart';
import 'package:hustler_syn/core/services/api_services.dart';
import 'package:hustler_syn/core/services/local_storagre_services.dart';
import 'package:hustler_syn/locator.dart';

///
///      this file is use for data which is on server
///
class DatabaseServices {
  final _apiService = ApiServices();

  ///
  ///. register client
  ///

  Future<RequestResponse<AppUser>> registerClient(AppUser appUser) async {
    try {
      final bool hasImage = appUser.image != null && appUser.image!.isNotEmpty;
      dynamic requestData;

      final baseMap = {
        'email': appUser.email ?? "",
        'fullName': appUser.fullName ?? "",
        'password': appUser.password ?? "",
        "language": appUser.language ?? "",
        "role": appUser.role?.value ?? "",
        "description": appUser.description ?? "",
        "phone": appUser.phone ?? "",
        if (appUser.latitude != null) 'latitude': appUser.latitude,
        if (appUser.longitude != null) 'longitude': appUser.longitude,
      };
      if (hasImage) {
        requestData = FormData.fromMap({
          ...baseMap,
          "profileImage": await MultipartFile.fromFile(
            appUser.image!,
            filename: appUser.image!.split('/').last,
          ),
        });
      } else {
        requestData = baseMap;
      }

      final response = await _apiService.post(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.registerClient}",
        data: requestData,
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final userJson = data['data'] ?? data['user'] ?? data;
        final user = AppUser.fromJson(userJson);
        return RequestResponse(true, data: user);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// register hustler
  ///
  Future<RequestResponse<AppUser>> registerHustler(AppUser appUser) async {
    try {
      final Map<String, dynamic> dataMap = {
        'fullName': appUser.fullName ?? "",
        'email': appUser.email ?? "",
        'password': appUser.password ?? "",
        'role': appUser.role?.value ?? "hustler",
        'phone': appUser.phone ?? "",
        'language': appUser.language ?? "English",
        'startingPrice': appUser.servicePrices?.isNotEmpty == true
            ? appUser.servicePrices!.first.startingPrice ?? "0"
            : "0",
        'businessName': appUser.businessName ?? "",
        'businessDesc': appUser.description ?? "",
        'serviceCategoryId': appUser.category ?? "General",
        if (appUser.latitude != null) 'latitude': appUser.latitude,
        if (appUser.longitude != null) 'longitude': appUser.longitude,
      };

      final List<MultipartFile> businessFiles = [];
      if (appUser.businessImages != null) {
        for (String path in appUser.businessImages!) {
          if (path.isNotEmpty) {
            businessFiles.add(await MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
            ));
          }
        }
      }

      final FormData formData = FormData.fromMap(dataMap);

      if (appUser.image != null && appUser.image!.isNotEmpty) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            appUser.image!,
            filename: appUser.image!.split('/').last,
          ),
        ));
      }

      if (businessFiles.isNotEmpty) {
        for (var file in businessFiles) {
          formData.files.add(MapEntry('businessImages', file));
        }
      }

      final response = await _apiService.post(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.registerHustler}",
        data: formData,
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final userJson = data['data'] ?? data['user'] ?? data;
        final user = AppUser.fromJson(userJson);
        return RequestResponse(true, data: user);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  ///. login user
  ///
  Future<RequestResponse<AppUser>> loginUser(AppUser appUser) async {
    try {
      final response = await _apiService.post(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.loginUser}",
        data: {
          'email': appUser.email ?? "",
          'password': appUser.password ?? "",
        },
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        final actualData = responseData['data'] ?? responseData;
        final userJson = actualData['user'] ?? actualData['data'] ?? actualData;

        final user = AppUser.fromJson(userJson);

        // Ensure token is captured (it might be in responseData['data']['token']
        // while userJson is responseData['data']['user'])
        user.token ??= responseData['token'] ??
            (responseData['data'] is Map
                ? responseData['data']['token']
                : null);

        return RequestResponse(true, data: user);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Forgot password
  ///
  Future<RequestResponse<void>> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.forgotPassword}",
        data: {
          'email': email,
          'newPassword': newPassword,
        },
      );

      if (response.success) {
        return RequestResponse(true, message: response.message);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get profile
  ///
  Future<RequestResponse<AppUser>> getProfile() async {
    try {
      // Use role-specific profile endpoint so fields like phone are included consistently.
      final storedRole = locator<LocalStorageService>().role;
      final role = (storedRole ?? UserRole.client.value).toLowerCase();
      final String profileUrl = role == UserRole.hustler.value
          ? ApiEndPoints.updateHustlerProfile
          : ApiEndPoints.updateClientProfile;

      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}$profileUrl",
      );

      debugPrint("Get Profile Response: ${response.data}");

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData =
            Map<String, dynamic>.from(response.data as Map);

        // Detailed logging to see the structure
        debugPrint("Response data keys: ${responseData.keys}");

        // Some backends nest user like:
        // - { data: { user: {...} } }
        // - { data: { data: { user: {...} } } }
        // - { user: {...} }
        dynamic candidate = responseData['user'] ?? responseData['data'];
        if (candidate is Map) {
          final map1 = Map<String, dynamic>.from(candidate);
          candidate = map1['user'] ?? map1['data'] ?? map1;
          if (candidate is Map) {
            final map2 = Map<String, dynamic>.from(candidate);
            candidate = map2['user'] ?? map2['data'] ?? map2;
          }
        }

        final Map<String, dynamic> userJson = candidate is Map
            ? Map<String, dynamic>.from(candidate)
            : responseData;

        debugPrint("Final User JSON for mapping: $userJson");
        final user = AppUser.fromJson(userJson);
        return RequestResponse(true, data: user);
      } else {
        debugPrint("Get Profile Failed: ${response.message}");
        final msg = _userDeletedMessage(response.message);
        return RequestResponse(false, message: msg ?? response.message);
      }
    } catch (e) {
      debugPrint("Get Profile Exception: $e");
      final msg = _userDeletedMessage(e.toString());
      return RequestResponse(false, message: msg ?? e.toString());
    }
  }

  /// Returns a clear message when the error indicates a deleted or missing user (for current user).
  static String? _userDeletedMessage(String? raw) {
    return getMessageForDeletedUser(raw, isCurrentUser: true);
  }

  /// Use when showing errors that may mean the user/account was deleted.
  /// [isCurrentUser]: true = "This account has been deleted..."; false = "This user is no longer available."
  static String? getMessageForDeletedUser(String? raw, {bool isCurrentUser = true}) {
    if (raw == null || raw.isEmpty) return null;
    final lower = raw.toLowerCase();
    if (lower.contains('deleted') ||
        lower.contains('not found') ||
        lower.contains('no longer') ||
        lower.contains('account has been') ||
        lower.contains('user has been') ||
        lower.contains('no longer available') ||
        lower.contains('404')) {
      return isCurrentUser
          ? 'This account has been deleted. Please sign in again or create a new account.'
          : 'This user is no longer available.';
    }
    return null;
  }

  ///
  /// Update Profile
  ///
  Future<RequestResponse<AppUser>> updateProfile(AppUser user,
      {String? imagePath}) async {
    try {
      // Prefer stored role (from login/register), then user object, then default to client so we use role-specific URL
      final storedRole = locator<LocalStorageService>().role;
      final userRole = user.role?.value;
      final role = storedRole ?? userRole ?? UserRole.client.value;
      debugPrint("DatabaseServices: Current User Role: $role (stored: $storedRole, user: $userRole)");

      String url;
      if (role == UserRole.client.value) {
        url = "${ApiEndPoints.baseUrl}${ApiEndPoints.updateClientProfile}";
      } else if (role == UserRole.hustler.value) {
        url = "${ApiEndPoints.baseUrl}${ApiEndPoints.updateHustlerProfile}";
      } else {
        url = "${ApiEndPoints.baseUrl}${ApiEndPoints.updateClientProfile}";
        debugPrint("DatabaseServices: Unknown role '$role', using client profile URL.");
      }

      Map<String, dynamic> dataMap = {
        'fullName': user.fullName,
        'email': user.email,
        'phone': user.phone,
        'description': user.description,
        'language': user.language,
        if (user.image != null && user.image!.startsWith('http'))
          'profileImage': user.image,
      };

      if (role == UserRole.hustler.value) {
        // Backend does not support updating businessName or category via this endpoint
        // So we don't send them to avoid confusion
      }

      debugPrint("=== REAL DATA BEING SENT TO BACKEND ===");
      debugPrint("URL: $url");
      debugPrint("Data: $dataMap");
      debugPrint("========================================");

      dynamic requestData;

      if (imagePath != null && imagePath.isNotEmpty) {
        dataMap['profileImage'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
        requestData = FormData.fromMap(dataMap);
      } else {
        requestData = dataMap;
      }

      final response = await _apiService.put(
        url: url,
        data: requestData,
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final userJson = data['data'] ?? data['user'] ?? data;
        final updatedUser = AppUser.fromJson(userJson);
        return RequestResponse(true, data: updatedUser);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Register FCM token with backend for push notifications (chat, order, payment).
  /// Call after login and on token refresh. Platform: "android" | "ios" | "web".
  ///
  Future<RequestResponse<void>> registerFcmToken(String fcmToken, String platform) async {
    try {
      final url = "${ApiEndPoints.baseUrl}${ApiEndPoints.registerFcmToken}";
      final response = await _apiService.post(
        url: url,
        data: {'fcmToken': fcmToken, 'platform': platform},
      );
      if (response.success) {
        debugPrint('[FCM] Token registered with backend.');
        return RequestResponse(true);
      }
      debugPrint('[FCM] Register token failed: ${response.message}');
      return RequestResponse(false, message: response.message);
    } catch (e) {
      debugPrint('[FCM] registerFcmToken error: $e');
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Send a push notification to the current user's devices (for testing).
  ///
  Future<RequestResponse<void>> sendNotificationToSelf({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final url = "${ApiEndPoints.baseUrl}${ApiEndPoints.sendNotificationToSelf}";
      final response = await _apiService.post(
        url: url,
        data: {
          'title': title,
          'body': body,
          if (data != null && data.isNotEmpty) 'data': data,
        },
      );
      if (response.success) return RequestResponse(true);
      return RequestResponse(false, message: response.message);
    } catch (e) {
      debugPrint('[FCM] sendNotificationToSelf error: $e');
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Add Hustler Service
  ///
  /// token is mendatory
  ///
  Future<RequestResponse<ServiceAndPriceDetail>> addHustlerService(
      ServiceAndPriceDetail service) async {
    try {
      final Map<String, dynamic> dataMap = {
        'name': service.serviceName ?? "",
        'description': service.description ?? "",
        'startingPrice': service.startingPrice ?? "0",
        'serviceCategoryId': service.serviceCategoryId ?? "",
      };

      final FormData formData = FormData.fromMap(dataMap);

      if (service.images != null && service.images!.isNotEmpty) {
        for (var path in service.images!) {
          if (path.isNotEmpty) {
            formData.files.add(MapEntry(
              'serviceImages',
              await MultipartFile.fromFile(
                path,
                filename: path.split('/').last,
              ),
            ));
          }
        }
      }

      final response = await _apiService.post(
        url:
            "${ApiEndPoints.baseUrl}${ApiEndPoints.addHustlerServiceForHustler}",
        data: formData,
      );

      if (response.success && response.data != null) {
        debugPrint("Add Service Response Data: ${response.data}");
        final Map<String, dynamic> data = response.data;
        final serviceJson = data['data'] ?? data;
        final newService = ServiceAndPriceDetail.fromJson(serviceJson);
        return RequestResponse(true, data: newService);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get My Services (for Hustler)
  ///
  Future<RequestResponse<List<ServiceAndPriceDetail>>> getMyServices() async {
    try {
      final userId = locator<LocalStorageService>().userId;
      if (userId == null) {
        return RequestResponse(false, message: "User ID not found");
      }

      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}/api/hustlers/$userId",
      );

      if (response.success && response.data != null) {
        final data = response.data;
        debugPrint("GetMyServices: Fetched data keys: ${data.keys}");

        // The services are populated inside the 'services' key of the user object
        final servicesList = data['services'] ?? data['data']?['services'];
        debugPrint(
            "GetMyServices: servicesList found: ${servicesList != null}");

        if (servicesList != null && servicesList is List) {
          final services = servicesList
              .map((e) =>
                  ServiceAndPriceDetail.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          debugPrint(
              "GetMyServices: Total services fetched: ${services.length}");
          if (services.isNotEmpty) {
            final firstService = services[0];
            debugPrint(
                "GetMyServices: Index 0 Service Name: ${firstService.serviceName}");
            debugPrint(
                "GetMyServices: Index 0 Service Price: ${firstService.startingPrice}");
            debugPrint(
                "GetMyServices: Index 0 Service Desc: ${firstService.description}");
          } else {
            debugPrint("GetMyServices: Service list is empty");
          }

          return RequestResponse(true, data: services);
        } else {
          debugPrint("GetMyServices: servicesList is null or not a List");
          return RequestResponse(true, data: []);
        }
      } else {
        debugPrint("GetMyServices Error: ${response.message}");
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get All Categories
  ///
  /// Fetches all service categories from the database
  ///
  Future<RequestResponse<List<ServiceCategory>>> getAllCategories() async {
    final localStorage = locator<LocalStorageService>();
    try {
      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.getAllCategories}",
      );

      debugPrint("Get All Categories Response: ${response.data}");

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data;

        // Extract categories list from response
        final categoriesList =
            responseData['data'] ?? responseData['categories'];

        if (categoriesList != null && categoriesList is List) {
          final categories = categoriesList
              .map(
                  (e) => ServiceCategory.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          debugPrint("Total categories fetched: ${categories.length}");

          // Update local cache
          await localStorage.setCategories(categories);

          return RequestResponse(true, data: categories);
        } else {
          debugPrint("Categories list is null or not a List");
          return RequestResponse(true, data: localStorage.categories);
        }
      } else {
        debugPrint(
            "⚠️ Category fetch failed (Status: ${response.message}). Using local cache.");
        return RequestResponse(true,
            data: localStorage.categories, message: response.message);
      }
    } catch (e) {
      debugPrint("❌ Category fetch exception: $e. Using local cache.");
      return RequestResponse(true,
          data: localStorage.categories, message: e.toString());
    }
  }

  ///
  /// Get All Hustlers
  ///
  Future<RequestResponse<List<AppUser>>> getAllHustlers() async {
    try {
      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.getAllHustlers}",
        // Backend defaults to pagination; Discover needs a full list.
        params: const {'limit': '1000', 'page': '1'},
      );

      // debugPrint("Get All Hustlers Response: ${response.data}");

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> hustlersList =
            responseData['data'] ?? responseData['hustlers'] ?? [];

        final hustlers = hustlersList
            .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        debugPrint("[DEBUG] Total Hustlers: ${hustlers.length}");
        return RequestResponse(true, data: hustlers);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get All Clients
  ///
  Future<RequestResponse<List<AppUser>>> getAllClients() async {
    try {
      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.getAllClients}",
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> clientsList =
            responseData['data'] ?? responseData['clients'] ?? [];

        final clients = clientsList
            .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        debugPrint("[DEBUG] Total Clients: ${clients.length}");
        return RequestResponse(true, data: clients);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get Service Providers By Category
  ///
  Future<RequestResponse<List<AppUser>>> getServiceProvidersByCategory(
      String? categoryId) async {
    try {
      debugPrint("=== Fetching Service Providers ===");
      debugPrint("Category ID: $categoryId");

      final response = await _apiService.get(
        url:
            "${ApiEndPoints.baseUrl}${ApiEndPoints.getServiceProvidersByCategory}",
        params: categoryId != null ? {'serviceCatId': categoryId} : null,
      );

      debugPrint(
          "Get Service Providers By Category Response: ${response.data}");
      debugPrint("Response success: ${response.success}");

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> servicesList =
            responseData['data'] ?? responseData['hustlers'] ?? [];

        // The backend returns HustlerService objects which have a 'userId' field populated with the user info.
        // We need to map these to AppUser objects for our UI.
        final hustlers = servicesList.map((e) {
          final Map<String, dynamic> serviceData = Map<String, dynamic>.from(e);
          final dynamic userData = serviceData['userId'];

          debugPrint("=== User Data from Backend ===");
          debugPrint("Service Data Keys: ${serviceData.keys}");
          debugPrint("User Data Type: ${userData.runtimeType}");

          if (userData is Map) {
            debugPrint("User Data ID: ${userData['_id']}");
            debugPrint("User Data Name: ${userData['fullName']}");
          } else {
            debugPrint("User Data is null or not a Map: $userData");
          }

          if (userData != null && userData is Map) {
            final Map<String, dynamic> userMap =
                Map<String, dynamic>.from(userData);

            debugPrint("=== User Data from Backend ===");
            debugPrint("userMap keys: ${userMap.keys}");
            debugPrint("fullName: ${userMap['fullName']}");
            debugPrint("fullname: ${userMap['fullname']}");
            debugPrint("FullName: ${userMap['FullName']}");
            debugPrint("name: ${userMap['name']}");
            debugPrint("==============================");

            // Merge service details into user object if needed,
            // but mainly we want the user info here.
            final user = AppUser.fromJson(userMap);

            debugPrint("After fromJson - user.fullName: ${user.fullName}");

            // Set the category from the populated service if possible
            if (serviceData['serviceCategoryId'] != null &&
                serviceData['serviceCategoryId'] is Map) {
              user.category = serviceData['serviceCategoryId']['name'];
            }
            // Also try to get the name from service business info if missing
            user.fullName ??=
                serviceData['name'] ?? serviceData['businessName'];

            debugPrint("Final user.fullName: ${user.fullName}");
            return user;
          }
          return AppUser();
        }).toList();

        return RequestResponse(true, data: hustlers);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get All Job Posts
  ///
  Future<RequestResponse<List<PostModel>>> getAllJobPosts() async {
    try {
      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.jobPosts}",
      );

      debugPrint("Get All Job Posts Response: ${response.data}");

      if (response.success && response.data != null) {
        final responseData = response.data;
        List<dynamic> postsList = [];
        if (responseData is List) {
          postsList = responseData;
        } else if (responseData is Map<String, dynamic>) {
          postsList = responseData['data'] ??
              responseData['jobPosts'] ??
              responseData['posts'] ??
              responseData['results'] ??
              [];
        }
        final posts = postsList
            .map((e) {
              try {
                return PostModel.fromJson(Map<String, dynamic>.from(e is Map ? e : <String, dynamic>{}));
              } catch (_) {
                return PostModel();
              }
            })
            .where((p) => p.title != null || p.id != null)
            .toList();
        return RequestResponse(true, data: posts);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Create Job Post
  ///
  Future<RequestResponse<PostModel>> createJobPost(
      PostModel post, List<String> imagePaths) async {
    try {
      // Manually construct the map to ensure correct formatting for FormData
      final Map<String, dynamic> dataMap = {
        'title': post.title,
        'description': post.description,
        'budget': post.budget?.toString() ?? "0",
        'location': post.location,
        'serviceCategoryId': post.serviceCategoryId,
      };

      // Backend handles JSON-encoded array for languages in multipart request
      if (post.languages != null && post.languages!.isNotEmpty) {
        dataMap['languages'] = jsonEncode(post.languages);
      }

      debugPrint("DatabaseServices.createJobPost - dataMap: $dataMap");
      final FormData formData = FormData.fromMap(dataMap);

      if (imagePaths.isNotEmpty) {
        for (var path in imagePaths) {
          if (path.isNotEmpty) {
            formData.files.add(MapEntry(
              'postImages',
              await MultipartFile.fromFile(
                path,
                filename: path.split('/').last,
              ),
            ));
          }
        }
      }

      final response = await _apiService.post(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.jobPosts}",
        data: formData,
      );

      debugPrint(
          "DatabaseServices.createJobPost - response success: ${response.success}");
      debugPrint(
          "DatabaseServices.createJobPost - response data: ${response.data}");

      if (response.success && response.data != null) {
        final data = response.data;
        dynamic postJson = data is Map ? (data['data'] ?? data['post'] ?? data) : data;
        if (postJson is Map<String, dynamic>) {
          try {
            final newPost = PostModel.fromJson(postJson);
            return RequestResponse(true, data: newPost);
          } catch (_) {
            return RequestResponse(true, data: PostModel(), message: response.message ?? 'Post created successfully.');
          }
        }
        return RequestResponse(true, data: PostModel(), message: response.message ?? 'Post created successfully.');
      } else {
        return RequestResponse(false, message: response.message ?? 'Failed to create post.');
      }
    } catch (e, stack) {
      debugPrint("DatabaseServices.createJobPost - Exception: $e");
      debugPrint("DatabaseServices.createJobPost - StackTrace: $stack");
      return RequestResponse(false, message: e.toString());
    }
  }

  // ============================================
  // CHAT API METHODS
  // ============================================

  /// Get user role for chat endpoints
  String _getUserRole() {
    final role = locator<LocalStorageService>().role;
    return role ?? 'client'; // Default to client if role not found
  }

  /// Get current user ID
  String? _getCurrentUserId() {
    return locator<LocalStorageService>().userId;
  }

  ///
  /// Get all conversations for current user
  ///
  Future<RequestResponse<List<ChatModel>>> getConversations() async {
    try {
      final role = _getUserRole();
      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.chatConversations(role)}",
      );

      // debugPrint("Get Conversations Response: ${response.data}");

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> conversationsList = responseData['data']
                ?['conversations'] ??
            responseData['conversations'] ??
            [];

        final conversations = conversationsList
            .map((e) => ChatModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        debugPrint("[API] Fetched ${conversations.length} conversations");
        return RequestResponse(true, data: conversations);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      debugPrint("Get Conversations Exception: $e");
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get messages for a conversation with a specific user
  ///
  Future<RequestResponse<List<MessageModel>>> getMessages(
    String otherUserId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final role = _getUserRole();
      final currentUserId = _getCurrentUserId();

      if (currentUserId == null) {
        return RequestResponse(false, message: "User ID not found");
      }

      final response = await _apiService.get(
        url:
            "${ApiEndPoints.baseUrl}${ApiEndPoints.chatMessages(role, otherUserId)}",
        params: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      // debugPrint("Get Messages Response: ${response.data}");

      if (response.success && response.data != null) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> messagesList =
            responseData['data']?['messages'] ?? responseData['messages'] ?? [];

        final messages = messagesList
            .map((e) => MessageModel.fromJson(
                Map<String, dynamic>.from(e), currentUserId))
            .toList();

        debugPrint("[API] Fetched ${messages.length} messages");
        if (messages.isNotEmpty) {
          debugPrint("[API] First message image: ${messages.first.image}");
          debugPrint("[API] First message type: ${messages.first.messageType}");
        }
        return RequestResponse(true, data: messages);
      } else {
        // No conversation found is not an error, just return empty list
        if (response.message?.contains('No conversation') == true) {
          return RequestResponse(true, data: []);
        }
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      debugPrint("Get Messages Exception: $e");
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Send a message (text and/or image).
  /// API: POST multipart/form-data — receiverId (required), message (optional), image (optional). Either message or image required.
  ///
  Future<RequestResponse<MessageModel>> sendMessage(
    String receiverId,
    String message, {
    String? imagePath,
  }) async {
    try {
      final role = _getUserRole();
      final currentUserId = _getCurrentUserId();

      if (currentUserId == null) {
        return RequestResponse(false, message: "User ID not found");
      }

      if (message.isEmpty && imagePath == null) {
        return RequestResponse(false, message: "Message or image is required");
      }

      // API spec: multipart/form-data with receiverId, message (optional), image (optional)
      final FormData formData = FormData.fromMap({
        'receiverId': receiverId,
        'message': message,
      });

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        ));
      }

      final response = await _apiService.post(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.chatSend(role)}",
        data: formData,
      );

      debugPrint("Send Message Response: ${response.data}");

      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final messageJson = data['data']?['message'] ?? data['message'];

        if (messageJson != null) {
          final sentMessage = MessageModel.fromJson(
            Map<String, dynamic>.from(messageJson),
            currentUserId,
          );
          return RequestResponse(true, data: sentMessage);
        } else {
          return RequestResponse(false,
              message: "Message data not found in response");
        }
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      debugPrint("Send Message Exception: $e");
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Mark conversation as read
  ///
  Future<RequestResponse<void>> markAsRead(String conversationId) async {
    try {
      final role = _getUserRole();
      final response = await _apiService.put(
        url:
            "${ApiEndPoints.baseUrl}${ApiEndPoints.chatMarkRead(role, conversationId)}",
        data: {},
      );

      debugPrint("Mark As Read Response: ${response.data}");

      if (response.success) {
        return RequestResponse(true);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      debugPrint("Mark As Read Exception: $e");
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Delete conversation
  ///
  Future<RequestResponse<void>> deleteConversation(
      String conversationId) async {
    try {
      final role = _getUserRole();
      final response = await _apiService.delete(
        url:
            "${ApiEndPoints.baseUrl}${ApiEndPoints.chatDeleteConversation(role, conversationId)}",
      );

      debugPrint("Delete Conversation Response: ${response.data}");

      if (response.success) {
        return RequestResponse(true);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      debugPrint("Delete Conversation Exception: $e");
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Delete Account (Permanent)
  ///
  /// Calls DELETE /api/client/account or /api/hustler/account with Bearer token.
  /// Backend permanently removes the user and ALL related data: posts, services,
  /// reviews, orders, payments, subscriptions, chat conversations, etc.
  ///
  Future<RequestResponse<void>> deleteAccount() async {
    try {
      final role = _getUserRole();
      debugPrint("DatabaseServices: Deleting account for role: $role");

      final response = await _apiService.delete(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.deleteAccount(role)}",
      );

      debugPrint("Delete Account Response: ${response.data}");

      if (response.success) {
        debugPrint("Account deleted successfully");
        return RequestResponse(true, message: response.message);
      } else {
        debugPrint("Delete Account Failed: ${response.message}");
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      debugPrint("Delete Account Exception: $e");
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Create Subscription Session (Stripe). Currency is ZAR (R) for South Africa.
  ///
  Future<RequestResponse<Map<String, dynamic>>> createSubscriptionSession(
      String userId,
      {String? role,
      String? planId,
      String currency = "zar"}) async {
    debugPrint("--------------------------------------------------");
    debugPrint("DATABASE SERVICES: createSubscriptionSession");
    debugPrint("Input UserID: $userId");
    debugPrint("Input Role (explicit): $role");
    debugPrint("Input PlanID: $planId");
    debugPrint("Currency: $currency (ZAR = R)");

    try {
      final userRole = (role ?? _getUserRole()).toLowerCase();

      final requestData = {
        'userId': userId,
        'userRole': userRole,
        'role': userRole,
        'userType': userRole,
        'currency': currency,
      };

      if (planId != null) {
        requestData['planId'] = planId;
      }

      debugPrint("Final Request Payload: $requestData");

      final response = await _apiService.post(
          url:
              "${ApiEndPoints.baseUrl}${ApiEndPoints.createSubscriptionSession}",
          data: requestData);

      debugPrint("Full API Response Data: ${response.data}");

      if (response.success && response.data != null) {
        debugPrint("SUCCESS: Session created.");
        return RequestResponse(true, data: response.data);
      } else {
        debugPrint("FAILURE: ${response.message}");
        return RequestResponse(false, message: response.message);
      }
    } catch (e, stack) {
      debugPrint("EXCEPTION in createSubscriptionSession: $e");
      debugPrint("Stack Trace: $stack");
      return RequestResponse(false, message: e.toString());
    } finally {
      debugPrint("--------------------------------------------------");
    }
  }

  ///
  /// Get current subscription plan for logged-in user.
  /// Returns a single flat map so status/renewal can be read from top level or nested subscription/plan.
  ///
  Future<RequestResponse<Map<String, dynamic>?>> getCurrentSubscriptionPlan() async {
    try {
      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.currentSubscriptionPlan}",
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> raw =
            Map<String, dynamic>.from(response.data as Map);
        // Flatten: backend may return { data: { subscription: { status, currentPeriodEnd } } } or { status, currentPeriodEnd } at top level
        final dynamic inner = raw['data'] ?? raw;
        Map<String, dynamic>? sub = inner is Map<String, dynamic>
            ? Map<String, dynamic>.from(inner)
            : null;
        if (sub != null) {
          final nested = sub['subscription'] ?? sub['plan'] ?? sub['currentSubscription'];
          if (nested is Map<String, dynamic>) {
            sub = Map<String, dynamic>.from(nested);
          }
          return RequestResponse(true, data: sub);
        }
        return RequestResponse(true, data: null);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get logged-in user's billing/invoice history (subscription payments).
  /// GET /api/billing-history with Authorization header.
  ///
  Future<RequestResponse<List<Map<String, dynamic>>>> getBillingHistory() async {
    try {
      final url = "${ApiEndPoints.baseUrl}${ApiEndPoints.billingHistory}";
      final response = await _apiService.get(url: url, debugHeaders: true);

      // Debug-only tracing (does nothing in release)
      assert(() {
        debugPrint("--------------------------------------------------");
        debugPrint("DATABASE SERVICES: getBillingHistory");
        debugPrint("GET $url");
        debugPrint("Success: ${response.success}");
        debugPrint("Message: ${response.message}");
        debugPrint("Raw type: ${response.data.runtimeType}");
        debugPrint("Raw data: ${response.data}");
        debugPrint("--------------------------------------------------");
        return true;
      }());

      List<dynamic> list = [];
      if (response.data != null) {
        final raw = response.data;
        if (raw is List) {
          list = raw;
        } else if (raw is Map) {
          final rawMap = Map<String, dynamic>.from(
            raw.map((k, v) => MapEntry(k?.toString() ?? '', v)),
          );

          dynamic data = rawMap['data'] ??
              rawMap['billingHistory'] ??
              rawMap['invoices'] ??
              rawMap['history'] ??
              rawMap['payments'] ??
              rawMap['items'] ??
              rawMap['results'] ??
              rawMap['list'];

          // Common shape: { data: { invoices: [...] } }
          if (data is Map) {
            final dataMap = Map<String, dynamic>.from(
              data.map((k, v) => MapEntry(k?.toString() ?? '', v)),
            );
            data = dataMap['data'] ??
                dataMap['billingHistory'] ??
                dataMap['invoices'] ??
                dataMap['history'] ??
                dataMap['payments'] ??
                dataMap['items'] ??
                dataMap['results'] ??
                dataMap['list'];
          }

          if (data is List) list = data;
        }
      }
      // Dio often decodes JSON objects as `Map<dynamic, dynamic>` (e.g. LinkedHashMap),
      // so filtering by `Map<String, dynamic>` can drop valid rows. Convert maps safely.
      final parsed = list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e.map(
                (k, v) => MapEntry(k?.toString() ?? '', v),
              )))
          .where((e) => e.isNotEmpty)
          .toList();
      return RequestResponse(response.success, message: response.message, data: parsed);
    } catch (e) {
      return RequestResponse(false, message: e.toString(), data: []);
    }
  }
  Future<RequestResponse<Map<String, dynamic>>> createBookingPaymentSession({
    required String serviceId,
    required DateTime scheduledAt,
    required String durationLabel,
    String? notes,
    required num amount,
    String currency = "zar",
  }) async {
    debugPrint("--------------------------------------------------");
    debugPrint("DATABASE SERVICES: createBookingPaymentSession");
    debugPrint("serviceId: $serviceId");
    debugPrint("scheduledAt: $scheduledAt");
    debugPrint("durationLabel: $durationLabel");
    debugPrint("amount: $amount");
    debugPrint("currency: $currency");

    try {
      final requestData = {
        'serviceId': serviceId,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'durationLabel': durationLabel,
        'notes': notes ?? '',
        'amount': amount,
        'currency': currency,
      };

      debugPrint("Final Booking Payload: $requestData");
      final fullUrl =
          "${ApiEndPoints.baseUrl}${ApiEndPoints.createBookingPaymentSession}";
      debugPrint("[PAYMENT] POST $fullUrl");

      final response = await _apiService.post(
        url: fullUrl,
        data: requestData,
      );

      debugPrint("[PAYMENT] Status: ${response.success}, Full Response: ${response.data}");

      if (response.success && response.data != null) {
        debugPrint("SUCCESS: Booking payment session created.");
        return RequestResponse(true, data: response.data);
      } else {
        debugPrint("FAILURE (booking): ${response.message}");
        return RequestResponse(false, message: response.message);
      }
    } catch (e, stack) {
      debugPrint("EXCEPTION in createBookingPaymentSession: $e");
      debugPrint("Stack Trace: $stack");
      return RequestResponse(false, message: e.toString());
    } finally {
      debugPrint("--------------------------------------------------");
    }
  }

  ///
  /// Notify backend that Stripe payment succeeded (success callback). App sends Accept: application/json; backend can return 200 + { success: true, data: { orderId, status: "confirmed" } } so we know order is paid and release-funds is allowed.
  ///
  Future<RequestResponse<Map<String, dynamic>?>> notifyBookingPaymentSuccess(String sessionId) async {
    try {
      final url = "${ApiEndPoints.baseUrl}${ApiEndPoints.bookingPaymentSuccessCallback(sessionId)}";
      debugPrint("[PAYMENT] Notifying backend success: GET $url (Accept: application/json)");
      final response = await _apiService.get(url: url);
      debugPrint("[PAYMENT] Success callback response: success=${response.success}, message=${response.message}");
      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final inner = data['data'];
          final orderId = inner is Map ? inner['orderId']?.toString() : null;
          final status = inner is Map ? inner['status']?.toString() : null;
          if (orderId != null || status != null) {
            debugPrint("[PAYMENT] Order confirmed: orderId=$orderId, status=$status");
          }
          return RequestResponse(true, data: data, message: response.message);
        }
        return RequestResponse(true, data: null, message: response.message);
      }
      return RequestResponse(false, message: response.message);
    } catch (e) {
      debugPrint("[PAYMENT] Success callback error: $e");
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get client's pending orders (status confirmed – paid, not yet released)
  ///
  Future<RequestResponse<List<OrderModel>>> getPendingOrders() async {
    try {
      final url = "${ApiEndPoints.baseUrl}${ApiEndPoints.getClientOrdersPending}";
      debugPrint("[ORDERS] GET pending: $url");
      final response = await _apiService.get(url: url);
      debugPrint("[ORDERS] Pending response success: ${response.success}, data type: ${response.data?.runtimeType}");
      if (response.data != null) {
        final raw = response.data;
        List<dynamic> list = [];
        if (raw is List) {
          list = raw;
          debugPrint("[ORDERS] Pending: backend returned array, length=${list.length}");
        } else if (raw is Map<String, dynamic>) {
          final data = raw;
          final inner = data['data'] ?? data['orders'] ?? data['items'] ?? data;
          if (inner is List) {
            list = inner;
          } else if (inner is Map) {
            list = inner['orders'] ?? inner['data'] ?? [];
          }
          debugPrint("[ORDERS] Pending: from map keys ${data.keys.toList()}, list length=${list.length}");
        }
        final orders = list
            .whereType<Map<String, dynamic>>()
            .map((e) {
              try {
                return OrderModel.fromJson(e);
              } catch (e2) {
                debugPrint("[ORDERS] Parse error for item: $e2");
                return null;
              }
            })
            .whereType<OrderModel>()
            .toList();
        debugPrint("[ORDERS] Pending parsed count: ${orders.length}");
        return RequestResponse(response.success, data: orders, message: response.message);
      }
      return RequestResponse(false, message: response.message ?? 'No data');
    } catch (e, stack) {
      debugPrint("[ORDERS] getPendingOrders error: $e");
      debugPrint("[ORDERS] $stack");
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Release funds for an order (client). POST /api/client/orders/:orderId/release-funds.
  /// Backend marks order completed and creates a Payout: 90% to hustler, 10% platform commission (Fiverr-style).
  ///
  Future<RequestResponse<void>> releaseFunds(String orderId) async {
    try {
      final url =
          "${ApiEndPoints.baseUrl}${ApiEndPoints.releaseFunds(orderId)}";
      final response = await _apiService.post(url: url, data: {});
      if (response.success) {
        final msg = response.data is Map ? response.data['message'] : null;
        return RequestResponse(true, message: msg?.toString());
      }
      return RequestResponse(false, message: response.message);
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Cancel order (client). Pending = no refund; Confirmed = Stripe refund; Completed = not allowed.
  ///
  Future<RequestResponse<void>> cancelOrder(String orderId) async {
    try {
      final url =
          "${ApiEndPoints.baseUrl}${ApiEndPoints.cancelOrder(orderId)}";
      final response = await _apiService.post(url: url, data: {});
      if (response.success) return RequestResponse(true);
      return RequestResponse(false, message: response.message);
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get all client orders, optionally filtered by status (e.g. completed)
  ///
  Future<RequestResponse<List<OrderModel>>> getOrders({String? status}) async {
    try {
      String url = "${ApiEndPoints.baseUrl}${ApiEndPoints.getClientOrders}";
      if (status != null && status.isNotEmpty) {
        url += "?status=$status";
      }
      debugPrint("[ORDERS] GET orders: $url");
      final response = await _apiService.get(url: url);
      debugPrint("[ORDERS] Orders response success: ${response.success}, data type: ${response.data?.runtimeType}");
      if (response.data != null) {
        final raw = response.data;
        List<dynamic> list = [];
        if (raw is List) {
          list = raw;
        } else if (raw is Map<String, dynamic>) {
          final data = raw;
          final inner = data['data'] ?? data['orders'] ?? data['items'] ?? data;
          if (inner is List) {
            list = inner;
          } else if (inner is Map) {
            list = inner['orders'] ?? inner['data'] ?? [];
          }
        }
        final orders = list
            .whereType<Map<String, dynamic>>()
            .map((e) {
              try {
                return OrderModel.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<OrderModel>()
            .toList();
        debugPrint("[ORDERS] Orders parsed count: ${orders.length}");
        return RequestResponse(response.success, data: orders, message: response.message);
      }
        return RequestResponse(false, message: response.message);
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get hustler's pending orders (tasks) – for hustler view, read-only.
  ///
  Future<RequestResponse<List<OrderModel>>> getHustlerPendingOrders() async {
    try {
      final url = "${ApiEndPoints.baseUrl}${ApiEndPoints.getHustlerOrdersPending}";
      final response = await _apiService.get(url: url);
      if (response.data != null) {
        final raw = response.data;
        List<dynamic> list = _parseOrdersList(raw);
        final orders = list
            .whereType<Map<String, dynamic>>()
            .map((e) {
              try {
                return OrderModel.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<OrderModel>()
            .toList();
        return RequestResponse(response.success, data: orders, message: response.message);
      }
      return RequestResponse(false, message: response.message);
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get hustler's orders (all or by status) – for hustler view.
  ///
  Future<RequestResponse<List<OrderModel>>> getHustlerOrders({String? status}) async {
    try {
      String url = "${ApiEndPoints.baseUrl}${ApiEndPoints.getHustlerOrders}";
      if (status != null && status.isNotEmpty) url += "?status=$status";
      final response = await _apiService.get(url: url);
      if (response.data != null) {
        final raw = response.data;
        List<dynamic> list = _parseOrdersList(raw);
        final orders = list
            .whereType<Map<String, dynamic>>()
            .map((e) {
              try {
                return OrderModel.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<OrderModel>()
            .toList();
        return RequestResponse(response.success, data: orders, message: response.message);
      }
      return RequestResponse(false, message: response.message);
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  static List<dynamic> _parseOrdersList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'] ?? raw['orders'] ?? raw['items'] ?? raw;
      if (inner is List) return inner;
      if (inner is Map) return inner['orders'] ?? inner['data'] ?? [];
    }
    return [];
  }

  // ============================================
  // HUSTLER EARNINGS + WITHDRAW REQUEST
  // ============================================

  /// GET /api/hustler/earnings (JWT + hustler role)
  Future<RequestResponse<Map<String, dynamic>>> getHustlerEarnings() async {
    try {
      final url = "${ApiEndPoints.baseUrl}${ApiEndPoints.hustlerEarnings}";
      final res = await _apiService.get(url: url);
      if (res.success && res.data != null) {
        if (res.data is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(res.data);
          final inner = map['data'] ?? map;
          if (inner is Map<String, dynamic>) {
            return RequestResponse(true, data: Map<String, dynamic>.from(inner));
          }
          if (inner is Map) {
            return RequestResponse(true, data: Map<String, dynamic>.from(inner));
          }
        }
        return RequestResponse(true, data: {});
      }
      return RequestResponse(false, message: res.message ?? 'Failed to fetch earnings');
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  /// POST /api/hustler/earnings/withdraw-request
  /// Body: { bankDetails: { bankName, accountHolderName, accountNumber, branchCode?, accountType? }, note? }
  Future<RequestResponse<Map<String, dynamic>>> requestHustlerWithdrawal({
    required Map<String, dynamic> bankDetails,
    String? note,
  }) async {
    try {
      final url = "${ApiEndPoints.baseUrl}${ApiEndPoints.hustlerWithdrawRequest}";
      final payload = {
        'bankDetails': bankDetails,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      };
      final res = await _apiService.post(url: url, data: payload);
      if (res.success && res.data != null) {
        if (res.data is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(res.data);
          final inner = map['data'] ?? map;
          if (inner is Map<String, dynamic>) {
            return RequestResponse(true, data: Map<String, dynamic>.from(inner), message: map['message']?.toString());
          }
          if (inner is Map) {
            return RequestResponse(true, data: Map<String, dynamic>.from(inner), message: map['message']?.toString());
          }
        }
        return RequestResponse(true, data: {}, message: res.message);
      }
      return RequestResponse(false, message: res.message ?? 'Failed to submit withdraw request');
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Create Review for completed booking (client only)
  ///
  Future<RequestResponse<Review>> createReview({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final payload = {
        'orderId': orderId,
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      };

      final response = await _apiService.post(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.createReview}",
        data: payload,
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final dynamic inner = data['data'] ?? data;
        final dynamic reviewJson =
            inner is Map ? inner['review'] ?? inner : inner;

        if (reviewJson is Map<String, dynamic>) {
          final review = Review.fromJson(reviewJson);
          return RequestResponse(true, data: review);
        }

        return const RequestResponse(
          false,
          message: "Invalid review data in response.",
        );
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get logged-in client's own reviews
  ///
  Future<RequestResponse<List<Review>>> getMyReviews() async {
    try {
      final response = await _apiService.get(
        url: "${ApiEndPoints.baseUrl}${ApiEndPoints.getMyReviews}",
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final dynamic inner = data['data'] ?? data;
        final List<dynamic> list =
            inner is Map ? (inner['reviews'] ?? inner['data'] ?? []) : [];

        final reviews = list
            .whereType<Map<String, dynamic>>()
            .map((e) => Review.fromJson(e))
            .toList();

        return RequestResponse(true, data: reviews);
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get public reviews for a Hustler (plus stats)
  ///
  Future<RequestResponse<ReviewsWithStats>> getHustlerReviews(
      String hustlerId) async {
    try {
      final response = await _apiService.get(
        url:
            "${ApiEndPoints.baseUrl}${ApiEndPoints.hustlerReviews(hustlerId)}",
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final dynamic inner = data['data'] ?? data;

        final List<dynamic> list = inner is Map ? (inner['reviews'] ?? []) : [];
        final reviews = list
            .whereType<Map<String, dynamic>>()
            .map((e) => Review.fromJson(e))
            .toList();

        final statsJson =
            inner is Map && inner['stats'] is Map<String, dynamic>
                ? inner['stats'] as Map<String, dynamic>
                : <String, dynamic>{};
        final stats = ReviewStats.fromJson(statsJson);

        return RequestResponse(
          true,
          data: ReviewsWithStats(reviews: reviews, stats: stats),
        );
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }

  ///
  /// Get public reviews for a specific service (plus stats)
  ///
  Future<RequestResponse<ReviewsWithStats>> getServiceReviews(
      String serviceId) async {
    try {
      final response = await _apiService.get(
        url:
            "${ApiEndPoints.baseUrl}${ApiEndPoints.serviceReviews(serviceId)}",
      );

      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final dynamic inner = data['data'] ?? data;

        final List<dynamic> list = inner is Map ? (inner['reviews'] ?? []) : [];
        final reviews = list
            .whereType<Map<String, dynamic>>()
            .map((e) => Review.fromJson(e))
            .toList();

        final statsJson =
            inner is Map && inner['stats'] is Map<String, dynamic>
                ? inner['stats'] as Map<String, dynamic>
                : <String, dynamic>{};
        final stats = ReviewStats.fromJson(statsJson);

        return RequestResponse(
          true,
          data: ReviewsWithStats(reviews: reviews, stats: stats),
        );
      } else {
        return RequestResponse(false, message: response.message);
      }
    } catch (e) {
      return RequestResponse(false, message: e.toString());
    }
  }
}
