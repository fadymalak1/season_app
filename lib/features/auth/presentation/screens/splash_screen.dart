import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:season_app/core/constants/app_assets.dart';
import 'package:season_app/core/constants/app_colors.dart';
import 'package:season_app/core/router/routes.dart';
import 'package:season_app/core/services/auth_service.dart';
import 'package:season_app/core/services/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/shared/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  void _checkAuthStatus() {
    Timer(const Duration(seconds: 3), () {
      // Ensure DioHelper is initialized
      ref.read(dioHelperProvider);
      
      // Check if user is already logged in
      final isLoggedIn = AuthService.isLoggedIn();
      final token = AuthService.getToken();
      
      if (isLoggedIn && token != null && token.isNotEmpty) {
        // Set token in DioHelper
        DioHelper.instance.setAccessToken(token);
        // User is logged in, go to home
        context.go(Routes.home);
      } else {
        // User is not logged in, go to welcome
        context.go(Routes.welcome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset(
          AppAssets.appLogo,
          width: MediaQuery.of(context).size.width / 3,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
