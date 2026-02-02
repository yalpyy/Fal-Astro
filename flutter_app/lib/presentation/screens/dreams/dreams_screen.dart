import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/auth_provider.dart';
import '../../widgets/loading/mystic_loading_overlay.dart';

/// Dream interpretation screen
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
            SnackBar(content: Text('Ses tanıma hatası: ${error.errorMsg}')),
          );
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ses tanıma bu cihazda kullanılamıyor')),
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
            // Append to existing text with space
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rüya Yorumu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rüyanı Anlat',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rüyanı detaylı bir şekilde yaz, mistik yorumunu alalım',
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

            // Dream input form
            if (_interpretation == null) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _dreamController,
                      maxLines: 6,
                      maxLength: 2000,
                      decoration: InputDecoration(
                        hintText: 'Rüyamda bir ormanda yürüyordum...',
                        labelText: 'Rüyanı yaz',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8, top: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _VoiceInputButton(
                                isListening: _isListening,
                                isAvailable: _speechAvailable,
                                onPressed: _toggleListening,
                              ),
                            ],
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 20) {
                          return 'Lütfen rüyanı en az 20 karakter ile anlat';
                        }
                        return null;
                      },
                    ),
                    if (_isListening)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mic, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dinleniyor... Rüyanızı anlatın',
                                style: TextStyle(color: colorScheme.onPrimaryContainer),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Error message
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _interpretDream,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Rüyamı Yorumla'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Nasıl Çalışır?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoItem(
                        icon: Icons.edit,
                        text: 'Rüyanı detaylı bir şekilde yaz',
                      ),
                      _InfoItem(
                        icon: Icons.psychology,
                        text: 'AI destekli analiz ile semboller çıkarılır',
                      ),
                      _InfoItem(
                        icon: Icons.lightbulb,
                        text: 'Kişisel yorum ve tavsiyeler alırsın',
                      ),
                      _InfoItem(
                        icon: Icons.star,
                        text: 'Şanslı sayılar ve ruh hali skoru',
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Interpretation result
            if (_interpretation != null) ...[
              _InterpretationCard(interpretation: _interpretation!),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _interpretation = null;
                    _dreamController.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Yeni Rüya Yorumlat'),
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
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bu yorum eğlence amaçlıdır ve profesyonel psikolojik tavsiye yerine geçmez.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _InterpretationCard extends StatelessWidget {
  final Map<String, dynamic> interpretation;

  const _InterpretationCard({required this.interpretation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final symbols = interpretation['symbols'] as List? ?? [];
    final emotions = interpretation['emotions'] as List? ?? [];
    final themes = interpretation['themes'] as List? ?? [];
    final luckyNumbers = interpretation['lucky_numbers'] as List? ?? [];
    final moodScore = interpretation['mood_score'] as int? ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main interpretation
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
                      'Rüya Yorumun',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  interpretation['interpretation'] ?? '',
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

        // Mood Score
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Ruh Hali Skoru',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(10, (index) {
                    return Icon(
                      index < moodScore ? Icons.star : Icons.star_border,
                      color: index < moodScore ? Colors.amber : Colors.grey,
                      size: 28,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  '$moodScore/10',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Symbols
        if (symbols.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_symbols, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Semboller',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...symbols.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s['symbol'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(s['meaning'] ?? ''),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Emotions & Themes
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duygular',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: emotions
                            .map((e) => Chip(
                                  label: Text(e.toString()),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
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
                      Text(
                        'Temalar',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: themes
                            .map((t) => Chip(
                                  label: Text(t.toString()),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lucky numbers & Advice
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.casino, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Şanslı Sayılar: ',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      luckyNumbers.join(', '),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                if (interpretation['advice'] != null) ...[
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          interpretation['advice'],
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Voice input button with animated feedback
class _VoiceInputButton extends StatelessWidget {
  final bool isListening;
  final bool isAvailable;
  final VoidCallback onPressed;

  const _VoiceInputButton({
    required this.isListening,
    required this.isAvailable,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isListening ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        boxShadow: isListening
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: isListening ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        ),
        onPressed: isAvailable ? onPressed : null,
        tooltip: isAvailable
            ? (isListening ? 'Kaydı durdur' : 'Sesle anlat')
            : 'Ses tanıma kullanılamıyor',
      ),
    );
  }
}
