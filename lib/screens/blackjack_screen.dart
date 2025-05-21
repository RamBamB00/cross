import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    initializeDeck();
    startNewGame();
  }

  void initializeDeck() {
    final List<String> suits = ['♠', '♥', '♦', '♣'];
    final List<String> values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    
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

  void startNewGame() {
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
  }

  void hit() {
    if (!gameOver) {
      setState(() {
        playerHand.add(drawCard());
        int playerValue = calculateHandValue(playerHand);
        
        if (playerValue > 21) {
          gameOver = true;
          message = AppLocalizations.of(context).bust;
        }
      });
    }
  }

  void stand() {
    if (!gameOver) {
      setState(() {
        while (calculateHandValue(dealerHand) < 17) {
          dealerHand.add(drawCard());
        }
        
        int playerValue = calculateHandValue(playerHand);
        int dealerValue = calculateHandValue(dealerHand);
        
        if (dealerValue > 21) {
          message = AppLocalizations.of(context).dealerBusts;
        } else if (dealerValue > playerValue) {
          message = AppLocalizations.of(context).dealerWins;
        } else if (dealerValue < playerValue) {
          message = AppLocalizations.of(context).youWin;
        } else {
          message = AppLocalizations.of(context).push;
        }
        
        gameOver = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(isLandscape ? 24.0 : 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          onPressed: gameOver ? null : hit,
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
                          onPressed: gameOver ? null : stand,
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
                          onPressed: startNewGame,
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
    );
  }
} 