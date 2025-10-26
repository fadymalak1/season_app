import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/core/services/firebase_service.dart';
import 'package:season_app/core/services/local_storage_service.dart';
import 'package:season_app/core/services/notification_service.dart';
import 'package:season_app/shared/providers/locale_provider.dart';
import 'package:season_app/shared/providers/theme_provider.dart';
import 'package:svg_image/svg_image.dart';
import 'core/localization/generated/l10n.dart';
import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage service
  await LocalStorageService.init();
  
  // Initialize SVG config
  await SvgImageConfig.init();

  // Initialize Firebase and Notifications
  try {
    await FirebaseService.initialize();
    
    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('❌ Error initializing Firebase: $e');
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
              AppLocalizations.delegate, // من الـ Flutter Intl
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.welcome),
            const SizedBox(height: 16),
            Text(loc.helloUser('Fady')),
          ],
        ),
      ),
    );
  }
}
