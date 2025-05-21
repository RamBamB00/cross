import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cross/providers/auth_provider.dart';
import 'package:cross/providers/connectivity_provider.dart';
import 'package:cross/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!connectivityProvider.isOnline)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  l10n.offlineMode,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ),
            if (authProvider.isAuthenticated)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${l10n.loggedInAs} ${authProvider.currentUser?.email}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/blackjack'),
              child: Text(l10n.playBlackjack),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/history'),
              child: Text(l10n.gameHistory),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/about'),
              child: Text(l10n.about),
            ),
            if (!authProvider.isAuthenticated && !authProvider.isGuestMode)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(l10n.login),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 