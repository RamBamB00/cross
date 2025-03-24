import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _displayText = '';
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;

  // Add Text
  void _addText() {
    setState(() {
      _displayText = 'Hello, Flutter!';
    });
  }

  // Remove Text
  void _removeText() {
    setState(() {
      _displayText = '';
    });
  }

  // Change Background Color
  void _changeBackgroundColor() {
    setState(() {
      _backgroundColor = _backgroundColor == Colors.white
          ? Colors.lightBlueAccent
          : Colors.white;
    });
  }

  // Toggle Text Color
  void _toggleTextColor() {
    setState(() {
      _textColor = _textColor == Colors.black ? Colors.red : Colors.black;
    });
  }

  // Show Alert Dialog
  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text('This is a sample alert message.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Task App')),
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              color: Colors.white,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _displayText,
                  style: TextStyle(fontSize: 24, color: _textColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            _buildButton('Add Text', _addText),
            _buildButton('Remove Text', _removeText),
            _buildButton('Change Background', _changeBackgroundColor),
            _buildButton('Toggle Text Color', _toggleTextColor),
            _buildButton('Show Alert', _showAlertDialog),
          ],
        ),
      ),
    );
  }

  // Custom button for cleaner UI
  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
