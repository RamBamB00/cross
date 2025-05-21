import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/game_history.dart';
import '../services/game_history_service.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedResult;
  List<GameHistory> _games = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        final games = await GameHistoryService.searchGameHistory(
          authProvider.currentUser!.uid,
          searchQuery: _searchController.text,
          startDate: _startDate,
          endDate: _endDate,
          result: _selectedResult,
        );
        setState(() => _games = games);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadGames();
    }
  }

  void _showResultFilter() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.result),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.all),
              onTap: () {
                setState(() => _selectedResult = null);
                Navigator.pop(context);
                _loadGames();
              },
            ),
            ListTile(
              title: Text(l10n.win),
              onTap: () {
                setState(() => _selectedResult = 'win');
                Navigator.pop(context);
                _loadGames();
              },
            ),
            ListTile(
              title: Text(l10n.lose),
              onTap: () {
                setState(() => _selectedResult = 'lose');
                Navigator.pop(context);
                _loadGames();
              },
            ),
            ListTile(
              title: Text(l10n.tie),
              onTap: () {
                setState(() => _selectedResult = 'tie');
                Navigator.pop(context);
                _loadGames();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    if (authProvider.isGuestMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.gameHistory),
        ),
        body: Center(
          child: Text(l10n.pleaseSignIn),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gameHistory),
        actions: [
          if (!isOnline)
            IconButton(
              icon: const Icon(Icons.cloud_off),
              onPressed: null,
              tooltip: l10n.offlineMode,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchHistory,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadGames();
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => _loadGames(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(_startDate != null && _endDate != null
                            ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                            : l10n.dateRange),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _showResultFilter,
                      icon: const Icon(Icons.filter_list),
                      label: Text(_selectedResult?.toUpperCase() ?? l10n.result),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _games.isEmpty
                    ? Center(child: Text(l10n.noGamesFound))
                    : ListView.builder(
                        itemCount: _games.length,
                        itemBuilder: (context, index) {
                          final game = _games[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                '${l10n.gameOn} ${DateFormat('MMM d, y').format(game.timestamp)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${l10n.result}: ${game.result.toUpperCase()}'),
                                  Text('${l10n.playerScore}: ${game.playerScore} vs ${l10n.dealerScore}: ${game.dealerScore}'),
                                  Text('${l10n.yourHand}: ${game.playerHand.join(' ')}'),
                                  Text('${l10n.dealerHand}: ${game.dealerHand.join(' ')}'),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 