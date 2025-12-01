// core/router/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:season_app/features/auth/presentation/screens/login_screen.dart';
import 'package:season_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:season_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:season_app/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:season_app/features/profile/presentation/screens/webview_screen.dart';
import 'package:season_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:season_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:season_app/features/auth/presentation/screens/verify_reset_otp_screen.dart';
import 'package:season_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:season_app/features/home/presentation/screens/main_screen.dart';
import 'package:season_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:season_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:season_app/features/vendor/presentation/screens/vendor_services_list_screen.dart';
import 'package:season_app/features/vendor/presentation/screens/vendor_service_form_screen.dart';
import 'package:season_app/features/vendor/presentation/screens/vendor_service_details_screen.dart';
import 'package:season_app/features/vendor/presentation/screens/location_picker_screen.dart';
import 'package:season_app/features/groups/presentation/screens/groups_list_screen.dart';
import 'package:season_app/features/groups/presentation/screens/group_details_screen.dart';
import 'package:season_app/features/groups/presentation/screens/create_group_screen.dart';
import 'package:season_app/features/groups/presentation/screens/join_group_screen.dart';
import 'package:season_app/features/groups/presentation/screens/qr_scanner_screen.dart';
import 'package:season_app/features/groups/presentation/screens/edit_group_screen.dart';
import 'package:season_app/features/groups/presentation/screens/sos_alerts_screen.dart';

import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    // refreshListenable: GoRouterRefreshStream(
      // ref.watch(authControllerProvider.notifier).authStateChanges,
    // ),
    redirect: (context, state) async {
      return null;
    
      // final user = ref.read(authControllerProvider).valueOrNull;
      // final isLoggingIn = state.location == Routes.login;
      //
      // // المستخدم مش داخل → رجعه على login
      // if (user == null && !isLoggingIn) return Routes.login;
      //
      // // المستخدم داخل → ميخشّش login تاني
      // if (user != null && isLoggingIn) return Routes.home;
      //
      // return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.verifyOtp,
        builder: (context, state) => const VerifyOtpScreen(),
      ),
      GoRoute(
        path: Routes.webview,
        builder: (context, state) {
          final url = state.uri.queryParameters['url'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          return WebViewScreen(url: url, title: title);
        },
      ),
      
      // Forgot Password Routes
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.verifyResetOtp,
        builder: (context, state) => const VerifyResetOtpScreen(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      
      // Home Route
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const MainScreen(),
      ),
      
      // Profile Routes
      GoRoute(
        path: Routes.profileEdit,
        builder: (context, state) => const EditProfileScreen(),
      ),
      
      // Settings Route
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Vendor Services
      GoRoute(
        path: Routes.vendorServices,
        builder: (context, state) => const VendorServicesListScreen(),
      ),
      GoRoute(
        path: Routes.vendorServiceNew,
        builder: (context, state) => const VendorServiceFormScreen(),
      ),
      GoRoute(
        path: Routes.vendorServiceEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return VendorServiceFormScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: Routes.vendorServiceDetails,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return VendorServiceDetailsScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: Routes.locationPicker,
        builder: (context, state) {
          final lat = double.tryParse(state.uri.queryParameters['lat'] ?? '0') ?? 0;
          final lng = double.tryParse(state.uri.queryParameters['lng'] ?? '0') ?? 0;
          return LocationPickerScreen(initialLat: lat, initialLng: lng);
        },
      ),
      
      // Groups Routes - Order matters! Specific routes before :id pattern
      GoRoute(
        path: '/groups',
        builder: (context, state) => const GroupsListScreen(),
      ),
      GoRoute(
        path: '/groups/create',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/groups/join',
        builder: (context, state) => const JoinGroupScreen(),
      ),
      GoRoute(
        path: '/groups/qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: '/groups/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return GroupDetailsScreen(groupId: id);
        },
      ),
      GoRoute(
        path: '/groups/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditGroupScreen(groupId: id);
        },
      ),
      GoRoute(
        path: '/groups/:id/sos',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SosAlertsScreen(groupId: id);
        },
      ),
    ],
  );
});
