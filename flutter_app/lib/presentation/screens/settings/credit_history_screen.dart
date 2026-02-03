import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Credit transaction type
enum CreditTransactionType {
  purchase('Satın Alma', Icons.add_circle, Color(0xFF4ADE80)),
  fortuneReading('Fal Bakımı', Icons.coffee, Color(0xFFFF6B6B)),
  astroReport('Astro Rapor', Icons.stars, Color(0xFF9B59B6)),
  dreamInterpretation('Rüya Yorumu', Icons.nights_stay, Color(0xFF3498DB)),
  bonus('Bonus', Icons.card_giftcard, Color(0xFFFFD700)),
  refund('İade', Icons.replay, Color(0xFF4A9DFF));

  final String label;
  final IconData icon;
  final Color color;
  const CreditTransactionType(this.label, this.icon, this.color);
}

/// Credit transaction model
class CreditTransaction {
  final String id;
  final CreditTransactionType type;
  final int amount;
  final String description;
  final DateTime date;
  final bool isCredit; // true: earned, false: spent

  const CreditTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.isCredit,
  });
}

/// Mock credit transactions
final _mockTransactions = [
  CreditTransaction(
    id: '1',
    type: CreditTransactionType.purchase,
    amount: 100,
    description: '100 Kredi Paketi',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    isCredit: true,
  ),
  CreditTransaction(
    id: '2',
    type: CreditTransactionType.fortuneReading,
    amount: 10,
    description: 'Kahve Falı',
    date: DateTime.now().subtract(const Duration(hours: 5)),
    isCredit: false,
  ),
  CreditTransaction(
    id: '3',
    type: CreditTransactionType.bonus,
    amount: 5,
    description: 'Günlük Giriş Bonusu',
    date: DateTime.now().subtract(const Duration(days: 1)),
    isCredit: true,
  ),
  CreditTransaction(
    id: '4',
    type: CreditTransactionType.astroReport,
    amount: 15,
    description: 'Doğum Haritası Raporu',
    date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    isCredit: false,
  ),
  CreditTransaction(
    id: '5',
    type: CreditTransactionType.dreamInterpretation,
    amount: 8,
    description: 'Rüya Yorumu',
    date: DateTime.now().subtract(const Duration(days: 2)),
    isCredit: false,
  ),
  CreditTransaction(
    id: '6',
    type: CreditTransactionType.purchase,
    amount: 50,
    description: '50 Kredi Paketi',
    date: DateTime.now().subtract(const Duration(days: 3)),
    isCredit: true,
  ),
  CreditTransaction(
    id: '7',
    type: CreditTransactionType.fortuneReading,
    amount: 10,
    description: 'Kahve Falı',
    date: DateTime.now().subtract(const Duration(days: 4)),
    isCredit: false,
  ),
  CreditTransaction(
    id: '8',
    type: CreditTransactionType.refund,
    amount: 10,
    description: 'Hatalı İşlem İadesi',
    date: DateTime.now().subtract(const Duration(days: 5)),
    isCredit: true,
  ),
];

/// Credit history provider
final creditHistoryProvider = FutureProvider<List<CreditTransaction>>((ref) async {
  // In production, fetch from Supabase
  await Future.delayed(const Duration(milliseconds: 500));
  return _mockTransactions;
});

/// Current balance provider
final creditBalanceProvider = Provider<int>((ref) {
  // Calculate from transactions or fetch from Supabase
  return 122; // Mock balance
});

/// Credit history screen
class CreditHistoryScreen extends ConsumerWidget {
  const CreditHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(creditHistoryProvider);
    final balance = ref.watch(creditBalanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Kredi Geçmişi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Balance card
            _buildBalanceCard(balance),

            const SizedBox(height: 24),

            // Transactions title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'İşlem Geçmişi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Transactions list
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Hata: $e',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
                data: (transactions) => _buildTransactionsList(transactions),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(int balance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7C3AED),
              const Color(0xFF5B21B6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mevcut Bakiye',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$balance',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Kredi',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<CreditTransaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz işlem geçmişiniz yok',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Group transactions by date
    final grouped = <String, List<CreditTransaction>>{};
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

    for (final transaction in transactions) {
      final dateKey = dateFormat.format(transaction.date);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final dayTransactions = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _getRelativeDate(dateKey),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Transactions for this date
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: dayTransactions.map((transaction) {
                  final isLast = transaction == dayTransactions.last;
                  return _TransactionItem(
                    transaction: transaction,
                    showDivider: !isLast,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  String _getRelativeDate(String dateKey) {
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');
    final today = dateFormat.format(DateTime.now());
    final yesterday = dateFormat.format(DateTime.now().subtract(const Duration(days: 1)));

    if (dateKey == today) {
      return 'Bugün';
    } else if (dateKey == yesterday) {
      return 'Dün';
    }
    return dateKey;
  }
}

/// Transaction item widget
class _TransactionItem extends StatelessWidget {
  final CreditTransaction transaction;
  final bool showDivider;

  const _TransactionItem({
    required this.transaction,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: transaction.type.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.type.icon,
                  color: transaction.type.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.type.label} • ${timeFormat.format(transaction.date)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: transaction.isCredit
                      ? const Color(0xFF4ADE80).withOpacity(0.15)
                      : const Color(0xFFFF6B6B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${transaction.isCredit ? '+' : '-'}${transaction.amount}',
                  style: TextStyle(
                    color: transaction.isCredit
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFF6B6B),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 74,
            color: Colors.white.withOpacity(0.05),
          ),
      ],
    );
  }
}
