import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blackjack',
      theme: ThemeData(primarySwatch: Colors.blue),
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

class BlackjackScreen extends StatelessWidget {
  const BlackjackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blackjack Table')),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          final layout = _buildGameLayout();

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
                                  layout[0], // Dealer
                                  const SizedBox(height: 20),
                                  layout[1], // Status
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  layout[2], // Player
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        layout[3], // Controls
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildGameLayout() {
    final playerCards = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CardWidget(cardText: '🂡'),
        SizedBox(width: 10),
        CardWidget(cardText: '🂱'),
      ],
    );

    final dealerCards = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CardWidget(cardText: '🂠'),
        SizedBox(width: 10),
        CardWidget(cardText: '🂡'),
      ],
    );

    final controls = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 10,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton(onPressed: () {}, child: const Text('Hit')),
          ElevatedButton(onPressed: () {}, child: const Text('Stand')),
          ElevatedButton(onPressed: () {}, child: const Text('Double')),
          ElevatedButton(onPressed: () {}, child: const Text('Restart')),
        ],
      ),
    );

    final statusBar = const Center(
      child: Text(
        'Your Turn!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );

    return [
      ExpandedSection(title: 'Dealer', child: dealerCards),
      statusBar,
      ExpandedSection(title: 'Player', child: playerCards),
      controls,
    ];
  }
}

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

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About the Game')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '🎲 Flutter Blackjack Game 🎲',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            Text(
              'This is a simple Flutter-based Blackjack game where players can enjoy the classic card game experience.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              '👨‍💻 Developers:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '• Daniil Naumenko\n• Ramazan Abytaiev\n',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              '📌 Mentor:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Professor Abzal Kyzyrkanov',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                '🎮 Enjoy your game! 🎮',
                style: TextStyle(
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
