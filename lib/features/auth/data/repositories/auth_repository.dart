import 'package:dio/dio.dart';
import 'package:season_app/features/auth/data/datasources/auth_datasource.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository(this.remoteDataSource);

  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? notificationToken,
  }) async {
    try {
      final response = await remoteDataSource.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        notificationToken: notificationToken,
      );

      if (response.statusCode == 201) {
        return response.data["message"] ?? "OTP sent successfully.";
      } else {
        throw Exception(response.data["message"] ?? "Registration failed");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data['errors'];
        final message = e.response?.data['message'] ?? 'حدث خطأ غير متوقع';
        throw Exception(message);
      } else {
        throw Exception('حدث خطأ أثناء التسجيل');
      }
    }
  }
}
