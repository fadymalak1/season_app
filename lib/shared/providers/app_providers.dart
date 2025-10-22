import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:season_app/core/constants/api_endpoints.dart';
import 'package:season_app/core/services/dio_client.dart';

// DioHelper provider (singleton)
final dioHelperProvider = Provider<DioHelper>((ref) {
  final helper = DioHelper.instance;

  helper.initialize(
    baseUrl: ApiEndpoints.baseUrl,
    enableLogging: true,
  );

  return helper;
});

// Provide Dio instance ready to use
final dioProvider = Provider<Dio>((ref) {
  final helper = ref.watch(dioHelperProvider);
  return helper.dio;
});
