// core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:season_app/features/auth/presentation/screens/login_screen.dart';
import 'package:season_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:season_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:season_app/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:season_app/features/auth/presentation/screens/web_view_screen.dart';
import 'package:season_app/features/auth/presentation/screens/welcome_screen.dart';

import 'go_router_refresh.dart';
import 'routes.dart';
import 'guards/auth_guard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    // refreshListenable: GoRouterRefreshStream(
      // ref.watch(authControllerProvider.notifier).authStateChanges,
    // ),
    redirect: (context, state) async {
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
    ],
  );
});
