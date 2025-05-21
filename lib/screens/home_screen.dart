import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cross/l10n/app_localizations.dart';
import 'package:cross/screens/blackjack_screen.dart';
import 'package:cross/screens/about_screen.dart';
import 'package:cross/screens/settings_screen.dart';
import 'package:cross/providers/auth_provider.dart' as app;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<app.AuthProvider>(context);
    
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
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Guest Mode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
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
            if (authProvider.isGuestMode) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _showLoginRequiredDialog(context),
                child: const Text('Login to access all features'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 