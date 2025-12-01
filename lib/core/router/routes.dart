// core/router/routes.dart
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  static const String welcome = '/welcome';
  static const String verifyOtp = '/verifyOtp';
  static const String webview = '/webview';
  // Vendor services
  static const String vendorServices = '/vendor/services';
  static const String vendorServiceNew = '/vendor/services/new';
  static const String vendorServiceEdit = '/vendor/services/:id/edit';
  static const String vendorServiceDetails = '/vendor/services/:id';
  static const String locationPicker = '/location/picker';
  
  // Forgot Password Routes
  static const String forgotPassword = '/forgotPassword';
  static const String verifyResetOtp = '/verifyResetOtp';
  static const String resetPassword = '/resetPassword';
}
