import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cross/providers/auth_provider.dart';
import 'package:cross/providers/connectivity_provider.dart';
import 'package:cross/providers/theme_provider.dart';
import 'package:cross/providers/language_provider.dart';
import 'package:cross/services/local_storage_service.dart';
import 'package:cross/services/game_history_service.dart';
import 'package:cross/screens/home_screen.dart';
import 'package:cross/screens/login_screen.dart';
import 'package:cross/screens/about_screen.dart';
import 'package:cross/screens/settings_screen.dart';
import 'package:cross/screens/blackjack_screen.dart';
import 'package:cross/screens/history_screen.dart';
import 'package:cross/l10n/app_localizations.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStorageService.init();
  await GameHistoryService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: 'Blackjack App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.dark,
              ),
            ),
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
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/about': (context) => const AboutScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/blackjack': (context) => const BlackjackScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          );
        },
      ),
    );
  }
}
