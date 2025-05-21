import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Blackjack Game',
      'home': 'Home',
      'about': 'About',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'english': 'English',
      'russian': 'Russian',
      'kazakh': 'Kazakh',
      'signOut': 'Sign Out',
      'playBlackjack': 'Play Blackjack',
      'aboutGame': 'About the Game',
      'aboutGameDescription': 'Blackjack is a popular card game where players try to get a hand value as close to 21 as possible without going over.',
      'howToPlay': 'How to Play',
      'howToPlaySteps': '1. Place your bet\n2. Get two cards\n3. Hit to get more cards\n4. Stand to keep your hand\n5. Try to beat the dealer',
      'features': 'Features',
      'featuresList': '• Multiple languages\n• Dark/Light theme\n• User authentication\n• Save preferences',
    },
    'ru': {
      'appTitle': 'Игра Блэкджек',
      'home': 'Главная',
      'about': 'О игре',
      'settings': 'Настройки',
      'theme': 'Тема',
      'language': 'Язык',
      'english': 'English',
      'russian': 'Русский',
      'kazakh': 'Қазақша',
      'signOut': 'Выйти',
      'playBlackjack': 'Играть в Блэкджек',
      'aboutGame': 'Об игре',
      'aboutGameDescription': 'Блэкджек - популярная карточная игра, где игроки пытаются набрать комбинацию карт, максимально близкую к 21, не превышая это значение.',
      'howToPlay': 'Как играть',
      'howToPlaySteps': '1. Сделайте ставку\n2. Получите две карты\n3. Возьмите карту для получения дополнительных карт\n4. Остановитесь, чтобы сохранить текущую комбинацию\n5. Попробуйте обыграть дилера',
      'features': 'Возможности',
      'featuresList': '• Несколько языков\n• Темная/Светлая тема\n• Аутентификация пользователей\n• Сохранение настроек',
    },
    'kk': {
      'appTitle': 'Блэкджек Ойыны',
      'home': 'Басты бет',
      'about': 'Ойын туралы',
      'settings': 'Баптаулар',
      'theme': 'Тақырып',
      'language': 'Тіл',
      'english': 'English',
      'russian': 'Русский',
      'kazakh': 'Қазақша',
      'signOut': 'Шығу',
      'playBlackjack': 'Блэкджек Ойнау',
      'aboutGame': 'Ойын туралы',
      'aboutGameDescription': 'Блэкджек - ойыншылар 21-ге жақын, бірақ одан аспайтын карталар комбинациясын жинауға тырысатын танымал карта ойыны.',
      'howToPlay': 'Қалай ойнау керек',
      'howToPlaySteps': '1. Бәс қойыңыз\n2. Екі карта алыңыз\n3. Қосымша карта алу үшін карта алыңыз\n4. Қолды сақтау үшін тоқтаңыз\n5. Дилерді жеңуге тырысыңыз',
      'features': 'Мүмкіндіктер',
      'featuresList': '• Бірнеше тілдер\n• Қара/Ақ тақырып\n• Пайдаланушы аутентификациясы\n• Баптауларды сақтау',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get russian => _localizedValues[locale.languageCode]!['russian']!;
  String get kazakh => _localizedValues[locale.languageCode]!['kazakh']!;
  String get signOut => _localizedValues[locale.languageCode]!['signOut']!;
  String get playBlackjack => _localizedValues[locale.languageCode]!['playBlackjack']!;
  String get aboutGame => _localizedValues[locale.languageCode]!['aboutGame']!;
  String get aboutGameDescription => _localizedValues[locale.languageCode]!['aboutGameDescription']!;
  String get howToPlay => _localizedValues[locale.languageCode]!['howToPlay']!;
  String get howToPlaySteps => _localizedValues[locale.languageCode]!['howToPlaySteps']!;
  String get features => _localizedValues[locale.languageCode]!['features']!;
  String get featuresList => _localizedValues[locale.languageCode]!['featuresList']!;

  // Blackjack game strings
  String get bust => 'Bust!';
  String get dealerBusts => 'Dealer busts!';
  String get dealerWins => 'Dealer wins!';
  String get youWin => 'You win!';
  String get push => 'Push!';
  String get dealerHand => 'Dealer\'s hand';
  String get yourHand => 'Your hand';
  String get yourValue => 'Your value';
  String get hit => 'Hit';
  String get stand => 'Stand';
  String get newGame => 'New Game';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'kk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 