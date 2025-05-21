// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get bust => 'Bust!';

  @override
  String get dealerBusts => 'Dealer busts!';

  @override
  String get dealerWins => 'Dealer wins!';

  @override
  String get youWin => 'You win!';

  @override
  String get push => 'Push!';

  @override
  String get dealerHand => 'Dealer\'s hand';

  @override
  String get yourHand => 'Your hand';

  @override
  String get yourValue => 'Your value';

  @override
  String get hit => 'Hit';

  @override
  String get stand => 'Stand';

  @override
  String get newGame => 'New Game';

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get guestModeSettingsDisabled => 'Please sign in to access settings';

  @override
  String get home => 'Home';

  @override
  String get about => 'About';

  @override
  String get settings => 'Settings';

  @override
  String get appTitle => 'Blackjack';

  @override
  String get aboutGame => 'About the Game';

  @override
  String get aboutGameDescription =>
      'Blackjack is a popular casino card game where players try to beat the dealer by getting a hand value closer to 21 without going over.';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get howToPlaySteps =>
      '1. Get as close to 21 as possible without going over\n2. Beat the dealer\'s hand\n3. Aces can be worth 1 or 11\n4. Face cards are worth 10';

  @override
  String get features => 'Features';

  @override
  String get featuresList =>
      '• Realistic card game experience\n• Multiple language support\n• Dark/Light theme\n• Guest mode available';

  @override
  String get playBlackjack => 'Play Blackjack';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get kazakh => 'Kazakh';

  @override
  String get signOut => 'Sign Out';
}
