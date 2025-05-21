import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cross/providers/theme_provider.dart';
import 'package:cross/providers/language_provider.dart';
import 'package:cross/providers/auth_provider.dart';
import 'package:cross/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.theme),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (bool value) async {
                themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                if (authProvider.currentUser != null) {
                  await authProvider.savePreferences({
                    'darkMode': value,
                    'language': languageProvider.locale.languageCode,
                  });
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: languageProvider.locale.languageCode,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l10n.english),
                ),
                DropdownMenuItem(
                  value: 'ru',
                  child: Text(l10n.russian),
                ),
                DropdownMenuItem(
                  value: 'kk',
                  child: Text(l10n.kazakh),
                ),
              ],
              onChanged: (String? value) async {
                if (value != null) {
                  languageProvider.setLocale(Locale(value));
                  if (authProvider.currentUser != null) {
                    await authProvider.savePreferences({
                      'darkMode': themeProvider.isDarkMode,
                      'language': value,
                    });
                  }
                }
              },
            ),
          ),
          if (authProvider.currentUser != null) ...[
            ListTile(
              title: Text(l10n.signOut),
              trailing: const Icon(Icons.logout),
              onTap: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
            ListTile(
              title: const Text('Debug Info'),
              trailing: const Icon(Icons.bug_report),
              onTap: () {
                Navigator.pushNamed(context, '/debug');
              },
            ),
          ],
        ],
      ),
    );
  }
} 