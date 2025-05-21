import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cross/l10n/app_localizations.dart';
import 'package:cross/screens/blackjack_screen.dart';
import 'package:cross/screens/about_screen.dart';
import 'package:cross/screens/settings_screen.dart';
import 'package:cross/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (authProvider.isGuestMode)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                authProvider.exitGuestMode();
                Navigator.pushReplacementNamed(context, '/');
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authProvider.isGuestMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Guest Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlackjackScreen()),
                );
              },
              child: Text(l10n.playBlackjack),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
              child: Text(l10n.about),
            ),
          ],
        ),
      ),
    );
  }
} 