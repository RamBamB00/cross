// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get bust => 'Перебор!';

  @override
  String get dealerBusts => 'Дилер перебрал!';

  @override
  String get dealerWins => 'Дилер выиграл!';

  @override
  String get youWin => 'Вы выиграли!';

  @override
  String get push => 'Ничья!';

  @override
  String get dealerHand => 'Карты дилера';

  @override
  String get yourHand => 'Ваши карты';

  @override
  String get yourValue => 'Ваше значение';

  @override
  String get hit => 'Взять карту';

  @override
  String get stand => 'Хватит';

  @override
  String get newGame => 'Новая игра';

  @override
  String get guestMode => 'Гостевой режим';

  @override
  String get guestModeSettingsDisabled =>
      'Пожалуйста, войдите для доступа к настройкам';

  @override
  String get home => 'Главная';

  @override
  String get about => 'О приложении';

  @override
  String get settings => 'Настройки';

  @override
  String get appTitle => 'Блэкджек';

  @override
  String get aboutGame => 'О игре';

  @override
  String get aboutGameDescription =>
      'Блэкджек - популярная карточная игра в казино, где игроки пытаются обыграть дилера, набрав комбинацию карт ближе к 21, не превышая это значение.';

  @override
  String get howToPlay => 'Как играть';

  @override
  String get howToPlaySteps =>
      '1. Наберите значение как можно ближе к 21, не превышая его\n2. Обыграйте руку дилера\n3. Туз может стоить 1 или 11\n4. Картинки стоят 10';

  @override
  String get features => 'Возможности';

  @override
  String get featuresList =>
      '• Реалистичный игровой процесс\n• Поддержка нескольких языков\n• Темная/Светлая тема\n• Доступен гостевой режим';

  @override
  String get playBlackjack => 'Играть в Блэкджек';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get english => 'Английский';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Казахский';

  @override
  String get signOut => 'Выйти';
}
