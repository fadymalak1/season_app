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
      "notification_token": notificationToken ?? "",
    };

    final response = await dio.post(
      ApiEndpoints.register,
      data: data,
    );

    return response;
  }
}
