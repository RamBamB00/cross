import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Глобальный ключ для доступа к состоянию MyApp (для переключения темы и языка)
final GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

void main() {
  runApp(MyApp(key: myAppKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Начальные настройки
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('kk');
  
  // Переключение темы: если светлая, то переключаем на зелёную тему, иначе – на белую
  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }
  
  // Циклическое переключение языков: kk -> ru -> en -> kk...
  void cycleLocale() {
    final locales = const [Locale('kk'), Locale('ru'), Locale('en')];
    int currentIndex = locales.indexWhere((l) => l.languageCode == _locale.languageCode);
    int nextIndex = (currentIndex + 1) % locales.length;
    setState(() {
      _locale = locales[nextIndex];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Определяем нашу светлую и "зелёную" тёмную тему
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
    
    final ThemeData greenDarkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.green[800],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      primarySwatch: Colors.green,
    );
    
    return MaterialApp(
      title: 'Flutter Blackjack',
      theme: lightTheme,
      darkTheme: greenDarkTheme,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('kk'),
      ],
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('kk');
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('kk');
      },
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  static final List<Widget> _pages = [
    const BlackjackScreen(),
    const AboutPage(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Play'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Страница игры, демонстрирующая работу жестов, динамических обновлений UI и локализации.
class BlackjackScreen extends StatefulWidget {
  const BlackjackScreen({super.key});
  
  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  List<String> playerCards = ['🂡', '🂱'];
  List<String> dealerCards = ['🂠', '🂡'];
  String statusText = '';
  
  Map<int, bool> cardFlipped = {};
  
  final Random rnd = Random();
  final List<String> cardFaces = ['🂡', '🂱', '🃁', '🃑', '🂮', '🂭'];
  
  @override
  Widget build(BuildContext context) {
    // Получаем локализованные строки
    final loc = AppLocalizations.of(context)!;
    // Если статус еще не установлен, задаем начальное значение
    if (statusText.isEmpty) {
      statusText = loc.yourTurn;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.blackjackTable),
        actions: [
          // Кнопка для переключения темы
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              myAppKey.currentState?.toggleTheme();
            },
          ),
          // Кнопка для переключения языка
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              myAppKey.currentState?.cycleLocale();
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          final layout = _buildGameLayout(isPortrait, loc);
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isPortrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: layout,
                    )
                  : Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  layout[0], // Блок дилера
                                  const SizedBox(height: 20),
                                  layout[1], // Статус игры
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  layout[2], // Блок игрока
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        layout[3], // Кнопки управления
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
  
  List<Widget> _buildGameLayout(bool isPortrait, AppLocalizations loc) {
    // Ряд карточек дилера с жестом onTap для случайной смены изображения карточки.
    Widget dealerCardsRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dealerCards.asMap().entries.map((entry) {
        int idx = entry.key;
        String card = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
            onTap: () {
              setState(() {
                dealerCards[idx] = cardFaces[rnd.nextInt(cardFaces.length)];
              });
            },
            child: CardWidget(cardText: card),
          ),
        );
      }).toList(),
    );
    
    // Ряд карточек игрока с жестами: onTap (переключает карточку) и onLongPress (показывает SnackBar).
    Widget playerCardsRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: playerCards.asMap().entries.map((entry) {
        int idx = entry.key;
        String card = entry.value;
        bool flipped = cardFlipped[idx] ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
            onTap: () {
              setState(() {
                cardFlipped[idx] = !flipped;
                if (cardFlipped[idx] == true) {
                  playerCards[idx] = cardFaces[rnd.nextInt(cardFaces.length)];
                } else {
                  playerCards[idx] = '🂡';
                }
              });
            },
            onLongPress: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Card ${idx + 1} long pressed!')),
              );
            },
            child: CardWidget(cardText: card),
          ),
        );
      }).toList(),
    );
    
    // Кнопки управления. При нажатии обновляется статус с локализованными сообщениями.
    Widget controls = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 10,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                playerCards.add(cardFaces[rnd.nextInt(cardFaces.length)]);
                cardFlipped[playerCards.length - 1] = false;
                statusText = '${loc.hit}! ${loc.cardAdded}';
              });
            },
            child: Text(loc.hit),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                statusText = loc.standMessage;
              });
            },
            child: Text(loc.stand),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                statusText = loc.doubleMessage;
              });
            },
            child: Text(loc.doubleAction),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                playerCards = ['🂡', '🂱'];
                dealerCards = ['🂠', '🂡'];
                cardFlipped.clear();
                statusText = loc.gameRestarted;
              });
            },
            child: Text(loc.restart),
          ),
        ],
      ),
    );
    
    // Статус игры.
    Widget statusBar = Center(
      child: Text(
        statusText,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
    
    return [
      ExpandedSection(title: loc.blackjackTable, child: dealerCardsRow),
      statusBar,
      ExpandedSection(title: loc.blackjackTable, child: playerCardsRow),
      controls,
    ];
  }
}

/// Виджет, представляющий игровую карточку.
class CardWidget extends StatelessWidget {
  final String cardText;
  const CardWidget({super.key, required this.cardText});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text(
        cardText,
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}

/// Виджет для группировки секций с заголовком.
class ExpandedSection extends StatelessWidget {
  final String title;
  final Widget child;
  const ExpandedSection({super.key, required this.title, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

/// Страница "О игре", с локализацией.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.aboutTheGame),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              myAppKey.currentState?.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              myAppKey.currentState?.cycleLocale();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.flutterBlackjackGame,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            Text(
              loc.thisIsBlackjack,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              loc.developers,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              '• Daniil Naumenko\n• Ramazan Abytaiev\n',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              loc.mentor,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Professor Abzal Kyzyrkanov',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                loc.enjoyYourGame,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Класс локализации: хранит переводы для разных языков.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'blackjack_table': 'Blackjack Table',
      'your_turn': 'Your Turn!',
      'hit': 'Hit',
      'stand': 'Stand',
      'double': 'Double',
      'restart': 'Restart',
      'card_added': 'Card added.',
      'stand_message': 'Stand! Waiting...',
      'double_message': 'Double! Bet increased.',
      'game_restarted': 'Game restarted!',
      'about_the_game': 'About the Game',
      'flutter_blackjack_game': 'Flutter Blackjack Game',
      'this_is_blackjack': 'This is a simple Flutter-based Blackjack game where players can enjoy the classic card game experience.',
      'developers': 'Developers:',
      'mentor': 'Mentor:',
      'enjoy_your_game': 'Enjoy your game!',
    },
    'ru': {
      'blackjack_table': 'Стол для блэкджека',
      'your_turn': 'Ваш ход!',
      'hit': 'Взять карту',
      'stand': 'Остаться',
      'double': 'Удвоить',
      'restart': 'Начать заново',
      'card_added': 'Карта добавлена.',
      'stand_message': 'Остаться! Ожидание...',
      'double_message': 'Удвоить! Ставка увеличена.',
      'game_restarted': 'Игра начата заново!',
      'about_the_game': 'О игре',
      'flutter_blackjack_game': 'Игра Блэкджек на Flutter',
      'this_is_blackjack': 'Это простая игра Блэкджек на Flutter, где игроки могут насладиться классическим игровым процессом.',
      'developers': 'Разработчики:',
      'mentor': 'Наставник:',
      'enjoy_your_game': 'Приятной игры!',
    },
    'kk': {
      'blackjack_table': 'Блэкджек үстелі',
      'your_turn': 'Сіздің кезегіңіз!',
      'hit': 'Карта алу',
      'stand': 'Болмау',
      'double': 'Қосарлау',
      'restart': 'Қайта бастау',
      'card_added': 'Карта қосылды.',
      'stand_message': 'Болмау! Күту...',
      'double_message': 'Қосарлау! Ставка артты.',
      'game_restarted': 'Ойын қайта басталды!',
      'about_the_game': 'Ойын туралы',
      'flutter_blackjack_game': 'Flutter Блэкджек ойыны',
      'this_is_blackjack': 'Бұл қарапайым Flutter негізіндегі Блэкджек ойыны, мұнда ойыншылар классикалық карта ойынын ойнай алады.',
      'developers': 'Дамытушылар:',
      'mentor': 'Ментор:',
      'enjoy_your_game': 'Ойынды рақаттаныңыз!',
    },
  };
  
  String get blackjackTable => _localizedValues[locale.languageCode]?['blackjack_table'] ?? '';
  String get yourTurn => _localizedValues[locale.languageCode]?['your_turn'] ?? '';
  String get hit => _localizedValues[locale.languageCode]?['hit'] ?? '';
  String get stand => _localizedValues[locale.languageCode]?['stand'] ?? '';
  String get doubleAction => _localizedValues[locale.languageCode]?['double'] ?? '';
  String get restart => _localizedValues[locale.languageCode]?['restart'] ?? '';
  String get cardAdded => _localizedValues[locale.languageCode]?['card_added'] ?? '';
  String get standMessage => _localizedValues[locale.languageCode]?['stand_message'] ?? '';
  String get doubleMessage => _localizedValues[locale.languageCode]?['double_message'] ?? '';
  String get gameRestarted => _localizedValues[locale.languageCode]?['game_restarted'] ?? '';
  String get aboutTheGame => _localizedValues[locale.languageCode]?['about_the_game'] ?? '';
  String get flutterBlackjackGame => _localizedValues[locale.languageCode]?['flutter_blackjack_game'] ?? '';
  String get thisIsBlackjack => _localizedValues[locale.languageCode]?['this_is_blackjack'] ?? '';
  String get developers => _localizedValues[locale.languageCode]?['developers'] ?? '';
  String get mentor => _localizedValues[locale.languageCode]?['mentor'] ?? '';
  String get enjoyYourGame => _localizedValues[locale.languageCode]?['enjoy_your_game'] ?? '';
}

/// Делегат локализации для AppLocalizations.
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) => ['en', 'ru', 'kk'].contains(locale.languageCode);
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
