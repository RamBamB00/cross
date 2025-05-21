import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/connectivity_provider.dart';
import '../services/local_storage_service.dart';
import '../providers/auth_provider.dart';
import '../models/game_history.dart';
import '../services/game_history_service.dart';

class BlackjackScreen extends StatefulWidget {
  const BlackjackScreen({super.key});

  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  final List<String> deck = [];
  final List<String> playerHand = [];
  final List<String> dealerHand = [];
  bool gameOver = false;
  String message = '';
  bool _isLoading = false;
  bool _hasPendingSync = false;

  @override
  void initState() {
    super.initState();
    _loadGameState();
  }

  Future<void> _loadGameState() async {
    setState(() => _isLoading = true);
    try {
      final savedState = LocalStorageService.getGameState();
      if (savedState != null) {
        setState(() {
          deck.clear();
          deck.addAll(List<String>.from(savedState['deck'] ?? []));
          playerHand.clear();
          playerHand.addAll(List<String>.from(savedState['playerHand'] ?? []));
          dealerHand.clear();
          dealerHand.addAll(List<String>.from(savedState['dealerHand'] ?? []));
          gameOver = savedState['gameOver'] ?? false;
          message = savedState['message'] ?? '';
        });
      } else {
        initializeDeck();
        startNewGame();
      }
    } catch (e) {
      initializeDeck();
      startNewGame();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveGameState() async {
    final gameState = {
      'deck': deck,
      'playerHand': playerHand,
      'dealerHand': dealerHand,
      'gameOver': gameOver,
      'message': message,
    };
    await LocalStorageService.saveGameState(gameState);
  }

  void initializeDeck() {
    final List<String> suits = ['♠', '♥', '♦', '♣'];
    final List<String> values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    
    deck.clear();
    for (var suit in suits) {
      for (var value in values) {
        deck.add('$value$suit');
      }
    }
  }

  void shuffleDeck() {
    deck.shuffle(Random());
  }

  String drawCard() {
    if (deck.isEmpty) {
      initializeDeck();
      shuffleDeck();
    }
    return deck.removeLast();
  }

  int calculateHandValue(List<String> hand) {
    int totalValue = 0;
    int aces = 0;

    for (var card in hand) {
      String cardValue = card.substring(0, card.length - 1);
      if (cardValue == 'A') {
        aces += 1;
      } else if (cardValue == 'K' || cardValue == 'Q' || cardValue == 'J') {
        totalValue += 10;
      } else {
        totalValue += int.parse(cardValue);
      }
    }

    for (int i = 0; i < aces; i++) {
      if (totalValue + 11 <= 21) {
        totalValue += 11;
      } else {
        totalValue += 1;
      }
    }

    return totalValue;
  }

  Future<void> startNewGame() async {
    setState(() => _isLoading = true);
    try {
      setState(() {
        playerHand.clear();
        dealerHand.clear();
        gameOver = false;
        message = '';
        
        shuffleDeck();
        
        // Deal initial cards
        playerHand.add(drawCard());
        dealerHand.add(drawCard());
        playerHand.add(drawCard());
        dealerHand.add(drawCard());
      });
      await _saveGameState();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> hit() async {
    if (!gameOver && !_isLoading) {
      setState(() => _isLoading = true);
      try {
        setState(() {
          playerHand.add(drawCard());
          int playerValue = calculateHandValue(playerHand);
          
          if (playerValue > 21) {
            gameOver = true;
            message = AppLocalizations.of(context)!.bust;
          }
        });
        await _saveGameState();
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> stand() async {
    if (!gameOver && !_isLoading) {
      setState(() => _isLoading = true);
      try {
        // First, update the game state
        setState(() {
          while (calculateHandValue(dealerHand) < 17) {
            dealerHand.add(drawCard());
          }
          
          int playerValue = calculateHandValue(playerHand);
          int dealerValue = calculateHandValue(dealerHand);
          
          if (dealerValue > 21) {
            message = AppLocalizations.of(context)!.dealerBusts;
          } else if (dealerValue > playerValue) {
            message = AppLocalizations.of(context)!.dealerWins;
          } else if (dealerValue < playerValue) {
            message = AppLocalizations.of(context)!.youWin;
          } else {
            message = AppLocalizations.of(context)!.push;
          }
          
          gameOver = true;
        });

        // Save game state first
        await _saveGameState();

        // Then try to save game history
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentUser != null) {
          String result;
          if (message == AppLocalizations.of(context)!.dealerBusts ||
              message == AppLocalizations.of(context)!.youWin) {
            result = 'win';
          } else if (message == AppLocalizations.of(context)!.dealerWins ||
              message == AppLocalizations.of(context)!.bust) {
            result = 'lose';
          } else {
            result = 'tie';
          }

          final gameHistory = GameHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: authProvider.currentUser!.uid,
            timestamp: DateTime.now(),
            result: result,
            playerHand: List.from(playerHand),
            dealerHand: List.from(dealerHand),
            playerScore: calculateHandValue(playerHand),
            dealerScore: calculateHandValue(dealerHand),
          );

          // Save game history without waiting for completion
          GameHistoryService.saveGameHistory(gameHistory).catchError((error) {
            print('Error saving game history: $error');
          });
        }
      } catch (e) {
        print('Error in stand method: $e');
      } finally {
        // Always set loading to false, even if there's an error
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _syncGameState() async {
    setState(() => _isLoading = true);
    try {
      // Here you would implement the actual sync with Firebase
      // For now, we'll just clear the pending sync flag
      setState(() => _hasPendingSync = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (!isOnline)
            IconButton(
              icon: const Icon(Icons.cloud_off),
              onPressed: null,
              tooltip: 'Offline Mode',
            ),
          if (_hasPendingSync)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: isOnline ? _syncGameState : null,
              tooltip: 'Sync Game State',
            ),
        ],
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              
              return SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(isLandscape ? 24.0 : 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isOnline)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Playing in Offline Mode',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${l10n.dealerHand}: ${dealerHand.join(' ')}',
                                style: TextStyle(
                                  fontSize: isLandscape ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isLandscape ? 24 : 20),
                              Text(
                                '${l10n.yourHand}: ${playerHand.join(' ')}',
                                style: TextStyle(
                                  fontSize: isLandscape ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isLandscape ? 24 : 20),
                              Text(
                                '${l10n.yourValue}: ${calculateHandValue(playerHand)}',
                                style: TextStyle(
                                  fontSize: isLandscape ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isLandscape ? 32 : 24),
                        if (gameOver)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: isLandscape ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(height: isLandscape ? 32 : 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: (_isLoading || gameOver) ? null : hit,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 32 : 24,
                                  vertical: isLandscape ? 16 : 12,
                                ),
                              ),
                              child: Text(
                                l10n.hit,
                                style: TextStyle(fontSize: isLandscape ? 18 : 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: (_isLoading || gameOver) ? null : stand,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 32 : 24,
                                  vertical: isLandscape ? 16 : 12,
                                ),
                              ),
                              child: Text(
                                l10n.stand,
                                style: TextStyle(fontSize: isLandscape ? 18 : 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading ? null : startNewGame,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 32 : 24,
                                  vertical: isLandscape ? 16 : 12,
                                ),
                              ),
                              child: Text(
                                l10n.newGame,
                                style: TextStyle(fontSize: isLandscape ? 18 : 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
} 