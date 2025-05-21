import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.theme),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  themeProvider.setThemeMode(newMode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.lightTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.darkTheme),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: languageProvider.locale.languageCode,
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  languageProvider.setLocale(Locale(newLanguage));
                }
              },
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
            ),
          ),
          if (!authProvider.isGuestMode)
            ListTile(
              title: Text(l10n.signOut),
              leading: const Icon(Icons.logout),
              onTap: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
            ),
        ],
      ),
    );
  }
} 