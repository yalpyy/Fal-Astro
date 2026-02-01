import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../providers/profile_provider.dart';
import '../../router/route_names.dart';
import '../../widgets/common/loading_overlay.dart';

/// Onboarding screen for birth profile
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'Türkiye');

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  bool _unknownTime = false;

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _birthTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğum tarihi seçiniz')),
      );
      return;
    }

    DateTime? birthTimeDateTime;
    if (_birthTime != null && !_unknownTime) {
      birthTimeDateTime = DateTime(
        _birthDate!.year,
        _birthDate!.month,
        _birthDate!.day,
        _birthTime!.hour,
        _birthTime!.minute,
      );
    }

    await ref.read(profileProvider.notifier).saveBirthProfile(
          birthDate: _birthDate!,
          birthTime: birthTimeDateTime,
          birthCity: _cityController.text.trim(),
          birthCountry: _countryController.text.trim(),
          unknownTime: _unknownTime,
        );

    if (mounted && ref.read(profileProvider).hasBirthProfile) {
      context.goNamed(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doğum Bilgileri'),
      ),
      body: LoadingOverlay(
        isLoading: profileState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Icon(
                  Icons.stars,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Kişisel Astroloji',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Size özel yorumlar için doğum bilgilerinizi girin',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),

                // Birth Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Doğum Tarihi'),
                  subtitle: Text(
                    _birthDate != null
                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                        : 'Tarih seçiniz',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectDate,
                ),
                const Divider(),

                // Birth Time
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: !_unknownTime,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Doğum Saati'),
                  subtitle: Text(
                    _unknownTime
                        ? 'Bilinmiyor'
                        : _birthTime != null
                            ? '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}'
                            : 'Saat seçiniz (opsiyonel)',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _unknownTime ? null : _selectTime,
                ),

                // Unknown time checkbox
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _unknownTime,
                  onChanged: (value) {
                    setState(() {
                      _unknownTime = value ?? false;
                      if (_unknownTime) _birthTime = null;
                    });
                  },
                  title: const Text('Doğum saatimi bilmiyorum'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const Divider(),

                const SizedBox(height: 16),

                // Birth City
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Doğum Şehri',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.city,
                ),
                const SizedBox(height: 16),

                // Birth Country
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Doğum Ülkesi',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.country,
                ),
                const SizedBox(height: 32),

                // Submit
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Devam Et'),
                ),
                const SizedBox(height: 16),

                // Privacy note
                Text(
                  'Doğum bilgileriniz güvenli şekilde saklanır ve sadece size özel yorumlar oluşturmak için kullanılır.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
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
