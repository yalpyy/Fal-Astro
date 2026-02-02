import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading/mystic_loading_overlay.dart';

/// Zodiac signs with Turkish names
enum ZodiacSign {
  aries('Koç', '♈', [3, 21], [4, 19]),
  taurus('Boğa', '♉', [4, 20], [5, 20]),
  gemini('İkizler', '♊', [5, 21], [6, 20]),
  cancer('Yengeç', '♋', [6, 21], [7, 22]),
  leo('Aslan', '♌', [7, 23], [8, 22]),
  virgo('Başak', '♍', [8, 23], [9, 22]),
  libra('Terazi', '♎', [9, 23], [10, 22]),
  scorpio('Akrep', '♏', [10, 23], [11, 21]),
  sagittarius('Yay', '♐', [11, 22], [12, 21]),
  capricorn('Oğlak', '♑', [12, 22], [1, 19]),
  aquarius('Kova', '♒', [1, 20], [2, 18]),
  pisces('Balık', '♓', [2, 19], [3, 20]);

  final String turkishName;
  final String symbol;
  final List<int> startDate;
  final List<int> endDate;

  const ZodiacSign(this.turkishName, this.symbol, this.startDate, this.endDate);
}

/// Synastry (zodiac compatibility) screen
class SynastryScreen extends ConsumerStatefulWidget {
  const SynastryScreen({super.key});

  @override
  ConsumerState<SynastryScreen> createState() => _SynastryScreenState();
}

class _SynastryScreenState extends ConsumerState<SynastryScreen> {
  ZodiacSign? _sign1;
  ZodiacSign? _sign2;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _calculateCompatibility() async {
    if (_sign1 == null || _sign2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen her iki burcu da seçin')),
      );
      return;
    }

    setState(() {
      _error = null;
      _result = null;
    });

    Map<String, dynamic>? result;
    String? errorMessage;

    await showMysticLoading(
      context: context,
      title: 'Uyum Hesaplanıyor',
      type: MysticLoadingType.compatibility,
      minimumDuration: const Duration(seconds: 4),
      load: () async {
        try {
          final supabase = ref.read(safeSupabaseClientProvider);
          if (supabase == null) {
            throw Exception('Supabase bağlantısı yok');
          }
          final response = await supabase.functions.invoke(
            'synastry-calculate',
            body: {
              'sign1': _sign1!.name,
              'sign2': _sign2!.name,
              'locale': 'tr',
            },
          );

          if (response.status != 200) {
            throw Exception(response.data?['message'] ?? 'Bir hata oluştu');
          }

          result = response.data;
        } catch (e) {
          // Fallback to local calculation
          result = _calculateLocalCompatibility(_sign1!, _sign2!);
        }
      },
    );

    if (mounted) {
      setState(() {
        _result = result;
        _error = errorMessage;
      });
    }
  }

  /// Local compatibility calculation (fallback)
  Map<String, dynamic> _calculateLocalCompatibility(ZodiacSign sign1, ZodiacSign sign2) {
    // Element compatibility
    final elements = {
      'fire': [ZodiacSign.aries, ZodiacSign.leo, ZodiacSign.sagittarius],
      'earth': [ZodiacSign.taurus, ZodiacSign.virgo, ZodiacSign.capricorn],
      'air': [ZodiacSign.gemini, ZodiacSign.libra, ZodiacSign.aquarius],
      'water': [ZodiacSign.cancer, ZodiacSign.scorpio, ZodiacSign.pisces],
    };

    String? element1, element2;
    for (final entry in elements.entries) {
      if (entry.value.contains(sign1)) element1 = entry.key;
      if (entry.value.contains(sign2)) element2 = entry.key;
    }

    // Calculate base score
    int baseScore = 50;

    // Same element = +30
    if (element1 == element2) baseScore += 30;

    // Compatible elements
    final compatible = {
      'fire': 'air',
      'air': 'fire',
      'earth': 'water',
      'water': 'earth',
    };
    if (compatible[element1] == element2) baseScore += 20;

    // Same sign = special case
    if (sign1 == sign2) baseScore = 75;

    // Opposite signs (6 signs apart) = strong attraction
    final index1 = ZodiacSign.values.indexOf(sign1);
    final index2 = ZodiacSign.values.indexOf(sign2);
    if ((index1 - index2).abs() == 6) baseScore += 15;

    // Clamp score
    final score = baseScore.clamp(30, 95);

    return {
      'overall_score': score,
      'love_score': (score + (sign1 == sign2 ? -10 : 5)).clamp(20, 100),
      'friendship_score': (score + 10).clamp(30, 100),
      'communication_score': element1 == element2 ? score + 15 : score - 5,
      'trust_score': score,
      'sign1': {
        'name': sign1.turkishName,
        'symbol': sign1.symbol,
        'element': _getElementTurkish(element1!),
      },
      'sign2': {
        'name': sign2.turkishName,
        'symbol': sign2.symbol,
        'element': _getElementTurkish(element2!),
      },
      'summary': _generateSummary(sign1, sign2, score, element1, element2),
      'strengths': _generateStrengths(element1, element2),
      'challenges': _generateChallenges(element1, element2),
      'advice': _generateAdvice(sign1, sign2, score),
    };
  }

  String _getElementTurkish(String element) {
    switch (element) {
      case 'fire':
        return 'Ateş';
      case 'earth':
        return 'Toprak';
      case 'air':
        return 'Hava';
      case 'water':
        return 'Su';
      default:
        return element;
    }
  }

  String _generateSummary(ZodiacSign sign1, ZodiacSign sign2, int score, String e1, String e2) {
    if (score >= 80) {
      return '${sign1.turkishName} ve ${sign2.turkishName} arasında güçlü bir uyum var! '
          'Bu iki burç birbirini tamamlayan enerjilere sahip ve birlikte harika bir uyum yakalayabilirler.';
    } else if (score >= 60) {
      return '${sign1.turkishName} ile ${sign2.turkishName} arasında iyi bir potansiyel var. '
          'Bazı farklılıklar olsa da, anlayış ve sabırla güçlü bir bağ kurulabilir.';
    } else {
      return '${sign1.turkishName} ve ${sign2.turkishName} arasında zorlu ama öğretici bir dinamik var. '
          'Bu ilişki her iki taraf için de büyüme fırsatı sunuyor.';
    }
  }

  List<String> _generateStrengths(String e1, String e2) {
    if (e1 == e2) {
      return [
        'Ortak değerler ve bakış açısı',
        'Birbirini anlama kolaylığı',
        'Benzer enerji seviyeleri',
      ];
    }
    if ((e1 == 'fire' && e2 == 'air') || (e1 == 'air' && e2 == 'fire')) {
      return [
        'Yaratıcı ve dinamik enerji',
        'Birbirini ateşleyen tutku',
        'Özgürlüğe saygı',
      ];
    }
    if ((e1 == 'earth' && e2 == 'water') || (e1 == 'water' && e2 == 'earth')) {
      return [
        'Duygusal derinlik',
        'Karşılıklı destek',
        'Güvenli ve sağlam temel',
      ];
    }
    return [
      'Farklı bakış açıları',
      'Birbirini tamamlama potansiyeli',
      'Büyüme fırsatı',
    ];
  }

  List<String> _generateChallenges(String e1, String e2) {
    if ((e1 == 'fire' && e2 == 'water') || (e1 == 'water' && e2 == 'fire')) {
      return [
        'Duygusal çatışmalar',
        'Farklı iletişim stilleri',
        'Enerji uyumsuzluğu',
      ];
    }
    if ((e1 == 'earth' && e2 == 'air') || (e1 == 'air' && e2 == 'earth')) {
      return [
        'Pratik vs teorik yaklaşım',
        'Farklı öncelikler',
        'İletişim zorlukları',
      ];
    }
    return [
      'Orta noktada buluşma ihtiyacı',
      'Sabır gerektiren durumlar',
      'Esneklik ihtiyacı',
    ];
  }

  String _generateAdvice(ZodiacSign sign1, ZodiacSign sign2, int score) {
    if (score >= 80) {
      return 'Bu güzel uyumu korumak için birbirinize zaman ayırmaya devam edin ve '
          'ortak ilgi alanlarınızı keşfedin.';
    } else if (score >= 60) {
      return 'İletişimi açık tutun ve birbirinizin farklılıklarına saygı gösterin. '
          'Ortak paydalarınıza odaklanın.';
    } else {
      return 'Sabırlı olun ve birbirinizden öğrenmeye açık olun. '
          'Bu ilişki size çok şey öğretebilir.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Burç Uyumu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Burç Uyumu Analizi',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'İki burç arasındaki kozmik uyumu keşfet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sign selection
            if (_result == null) ...[
              Row(
                children: [
                  Expanded(
                    child: _ZodiacSelector(
                      label: 'Birinci Burç',
                      selectedSign: _sign1,
                      onChanged: (sign) => setState(() => _sign1 = sign),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.favorite,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  Expanded(
                    child: _ZodiacSelector(
                      label: 'İkinci Burç',
                      selectedSign: _sign2,
                      onChanged: (sign) => setState(() => _sign2 = sign),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calculate button
              FilledButton.icon(
                onPressed: (_sign1 != null && _sign2 != null) ? _calculateCompatibility : null,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Uyumu Hesapla'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 24),

              // Error
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
            ],

            // Result
            if (_result != null) ...[
              _CompatibilityResult(result: _result!),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _result = null;
                  _sign1 = null;
                  _sign2 = null;
                }),
                icon: const Icon(Icons.refresh),
                label: const Text('Yeni Analiz'),
              ),
            ],

            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Bu analiz eğlence amaçlıdır ve bilimsel değildir.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zodiac sign selector dropdown
class _ZodiacSelector extends StatelessWidget {
  final String label;
  final ZodiacSign? selectedSign;
  final ValueChanged<ZodiacSign?> onChanged;

  const _ZodiacSelector({
    required this.label,
    required this.selectedSign,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ZodiacSign>(
          value: selectedSign,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: const Text('Seç'),
          isExpanded: true,
          items: ZodiacSign.values.map((sign) {
            return DropdownMenuItem(
              value: sign,
              child: Row(
                children: [
                  Text(sign.symbol, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(sign.turkishName),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Compatibility result display
class _CompatibilityResult extends StatelessWidget {
  final Map<String, dynamic> result;

  const _CompatibilityResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final overallScore = result['overall_score'] as int? ?? 50;
    final sign1 = result['sign1'] as Map<String, dynamic>?;
    final sign2 = result['sign2'] as Map<String, dynamic>?;
    final strengths = (result['strengths'] as List?)?.cast<String>() ?? [];
    final challenges = (result['challenges'] as List?)?.cast<String>() ?? [];

    Color getScoreColor(int score) {
      if (score >= 80) return Colors.green;
      if (score >= 60) return Colors.orange;
      return Colors.red;
    }

    return Column(
      children: [
        // Main score card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          sign1?['symbol'] ?? '?',
                          style: const TextStyle(fontSize: 48),
                        ),
                        Text(sign1?['name'] ?? ''),
                        Text(
                          sign1?['element'] ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Icon(
                        Icons.favorite,
                        size: 32,
                        color: getScoreColor(overallScore),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          sign2?['symbol'] ?? '?',
                          style: const TextStyle(fontSize: 48),
                        ),
                        Text(sign2?['name'] ?? ''),
                        Text(
                          sign2?['element'] ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Score circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: overallScore / 100,
                        strokeWidth: 12,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: getScoreColor(overallScore),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '%$overallScore',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: getScoreColor(overallScore),
                              ),
                        ),
                        Text(
                          'Uyum',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Category scores
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detaylı Skorlar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _ScoreBar(label: 'Aşk', score: result['love_score'] ?? 50),
                _ScoreBar(label: 'Arkadaşlık', score: result['friendship_score'] ?? 50),
                _ScoreBar(label: 'İletişim', score: result['communication_score'] ?? 50),
                _ScoreBar(label: 'Güven', score: result['trust_score'] ?? 50),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Summary
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Yorum',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result['summary'] ?? '',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Strengths & Challenges
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.thumb_up, size: 18, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Güçlü Yanlar',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...strengths.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, size: 18, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Dikkat',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...challenges.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(c, style: const TextStyle(fontSize: 13))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Advice
        if (result['advice'] != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result['advice'],
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Score bar widget
class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreBar({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color getColor() {
      if (score >= 80) return Colors.green;
      if (score >= 60) return Colors.orange;
      return Colors.red.shade300;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '%$score',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: getColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: getColor(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
