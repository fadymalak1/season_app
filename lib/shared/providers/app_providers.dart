import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:season_app/core/constants/api_endpoints.dart';
import 'package:season_app/core/services/dio_client.dart';
import 'package:season_app/core/services/auth_service.dart';
import 'package:season_app/shared/providers/locale_provider.dart';

// DioHelper provider (singleton) - initialized once
final dioHelperProvider = Provider<DioHelper>((ref) {
  final helper = DioHelper.instance;
  
  // Initialize DioHelper only once
  helper.initialize(
    baseUrl: ApiEndpoints.baseUrl,
    enableLogging: true,
    headers: {
      'Accept-Language': 'en', // Default language, will be updated by dioProvider
    },
  );

  // Load and set stored token if available
  final storedToken = AuthService.getToken();
  if (storedToken != null && storedToken.isNotEmpty) {
    helper.setAccessToken(storedToken);
  }

  return helper;
});

// Provide Dio instance ready to use with reactive language updates
final dioProvider = Provider<Dio>((ref) {
  final helper = ref.watch(dioHelperProvider);
  final locale = ref.watch(localeProvider);
  
  // Update Accept-Language header when locale changes
  helper.setHeaders({'Accept-Language': locale.languageCode});
  
  // Ensure token is set (in case it changed)
  final storedToken = AuthService.getToken();
  if (storedToken != null && storedToken.isNotEmpty) {
    helper.setAccessToken(storedToken);
  }
  
  return helper.dio;
});
