import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../router/route_names.dart';

/// Zodiac sign data
class ZodiacSign {
  final String id;
  final String name;
  final String symbol;
  final String dateRange;
  final String element;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  const ZodiacSign({
    required this.id,
    required this.name,
    required this.symbol,
    required this.dateRange,
    required this.element,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
  });
}

/// All zodiac signs
const List<ZodiacSign> zodiacSigns = [
  ZodiacSign(
    id: 'aries',
    name: 'Koç',
    symbol: '♈',
    dateRange: '21 Mar - 19 Nis',
    element: 'Ateş',
    primaryColor: Color(0xFFE53935),
    secondaryColor: Color(0xFFFF8A65),
    icon: Icons.local_fire_department,
  ),
  ZodiacSign(
    id: 'taurus',
    name: 'Boğa',
    symbol: '♉',
    dateRange: '20 Nis - 20 May',
    element: 'Toprak',
    primaryColor: Color(0xFF43A047),
    secondaryColor: Color(0xFF81C784),
    icon: Icons.grass,
  ),
  ZodiacSign(
    id: 'gemini',
    name: 'İkizler',
    symbol: '♊',
    dateRange: '21 May - 20 Haz',
    element: 'Hava',
    primaryColor: Color(0xFFFFB300),
    secondaryColor: Color(0xFFFFD54F),
    icon: Icons.air,
  ),
  ZodiacSign(
    id: 'cancer',
    name: 'Yengeç',
    symbol: '♋',
    dateRange: '21 Haz - 22 Tem',
    element: 'Su',
    primaryColor: Color(0xFF5C6BC0),
    secondaryColor: Color(0xFF9FA8DA),
    icon: Icons.water_drop,
  ),
  ZodiacSign(
    id: 'leo',
    name: 'Aslan',
    symbol: '♌',
    dateRange: '23 Tem - 22 Ağu',
    element: 'Ateş',
    primaryColor: Color(0xFFFF7043),
    secondaryColor: Color(0xFFFFAB91),
    icon: Icons.wb_sunny,
  ),
  ZodiacSign(
    id: 'virgo',
    name: 'Başak',
    symbol: '♍',
    dateRange: '23 Ağu - 22 Eyl',
    element: 'Toprak',
    primaryColor: Color(0xFF8D6E63),
    secondaryColor: Color(0xFFBCAAA4),
    icon: Icons.eco,
  ),
  ZodiacSign(
    id: 'libra',
    name: 'Terazi',
    symbol: '♎',
    dateRange: '23 Eyl - 22 Eki',
    element: 'Hava',
    primaryColor: Color(0xFFEC407A),
    secondaryColor: Color(0xFFF48FB1),
    icon: Icons.balance,
  ),
  ZodiacSign(
    id: 'scorpio',
    name: 'Akrep',
    symbol: '♏',
    dateRange: '23 Eki - 21 Kas',
    element: 'Su',
    primaryColor: Color(0xFF7B1FA2),
    secondaryColor: Color(0xFFBA68C8),
    icon: Icons.pest_control,
  ),
  ZodiacSign(
    id: 'sagittarius',
    name: 'Yay',
    symbol: '♐',
    dateRange: '22 Kas - 21 Ara',
    element: 'Ateş',
    primaryColor: Color(0xFF9C27B0),
    secondaryColor: Color(0xFFCE93D8),
    icon: Icons.architecture,
  ),
  ZodiacSign(
    id: 'capricorn',
    name: 'Oğlak',
    symbol: '♑',
    dateRange: '22 Ara - 19 Oca',
    element: 'Toprak',
    primaryColor: Color(0xFF455A64),
    secondaryColor: Color(0xFF90A4AE),
    icon: Icons.landscape,
  ),
  ZodiacSign(
    id: 'aquarius',
    name: 'Kova',
    symbol: '♒',
    dateRange: '20 Oca - 18 Şub',
    element: 'Hava',
    primaryColor: Color(0xFF00ACC1),
    secondaryColor: Color(0xFF4DD0E1),
    icon: Icons.waves,
  ),
  ZodiacSign(
    id: 'pisces',
    name: 'Balık',
    symbol: '♓',
    dateRange: '19 Şub - 20 Mar',
    element: 'Su',
    primaryColor: Color(0xFF26A69A),
    secondaryColor: Color(0xFF80CBC4),
    icon: Icons.water,
  ),
];

/// Provider for pinned zodiac sign
final pinnedZodiacProvider = StateNotifierProvider<PinnedZodiacNotifier, String?>((ref) {
  return PinnedZodiacNotifier();
});

class PinnedZodiacNotifier extends StateNotifier<String?> {
  PinnedZodiacNotifier() : super(null) {
    _loadPinnedZodiac();
  }

  Future<void> _loadPinnedZodiac() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('pinned_zodiac');
  }

  Future<void> setPinnedZodiac(String? zodiacId) async {
    final prefs = await SharedPreferences.getInstance();
    if (zodiacId != null) {
      await prefs.setString('pinned_zodiac', zodiacId);
    } else {
      await prefs.remove('pinned_zodiac');
    }
    state = zodiacId;
  }
}

/// Daily horoscope screen with zodiac grid
class DailyHoroscopeScreen extends ConsumerWidget {
  const DailyHoroscopeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedZodiac = ref.watch(pinnedZodiacProvider);

    // Sort zodiac signs with pinned one first
    final sortedSigns = List<ZodiacSign>.from(zodiacSigns);
    if (pinnedZodiac != null) {
      final pinnedIndex = sortedSigns.indexWhere((z) => z.id == pinnedZodiac);
      if (pinnedIndex != -1) {
        final pinned = sortedSigns.removeAt(pinnedIndex);
        sortedSigns.insert(0, pinned);
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Günlük Burçlar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Date header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _DateHeader(),
            ),
          ),

          // Zodiac grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final zodiac = sortedSigns[index];
                  final isPinned = zodiac.id == pinnedZodiac;
                  return _ZodiacCard(
                    zodiac: zodiac,
                    isPinned: isPinned,
                    onTap: () {
                      context.pushNamed(
                        RouteNames.zodiacDetail,
                        pathParameters: {'id': zodiac.id},
                      );
                    },
                    onLongPress: () {
                      _showPinDialog(context, ref, zodiac, isPinned);
                    },
                  );
                },
                childCount: sortedSigns.length,
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context, WidgetRef ref, ZodiacSign zodiac, bool isPinned) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: isPinned ? Colors.red : null,
              ),
              title: Text(isPinned ? 'Sabitlemeyi Kaldır' : 'Burcu Sabitle'),
              subtitle: Text(isPinned
                  ? '${zodiac.name} artık en başta görünmeyecek'
                  : '${zodiac.name} her zaman listenin başında görünecek'),
              onTap: () {
                ref.read(pinnedZodiacProvider.notifier).setPinnedZodiac(
                      isPinned ? null : zodiac.id,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isPinned
                        ? '${zodiac.name} sabitlemesi kaldırıldı'
                        : '${zodiac.name} sabitlendi'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Date header widget
class _DateHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final monthNames = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${now.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayNames[now.weekday - 1],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${monthNames[now.month - 1]} ${now.year}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.calendar_today_outlined),
        ],
      ),
    );
  }
}

/// Zodiac card with liquid glass effect
class _ZodiacCard extends StatelessWidget {
  final ZodiacSign zodiac;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ZodiacCard({
    required this.zodiac,
    required this.isPinned,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Hero(
        tag: 'zodiac_${zodiac.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  zodiac.primaryColor.withOpacity(0.8),
                  zodiac.secondaryColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: zodiac.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Glass effect overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Symbol
                      Text(
                        zodiac.symbol,
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Name
                      Text(
                        zodiac.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Date range
                      Text(
                        zodiac.dateRange,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pin indicator
                if (isPinned)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.push_pin,
                        size: 12,
                        color: zodiac.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
