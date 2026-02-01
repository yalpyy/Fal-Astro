import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/fortune_reading.dart';
import '../../providers/fortune_provider.dart';
import '../../router/route_names.dart';
import '../../widgets/common/loading_overlay.dart';

/// Fortune upload screen
class FortuneUploadScreen extends ConsumerStatefulWidget {
  const FortuneUploadScreen({super.key});

  @override
  ConsumerState<FortuneUploadScreen> createState() => _FortuneUploadScreenState();
}

class _FortuneUploadScreenState extends ConsumerState<FortuneUploadScreen> {
  XFile? _cupImage;
  XFile? _saucerImage;
  FortuneIntent _intent = FortuneIntent.general;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCup) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        if (isCup) {
          _cupImage = picked;
        } else {
          _saucerImage = picked;
        }
      });
    }
  }

  Future<void> _pickFromGallery(bool isCup) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        if (isCup) {
          _cupImage = File(picked.path);
        } else {
          _saucerImage = File(picked.path);
        }
      });
    }
  }

  void _showImageSourceDialog(bool isCup) {
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
                _pickImage(isCup);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(isCup);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_cupImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fincan fotoğrafı ekleyin')),
      );
      return;
    }

    await ref.read(createFortuneProvider.notifier).createFortune(
          intent: _intent,
          cupImage: _cupImage!,
          saucerImage: _saucerImage,
          customNote: _noteController.text.isNotEmpty ? _noteController.text : null,
        );

    final state = ref.read(createFortuneProvider);
    if (state.result != null && mounted) {
      context.goNamed(
        RouteNames.fortuneResult,
        pathParameters: {'id': state.result!.id},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createFortuneProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fal Baktır'),
      ),
      body: LoadingOverlay(
        isLoading: createState.isLoading,
        message: 'Falınız yorumlanıyor...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error
              if (createState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    createState.error!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),

              // Cup image
              Text(
                'Fincan Fotoğrafı *',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _ImagePickerCard(
                image: _cupImage,
                placeholder: Icons.coffee,
                onTap: () => _showImageSourceDialog(true),
                onRemove: () => setState(() => _cupImage = null),
              ),
              const SizedBox(height: 24),

              // Saucer image (optional)
              Text(
                'Tabak Fotoğrafı (opsiyonel)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _ImagePickerCard(
                image: _saucerImage,
                placeholder: Icons.circle_outlined,
                onTap: () => _showImageSourceDialog(false),
                onRemove: () => setState(() => _saucerImage = null),
              ),
              const SizedBox(height: 24),

              // Intent selection
              Text(
                'Niyet Seçin',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: FortuneIntent.values.map((intent) {
                  final isSelected = _intent == intent;
                  return ChoiceChip(
                    label: Text(_intentLabel(intent)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _intent = intent);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Note (optional)
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Not (opsiyonel)',
                  hintText: 'Aklınızdaki soruyu yazabilirsiniz...',
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 24),

              // Submit
              ElevatedButton(
                onPressed: _cupImage != null ? _submit : null,
                child: const Text('Falımı Baktır'),
              ),
              const SizedBox(height: 16),

              // Disclaimer
              Text(
                'Bu yorum eğlence amaçlıdır ve profesyonel tavsiye yerine geçmez.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
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

class _ImagePickerCard extends StatelessWidget {
  final XFile? image;
  final IconData placeholder;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _ImagePickerCard({
    this.image,
    required this.placeholder,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? FutureBuilder<Uint8List>(
                future: image!.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(snapshot.data!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filled(
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              )
            : InkWell(
                onTap: onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(placeholder, size: 48),
                    const SizedBox(height: 8),
                    const Text('Fotoğraf Ekle'),
                  ],
                ),
              ),
      ),
    );
  }
}
