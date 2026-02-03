import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/fortune_reading.dart';
import '../../../data/services/notification_service.dart';
import '../../providers/fortune_provider.dart';
import '../../router/route_names.dart';

/// Fortune upload screen with vertical stepper
class FortuneUploadScreen extends ConsumerStatefulWidget {
  const FortuneUploadScreen({super.key});

  @override
  ConsumerState<FortuneUploadScreen> createState() => _FortuneUploadScreenState();
}

class _FortuneUploadScreenState extends ConsumerState<FortuneUploadScreen> {
  int _currentStep = 0;

  // Step 1: Photos
  XFile? _cupImage1;
  XFile? _cupImage2;
  XFile? _saucerImage;
  Uint8List? _cupImage1Bytes;
  Uint8List? _cupImage2Bytes;
  Uint8List? _saucerImageBytes;

  // Step 2: Intent
  FortuneIntent _intent = FortuneIntent.general;

  // Step 3: Submission
  bool _isSubmitting = false;
  String? _submittedReadingId;

  Future<void> _pickImage(int imageIndex) async {
    if (kIsWeb) {
      await _pickFromGallery(imageIndex);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera(imageIndex);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(imageIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera(int imageIndex) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      _setImage(imageIndex, picked, bytes);
    }
  }

  Future<void> _pickFromGallery(int imageIndex) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      _setImage(imageIndex, picked, bytes);
    }
  }

  void _setImage(int imageIndex, XFile file, Uint8List bytes) {
    setState(() {
      switch (imageIndex) {
        case 0:
          _cupImage1 = file;
          _cupImage1Bytes = bytes;
          break;
        case 1:
          _cupImage2 = file;
          _cupImage2Bytes = bytes;
          break;
        case 2:
          _saucerImage = file;
          _saucerImageBytes = bytes;
          break;
      }
    });
  }

  void _removeImage(int imageIndex) {
    setState(() {
      switch (imageIndex) {
        case 0:
          _cupImage1 = null;
          _cupImage1Bytes = null;
          break;
        case 1:
          _cupImage2 = null;
          _cupImage2Bytes = null;
          break;
        case 2:
          _saucerImage = null;
          _saucerImageBytes = null;
          break;
      }
    });
  }

  bool get _canProceedFromStep1 => _cupImage1 != null && _cupImage2 != null;
  bool get _canProceedFromStep2 => true; // Intent always has a default

  void _onStepContinue() {
    if (_currentStep == 0 && !_canProceedFromStep1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen 2 adet fincan fotoğrafı ekleyin')),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _onStepTapped(int step) {
    if (step < _currentStep) {
      setState(() => _currentStep = step);
    } else if (step == 1 && _canProceedFromStep1) {
      setState(() => _currentStep = step);
    } else if (step == 2 && _canProceedFromStep1 && _canProceedFromStep2) {
      setState(() => _currentStep = step);
    }
  }

  Future<void> _submit() async {
    if (_cupImage1 == null || _cupImage2 == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Create the fortune reading
      await ref.read(createFortuneProvider.notifier).createFortune(
            intent: _intent,
            cupImage: _cupImage1!,
            saucerImage: _saucerImage,
          );

      final state = ref.read(createFortuneProvider);
      if (state.result != null && mounted) {
        _submittedReadingId = state.result!.id;

        // Schedule a notification for when fortune is ready
        await NotificationService().scheduleFortuneReadyNotification(
          readingId: _submittedReadingId!,
          delayMinutes: 5,
        );
      } else if (state.error != null && mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _navigateToResult() {
    if (_submittedReadingId != null && mounted) {
      context.goNamed(
        RouteNames.fortuneResult,
        pathParameters: {'id': _submittedReadingId!},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return _FortuneLoadingScreen(
        onComplete: _navigateToResult,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fal Baktır'),
        elevation: 0,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: _onStepTapped,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(_currentStep == 2 ? 'Gönder' : 'Devam'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Geri'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Step 1: Photos
          Step(
            title: const Text('Fotoğraflar'),
            subtitle: Text(_canProceedFromStep1
                ? 'Fotoğraflar hazır'
                : '2 fincan + 1 tabak (opsiyonel)'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _PhotosStep(
              cupImage1Bytes: _cupImage1Bytes,
              cupImage2Bytes: _cupImage2Bytes,
              saucerImageBytes: _saucerImageBytes,
              onPickImage: _pickImage,
              onRemoveImage: _removeImage,
            ),
          ),

          // Step 2: Intent
          Step(
            title: const Text('Niyet'),
            subtitle: Text(_intentLabel(_intent)),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _IntentStep(
              selectedIntent: _intent,
              onIntentSelected: (intent) => setState(() => _intent = intent),
            ),
          ),

          // Step 3: Submit
          Step(
            title: const Text('Gönderim'),
            subtitle: const Text('Falınızı gönderin'),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content: _SubmitStep(
              intent: _intent,
              hasAllPhotos: _canProceedFromStep1,
            ),
          ),
        ],
      ),
    );
  }

  String _intentLabel(FortuneIntent intent) {
    switch (intent) {
      case FortuneIntent.love:
        return 'Aşk';
      case FortuneIntent.money:
        return 'Para';
      case FortuneIntent.career:
        return 'Kariyer';
      case FortuneIntent.general:
        return 'Genel';
    }
  }
}

/// Step 1: Photos
class _PhotosStep extends StatelessWidget {
  final Uint8List? cupImage1Bytes;
  final Uint8List? cupImage2Bytes;
  final Uint8List? saucerImageBytes;
  final Function(int) onPickImage;
  final Function(int) onRemoveImage;

  const _PhotosStep({
    this.cupImage1Bytes,
    this.cupImage2Bytes,
    this.saucerImageBytes,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fincan Fotoğrafları *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fincanınızın iki farklı açıdan fotoğrafını çekin',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _PhotoBox(
              imageBytes: cupImage1Bytes,
              label: 'Fincan 1',
              icon: Icons.coffee,
              isRequired: true,
              onTap: () => onPickImage(0),
              onRemove: () => onRemoveImage(0),
            ),
            const SizedBox(width: 12),
            _PhotoBox(
              imageBytes: cupImage2Bytes,
              label: 'Fincan 2',
              icon: Icons.coffee,
              isRequired: true,
              onTap: () => onPickImage(1),
              onRemove: () => onRemoveImage(1),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Tabak Fotoğrafı (Opsiyonel)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Daha detaylı yorum için tabak fotoğrafı ekleyebilirsiniz',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 12),
        _PhotoBox(
          imageBytes: saucerImageBytes,
          label: 'Tabak',
          icon: Icons.panorama_fish_eye,
          isRequired: false,
          onTap: () => onPickImage(2),
          onRemove: () => onRemoveImage(2),
        ),
      ],
    );
  }
}

/// Photo box widget - 100x100 square
class _PhotoBox extends StatelessWidget {
  final Uint8List? imageBytes;
  final String label;
  final IconData icon;
  final bool isRequired;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PhotoBox({
    this.imageBytes,
    required this.label,
    required this.icon,
    required this.isRequired,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRequired && imageBytes == null
                    ? colorScheme.error.withOpacity(0.5)
                    : colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      imageBytes!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                : InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 28,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.outline,
                          ),
                        ),
                        if (isRequired)
                          Text(
                            '*',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          // Delete button
          if (imageBytes != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Step 2: Intent selection
class _IntentStep extends StatelessWidget {
  final FortuneIntent selectedIntent;
  final Function(FortuneIntent) onIntentSelected;

  const _IntentStep({
    required this.selectedIntent,
    required this.onIntentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Falınızın odak noktasını seçin',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _IntentCard(
              intent: FortuneIntent.love,
              icon: Icons.favorite,
              label: 'Aşk',
              color: const Color(0xFFE91E63),
              isSelected: selectedIntent == FortuneIntent.love,
              onTap: () => onIntentSelected(FortuneIntent.love),
            ),
            _IntentCard(
              intent: FortuneIntent.money,
              icon: Icons.attach_money,
              label: 'Para',
              color: const Color(0xFF4CAF50),
              isSelected: selectedIntent == FortuneIntent.money,
              onTap: () => onIntentSelected(FortuneIntent.money),
            ),
            _IntentCard(
              intent: FortuneIntent.career,
              icon: Icons.work,
              label: 'Kariyer',
              color: const Color(0xFF2196F3),
              isSelected: selectedIntent == FortuneIntent.career,
              onTap: () => onIntentSelected(FortuneIntent.career),
            ),
            _IntentCard(
              intent: FortuneIntent.general,
              icon: Icons.auto_awesome,
              label: 'Genel',
              color: const Color(0xFF9C27B0),
              isSelected: selectedIntent == FortuneIntent.general,
              onTap: () => onIntentSelected(FortuneIntent.general),
            ),
          ],
        ),
      ],
    );
  }
}

/// Intent card widget with modern rounded design
class _IntentCard extends StatelessWidget {
  final FortuneIntent intent;
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntentCard({
    required this.intent,
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 3: Submit confirmation
class _SubmitStep extends StatelessWidget {
  final FortuneIntent intent;
  final bool hasAllPhotos;

  const _SubmitStep({
    required this.intent,
    required this.hasAllPhotos,
  });

  String _intentLabel(FortuneIntent intent) {
    switch (intent) {
      case FortuneIntent.love:
        return 'Aşk';
      case FortuneIntent.money:
        return 'Para';
      case FortuneIntent.career:
        return 'Kariyer';
      case FortuneIntent.general:
        return 'Genel';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fotoğraflar hazır',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Niyet: ${_intentLabel(intent)}',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Falınız 5-10 dakika içinde hazır olacak. Hazır olduğunda size bildirim göndereceğiz.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Disclaimer
        Text(
          'Bu yorum eğlence amaçlıdır ve profesyonel tavsiye yerine geçmez.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}

/// Fortune loading screen with GIF
class _FortuneLoadingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const _FortuneLoadingScreen({required this.onComplete});

  @override
  State<_FortuneLoadingScreen> createState() => _FortuneLoadingScreenState();
}

class _FortuneLoadingScreenState extends State<_FortuneLoadingScreen> {
  double _progress = 0.0;
  String _statusText = 'Falınız hazırlanıyor...';
  final List<String> _statusMessages = [
    'Falınız hazırlanıyor...',
    'Fincan şekilleri inceleniyor...',
    'Semboller yorumlanıyor...',
    'Falınız neredeyse hazır...',
    'Son dokunuşlar yapılıyor...',
  ];

  @override
  void initState() {
    super.initState();
    _startLoadingAnimation();
  }

  void _startLoadingAnimation() async {
    // Simulate 45 seconds loading (as per app_config artificial_delay_seconds)
    const totalDuration = Duration(seconds: 45);
    const updateInterval = Duration(milliseconds: 500);
    final totalUpdates = totalDuration.inMilliseconds ~/ updateInterval.inMilliseconds;

    for (int i = 0; i <= totalUpdates; i++) {
      if (!mounted) return;

      await Future.delayed(updateInterval);

      if (!mounted) return;

      setState(() {
        _progress = i / totalUpdates;

        // Update status text at certain points
        final messageIndex = (i / totalUpdates * _statusMessages.length).floor();
        if (messageIndex < _statusMessages.length) {
          _statusText = _statusMessages[messageIndex];
        }
      });
    }

    // Navigate to result
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GIF Animation
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/videos/Creating_Fal.gif',
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if GIF not found
                      return Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.coffee,
                          size: 80,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Status text
                const Text(
                  'Falınız Bakılıyor...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // Progress bar
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Percentage
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Falınız hazır olduğunda\nbildirim alacaksınız',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
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
