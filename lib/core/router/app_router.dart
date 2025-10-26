// core/router/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:season_app/features/auth/presentation/screens/login_screen.dart';
import 'package:season_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:season_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:season_app/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:season_app/features/auth/presentation/screens/web_view_screen.dart';
import 'package:season_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:season_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:season_app/features/auth/presentation/screens/verify_reset_otp_screen.dart';
import 'package:season_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:season_app/features/home/presentation/screens/main_screen.dart';
import 'package:season_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:season_app/features/profile/presentation/screens/settings_screen.dart';

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
        builder: (context, state) => const WebViewScreen(title: '', url: '',),
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
    ],
  );
});
