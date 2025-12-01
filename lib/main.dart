import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/core/services/firebase_service.dart';
import 'package:season_app/core/services/local_storage_service.dart';
import 'package:season_app/core/services/notification_service.dart';
import 'package:season_app/core/services/background_location_service.dart';
import 'package:season_app/shared/providers/locale_provider.dart';
import 'package:season_app/shared/providers/theme_provider.dart';
import 'core/localization/generated/l10n.dart';
import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage service
  await LocalStorageService.init();
  
  // Initialize Firebase and Notifications
  try {
    await FirebaseService.initialize();
    
    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('❌ Error initializing Firebase: $e');
  }

  // Initialize background location service
  try {
    await initializeBackgroundLocationService();
  } catch (e) {
    debugPrint('Error initializing background location service: $e');
  }

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);


    return Consumer(
        builder:(context,ref,_){
          final themeMode = ref.watch(themeProvider);

          return MaterialApp.router(
            title: 'Season App',
            debugShowCheckedModeBanner: false,
            locale: locale,
            theme: AppTheme.lightTheme,
            themeMode: themeMode,
            supportedLocales: AppLocalizations.delegate.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          );
        }
    );
  }
}
