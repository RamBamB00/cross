import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isLandscape ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appTitle,
                    style: TextStyle(
                      fontSize: isLandscape ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isLandscape ? 24 : 20),
                  Text(
                    l10n.aboutGame,
                    style: TextStyle(
                      fontSize: isLandscape ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isLandscape ? 16 : 10),
                  Text(
                    l10n.aboutGameDescription,
                    style: TextStyle(fontSize: isLandscape ? 18 : 16),
                  ),
                  SizedBox(height: isLandscape ? 24 : 20),
                  Text(
                    l10n.howToPlay,
                    style: TextStyle(
                      fontSize: isLandscape ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isLandscape ? 16 : 10),
                  Text(
                    l10n.howToPlaySteps,
                    style: TextStyle(fontSize: isLandscape ? 18 : 16),
                  ),
                  SizedBox(height: isLandscape ? 24 : 20),
                  Text(
                    l10n.features,
                    style: TextStyle(
                      fontSize: isLandscape ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isLandscape ? 16 : 10),
                  Text(
                    l10n.featuresList,
                    style: TextStyle(fontSize: isLandscape ? 18 : 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/about');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
} 