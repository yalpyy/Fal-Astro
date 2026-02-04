import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/theme/premium_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading/mystic_loading_overlay.dart';

/// Premium dream interpretation screen
class DreamsScreen extends ConsumerStatefulWidget {
  const DreamsScreen({super.key});

  @override
  ConsumerState<DreamsScreen> createState() => _DreamsScreenState();
}

class _DreamsScreenState extends ConsumerState<DreamsScreen> {
  final _dreamController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _interpretation;
  String? _error;

  // Voice input
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ses tanıma hatası: ${error.errorMsg}'),
              backgroundColor: PremiumColors.error,
            ),
          );
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ses tanıma bu cihazda kullanılamıyor'),
          backgroundColor: PremiumColors.error,
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            final currentText = _dreamController.text;
            if (currentText.isNotEmpty && !currentText.endsWith(' ')) {
              _dreamController.text = '$currentText ${result.recognizedWords}';
            } else {
              _dreamController.text = currentText + result.recognizedWords;
            }
            _dreamController.selection = TextSelection.fromPosition(
              TextPosition(offset: _dreamController.text.length),
            );
          });
        },
        localeId: 'tr_TR',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _dreamController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _interpretDream() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _error = null;
      _interpretation = null;
    });

    Map<String, dynamic>? result;
    String? errorMessage;

    await showMysticLoading(
      context: context,
      title: 'Rüyan Yorumlanıyor',
      type: MysticLoadingType.dream,
      minimumDuration: const Duration(seconds: 5),
      load: () async {
        try {
          final supabase = ref.read(safeSupabaseClientProvider);
          if (supabase == null) {
            throw Exception('Supabase bağlantısı yok');
          }
          final response = await supabase.functions.invoke(
            'dream-interpret',
            body: {
              'dream_text': _dreamController.text.trim(),
              'locale': 'tr',
            },
          );

          if (response.status != 200) {
            throw Exception(response.data?['message'] ?? 'Bir hata oluştu');
          }

          result = response.data;
        } catch (e) {
          errorMessage = e.toString();
        }
      },
    );

    if (mounted) {
      setState(() {
        _interpretation = result;
        _error = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PremiumSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              _PremiumHeaderCard(),
              const SizedBox(height: PremiumSpacing.xl),

              // Dream input form or interpretation
              if (_interpretation == null) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _PremiumDreamInput(
                        controller: _dreamController,
                        isListening: _isListening,
                        speechAvailable: _speechAvailable,
                        onVoiceTap: _toggleListening,
                      ),
                      if (_isListening)
                        _ListeningIndicator(),
                      const SizedBox(height: PremiumSpacing.md),

                      // Error message
                      if (_error != null)
                        _ErrorCard(error: _error!),

                      // Submit button
                      _PremiumSubmitButton(
                        onPressed: _interpretDream,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: PremiumSpacing.xl),

                // How it works card
                _HowItWorksCard(),
              ],

              // Interpretation result
              if (_interpretation != null) ...[
                _PremiumInterpretationCard(interpretation: _interpretation!),
                const SizedBox(height: PremiumSpacing.lg),
                _NewDreamButton(
                  onPressed: () {
                    setState(() {
                      _interpretation = null;
                      _dreamController.clear();
                    });
                  },
                ),
              ],

              const SizedBox(height: PremiumSpacing.xl),

              // Disclaimer
              _PremiumDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium header card
class _PremiumHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF312E81).withOpacity(0.6),
            const Color(0xFF1E1B4B).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PremiumSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(PremiumRadius.lg),
            ),
            child: const Text('🌙', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(width: PremiumSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rüya Yorumu',
                  style: TextStyle(
                    color: PremiumColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: PremiumSpacing.xs),
                Text(
                  MysticalStrings.dreamHint,
                  style: TextStyle(
                    color: PremiumColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium dream input field
class _PremiumDreamInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool speechAvailable;
  final VoidCallback onVoiceTap;

  const _PremiumDreamInput({
    required this.controller,
    required this.isListening,
    required this.speechAvailable,
    required this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(color: PremiumColors.borderSubtle),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            maxLines: 6,
            maxLength: 2000,
            style: const TextStyle(
              color: PremiumColors.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Rüyamda bir ormanda yürüyordum...',
              hintStyle: TextStyle(color: PremiumColors.textTertiary),
              labelText: 'Rüyanı anlat',
              labelStyle: TextStyle(color: PremiumColors.textSecondary),
              alignLabelWithHint: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(PremiumSpacing.lg),
              counterStyle: TextStyle(color: PremiumColors.textTertiary),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 20) {
                return 'Lütfen rüyanı en az 20 karakter ile anlat';
              }
              return null;
            },
          ),
          // Voice button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumSpacing.md,
              vertical: PremiumSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: PremiumColors.borderSubtle),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Sesle anlat',
                  style: TextStyle(
                    color: PremiumColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: PremiumSpacing.sm),
                GestureDetector(
                  onTap: speechAvailable ? onVoiceTap : null,
                  child: Container(
                    padding: const EdgeInsets.all(PremiumSpacing.sm),
                    decoration: BoxDecoration(
                      color: isListening
                          ? PremiumColors.primaryPurple
                          : PremiumColors.surfaceLight,
                      shape: BoxShape.circle,
                      boxShadow: isListening
                          ? [
                              BoxShadow(
                                color: PremiumColors.primaryPurple.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening
                          ? Colors.white
                          : PremiumColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Listening indicator
class _ListeningIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.md),
      margin: const EdgeInsets.only(top: PremiumSpacing.md),
      decoration: BoxDecoration(
        color: PremiumColors.primaryPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(PremiumRadius.lg),
        border: Border.all(
          color: PremiumColors.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('🎙️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: PremiumSpacing.sm),
          Expanded(
            child: Text(
              'Dinleniyor... Rüyanızı anlatın',
              style: TextStyle(color: PremiumColors.textSecondary),
            ),
          ),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: PremiumColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error card
class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.md),
      margin: const EdgeInsets.only(bottom: PremiumSpacing.lg),
      decoration: BoxDecoration(
        color: PremiumColors.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(PremiumRadius.lg),
        border: Border.all(color: PremiumColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: PremiumColors.error),
          const SizedBox(width: PremiumSpacing.sm),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: PremiumColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium submit button
class _PremiumSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PremiumSubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PremiumSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1),
              PremiumColors.primaryPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.lg),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨', style: TextStyle(fontSize: 20)),
            const SizedBox(width: PremiumSpacing.sm),
            const Text(
              'Rüyamı Yorumla',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How it works card
class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.lg),
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(color: PremiumColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: PremiumSpacing.sm),
              const Text(
                'Nasıl Çalışır?',
                style: TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumSpacing.lg),
          _InfoItem(icon: '✏️', text: 'Rüyanı detaylı bir şekilde yaz'),
          _InfoItem(icon: '🧠', text: 'AI destekli analiz ile semboller çıkarılır'),
          _InfoItem(icon: '💡', text: 'Kişisel yorum ve tavsiyeler alırsın'),
          _InfoItem(icon: '🎲', text: 'Şanslı sayılar ve ruh hali skoru'),
        ],
      ),
    );
  }
}

/// Info item
class _InfoItem extends StatelessWidget {
  final String icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PremiumSpacing.xs),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: PremiumSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium interpretation card
class _PremiumInterpretationCard extends StatelessWidget {
  final Map<String, dynamic> interpretation;

  const _PremiumInterpretationCard({required this.interpretation});

  @override
  Widget build(BuildContext context) {
    final symbols = interpretation['symbols'] as List? ?? [];
    final emotions = interpretation['emotions'] as List? ?? [];
    final themes = interpretation['themes'] as List? ?? [];
    final luckyNumbers = interpretation['lucky_numbers'] as List? ?? [];
    final moodScore = interpretation['mood_score'] as int? ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main interpretation
        Container(
          padding: const EdgeInsets.all(PremiumSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF312E81).withOpacity(0.5),
                const Color(0xFF1E1B4B).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(PremiumRadius.xl),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: PremiumSpacing.sm),
                  const Text(
                    'Rüya Yorumun',
                    style: TextStyle(
                      color: PremiumColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PremiumSpacing.lg),
              Text(
                interpretation['interpretation'] ?? '',
                style: TextStyle(
                  color: PremiumColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PremiumSpacing.lg),

        // Mood Score
        Container(
          padding: const EdgeInsets.all(PremiumSpacing.lg),
          decoration: BoxDecoration(
            color: PremiumColors.cardBackground,
            borderRadius: BorderRadius.circular(PremiumRadius.xl),
            border: Border.all(color: PremiumColors.borderSubtle),
          ),
          child: Column(
            children: [
              const Text(
                'Ruh Hali Skoru',
                style: TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: PremiumSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(10, (index) {
                  return Text(
                    index < moodScore ? '⭐' : '☆',
                    style: TextStyle(
                      fontSize: 24,
                      color: index < moodScore
                          ? PremiumColors.premiumGold
                          : PremiumColors.textTertiary,
                    ),
                  );
                }),
              ),
              const SizedBox(height: PremiumSpacing.sm),
              Text(
                '$moodScore/10',
                style: TextStyle(
                  color: PremiumColors.premiumGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PremiumSpacing.lg),

        // Symbols
        if (symbols.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(PremiumSpacing.lg),
            decoration: BoxDecoration(
              color: PremiumColors.cardBackground,
              borderRadius: BorderRadius.circular(PremiumRadius.xl),
              border: Border.all(color: PremiumColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: PremiumSpacing.sm),
                    const Text(
                      'Semboller',
                      style: TextStyle(
                        color: PremiumColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PremiumSpacing.lg),
                ...symbols.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: PremiumSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PremiumSpacing.md,
                              vertical: PremiumSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: PremiumColors.primaryPurple.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(PremiumRadius.md),
                            ),
                            child: Text(
                              s['symbol'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: PremiumColors.primaryPurple,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: PremiumSpacing.md),
                          Expanded(
                            child: Text(
                              s['meaning'] ?? '',
                              style: TextStyle(
                                color: PremiumColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        const SizedBox(height: PremiumSpacing.lg),

        // Emotions & Themes
        Row(
          children: [
            Expanded(
              child: _ChipSection(
                title: 'Duygular',
                icon: '💭',
                items: emotions.map((e) => e.toString()).toList(),
              ),
            ),
            const SizedBox(width: PremiumSpacing.md),
            Expanded(
              child: _ChipSection(
                title: 'Temalar',
                icon: '🎭',
                items: themes.map((t) => t.toString()).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: PremiumSpacing.lg),

        // Lucky numbers & Advice
        Container(
          padding: const EdgeInsets.all(PremiumSpacing.lg),
          decoration: BoxDecoration(
            color: PremiumColors.cardBackground,
            borderRadius: BorderRadius.circular(PremiumRadius.xl),
            border: Border.all(color: PremiumColors.borderSubtle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎲', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: PremiumSpacing.sm),
                  const Text(
                    'Şanslı Sayılar: ',
                    style: TextStyle(
                      color: PremiumColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    luckyNumbers.join(', '),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PremiumColors.accentCyan,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (interpretation['advice'] != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: PremiumSpacing.lg),
                  child: Container(
                    height: 1,
                    color: PremiumColors.borderSubtle,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: PremiumSpacing.sm),
                    Expanded(
                      child: Text(
                        interpretation['advice'],
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: PremiumColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Chip section widget
class _ChipSection extends StatelessWidget {
  final String title;
  final String icon;
  final List<String> items;

  const _ChipSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.md),
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(color: PremiumColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: PremiumSpacing.xs),
              Text(
                title,
                style: const TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PremiumSpacing.sm),
          Wrap(
            spacing: PremiumSpacing.xs,
            runSpacing: PremiumSpacing.xs,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PremiumSpacing.sm,
                        vertical: PremiumSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: PremiumColors.surfaceLight,
                        borderRadius: BorderRadius.circular(PremiumRadius.sm),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: PremiumColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// New dream button
class _NewDreamButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewDreamButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.md),
        decoration: BoxDecoration(
          color: PremiumColors.surfaceLight,
          borderRadius: BorderRadius.circular(PremiumRadius.lg),
          border: Border.all(color: PremiumColors.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: PremiumColors.textSecondary, size: 20),
            const SizedBox(width: PremiumSpacing.sm),
            Text(
              'Yeni Rüya Yorumlat',
              style: TextStyle(
                color: PremiumColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium disclaimer
class _PremiumDisclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PremiumColors.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(PremiumRadius.md),
        border: Border.all(color: PremiumColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 14)),
          const SizedBox(width: PremiumSpacing.sm),
          Expanded(
            child: Text(
              'Bu yorum eğlence amaçlıdır ve profesyonel psikolojik tavsiye yerine geçmez.',
              style: TextStyle(
                color: PremiumColors.textTertiary,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
