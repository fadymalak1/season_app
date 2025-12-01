import 'package:dio/dio.dart';
import 'package:season_app/core/constants/api_endpoints.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<Response> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? notificationToken,
  }) async {
    final data = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "fcm_token": notificationToken ?? "",
    };

    final response = await dio.post(
      ApiEndpoints.register,
      data: data,
    );

    return response;
  }

  Future<Response> loginUser({
    required String email,
    required String password,
    String? notificationToken,
  }) async {
    final data = {
      "email": email,
      "password": password,
      "fcm_token": notificationToken ?? "",
    };

    final response = await dio.post(
      ApiEndpoints.login,
      data: data,
    );

    return response;
  }

  Future<Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final data = {
      "email": email,
      "otp": otp,
    };

    final response = await dio.post(
      ApiEndpoints.verifyOtp,
      data: data,
    );

    return response;
  }

  Future<Response> resendOtp({
    required String email,
  }) async {
    final data = {
      "email": email,
    };

    final response = await dio.post(
      ApiEndpoints.resendOtp,
      data: data,
    );

    return response;
  }

  Future<Response> forgotPassword({
    required String email,
  }) async {
    final data = {
      "email": email,
    };

    final response = await dio.post(
      ApiEndpoints.forgotPassword,
      data: data,
    );

    return response;
  }

  Future<Response> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final data = {
      "email": email,
      "otp": otp,
    };

    final response = await dio.post(
      ApiEndpoints.verifyResetOtp,
      data: data,
    );

    return response;
  }

  Future<Response> resendResetOtp({
    required String email,
  }) async {
    final data = {
      "email": email,
    };

    final response = await dio.post(
      ApiEndpoints.resendResetOtp,
      data: data,
    );

    return response;
  }

  Future<Response> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = {
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    final response = await dio.post(
      ApiEndpoints.resetPassword,
      data: data,
    );

    return response;
  }
}
