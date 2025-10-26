class ApiEndpoints {
  // 🌍 Base URL
  static const String baseUrl = 'https://seasonksa.com/api';

  // 🔐 Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resendResetOtp = '/auth/resend-reset-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String authProfile = '/auth/profile';

  // 👤 Profile
  static const String profile = '/profile';
  static const String updateProfile = '/profile';

  // 🏠 Home
  static const String getPosts = '/posts';
  static const String getPostDetails = '/posts/{id}';

  // ⚙️ Settings
  static const String changePassword = '/user/change-password';
}
