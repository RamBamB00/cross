import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cross/providers/theme_provider.dart';
import 'package:cross/providers/language_provider.dart';
import 'package:cross/providers/auth_provider.dart';
import 'package:cross/screens/home_screen.dart';
import 'package:cross/screens/login_screen.dart';
import 'package:cross/screens/about_screen.dart';
import 'package:cross/screens/settings_screen.dart';
import 'package:cross/screens/blackjack_screen.dart';
import 'package:cross/l10n/app_localizations.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: 'Blackjack',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
              Locale('kk'),
            ],
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return StreamBuilder(
                  stream: authProvider.authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData) {
                      return const HomeScreen();
                    }
                    return const LoginScreen();
                  },
                );
              },
            ),
            routes: {
              '/about': (context) => const AboutScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/blackjack': (context) => const BlackjackScreen(),
            },
          );
        },
      ),
    );
  }
}
