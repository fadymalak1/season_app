class ApiEndpoints {
  // 🌍 Base URL
  static const String baseUrl = 'https://seasonksa.com/api';

  // 🔐 Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // 🏠 Home
  static const String getPosts = '/posts';
  static const String getPostDetails = '/posts/{id}';

  // ⚙️ Settings
  static const String updateProfile = '/user/update';
  static const String changePassword = '/user/change-password';
}
