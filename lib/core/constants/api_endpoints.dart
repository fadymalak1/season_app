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
  static const String userQr = '/user/qr';

  // 🏠 Home
  static const String getPosts = '/posts';
  static const String getPostDetails = '/posts/{id}';

  // ⚙️ Settings
  static const String changePassword = '/user/change-password';

  // 🧑‍🔧 Vendor Services
  static const String serviceTypes = '/service-types';
  static const String vendorServices = '/vendor-services';
  static const String vendorServiceById = '/vendor-services/{id}';
  static const String vendorServiceEnable = '/vendor-services/{id}/enable';
  static const String vendorServiceForceDelete = '/vendor-services/{id}/forceDelete';

  // 🎒 Bag & Reminders
  static const String reminders = '/reminders';
  static const String reminderById = '/reminders/{id}';
  static const String bagTypes = '/bag-types';
  static const String bagCategories = '/categories';
  static const String bagCategoryItems = '/categories/items';
  static const String bagDetails = '/travel-bag/details';
  static const String bagAddItem = '/travel-bag/add-item';
  static const String bagDeleteItem = '/travel-bag/items/{item_id}';
  static const String bagUpdateItemQuantity = '/travel-bag/items/{item_id}/quantity';
}
