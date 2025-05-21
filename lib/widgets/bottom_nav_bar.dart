import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final isGuestMode = authProvider.isGuestMode;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isGuestMode)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                l10n.guestMode,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (isGuestMode) {
              onTap(index);
              return;
            }
            // Not guest mode: allow all
            onTap(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.info),
              label: l10n.about,
            ),
            if (!isGuestMode)
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: l10n.settings,
              ),
          ],
        ),
      ],
    );
  }
} 