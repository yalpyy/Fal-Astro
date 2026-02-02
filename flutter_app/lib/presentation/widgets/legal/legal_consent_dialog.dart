import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/supabase_service.dart';
import '../../providers/auth_provider.dart';

/// Legal requirements check provider
final legalRequirementsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated) {
    return {'needsConsent': false};
  }

  // Get current versions from config
  final configResponse = await supabase.client
      .from('app_config')
      .select('key, value')
      .inFilter('key', ['current_terms_version', 'current_privacy_version']);

  final configs = List<Map<String, dynamic>>.from(configResponse);
  String? currentTermsVersion;
  String? currentPrivacyVersion;

  for (final config in configs) {
    final value = config['value'];
    final cleanValue = value is String ? value.replaceAll('"', '') : value?.toString();
    if (config['key'] == 'current_terms_version') {
      currentTermsVersion = cleanValue;
    } else if (config['key'] == 'current_privacy_version') {
      currentPrivacyVersion = cleanValue;
    }
  }

  // Get user's accepted versions
  final profileResponse = await supabase.client
      .from('profiles')
      .select('terms_version, terms_accepted_at, privacy_version, privacy_accepted_at')
      .eq('user_id', authState.user!.id)
      .maybeSingle();

  if (profileResponse == null) {
    return {
      'needsConsent': true,
      'needsTerms': true,
      'needsPrivacy': true,
      'currentTermsVersion': currentTermsVersion,
      'currentPrivacyVersion': currentPrivacyVersion,
    };
  }

  final userTermsVersion = profileResponse['terms_version'] as String?;
  final userPrivacyVersion = profileResponse['privacy_version'] as String?;

  final needsTerms = userTermsVersion != currentTermsVersion ||
                     profileResponse['terms_accepted_at'] == null;
  final needsPrivacy = userPrivacyVersion != currentPrivacyVersion ||
                       profileResponse['privacy_accepted_at'] == null;

  return {
    'needsConsent': needsTerms || needsPrivacy,
    'needsTerms': needsTerms,
    'needsPrivacy': needsPrivacy,
    'currentTermsVersion': currentTermsVersion,
    'currentPrivacyVersion': currentPrivacyVersion,
  };
});

/// Legal consent dialog (GDPR/KVKK compliant)
class LegalConsentDialog extends ConsumerStatefulWidget {
  final VoidCallback onAccepted;
  final String? termsVersion;
  final String? privacyVersion;

  const LegalConsentDialog({
    super.key,
    required this.onAccepted,
    this.termsVersion,
    this.privacyVersion,
  });

  @override
  ConsumerState<LegalConsentDialog> createState() => _LegalConsentDialogState();
}

class _LegalConsentDialogState extends ConsumerState<LegalConsentDialog> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _marketingAccepted = false;
  bool _isLoading = false;

  bool get _canProceed => _termsAccepted && _privacyAccepted;

  Future<void> _submitConsent() async {
    if (!_canProceed) return;

    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      final authState = ref.read(authProvider);

      if (!authState.isAuthenticated) return;

      final userId = authState.user!.id;
      final now = DateTime.now().toIso8601String();

      // Update profile with consent
      await supabase.client.from('profiles').update({
        'terms_version': widget.termsVersion ?? '1.0',
        'terms_accepted_at': now,
        'privacy_version': widget.privacyVersion ?? '1.0',
        'privacy_accepted_at': now,
        'marketing_consent': _marketingAccepted,
        'marketing_consent_at': _marketingAccepted ? now : null,
      }).eq('user_id', userId);

      // Log consent to audit log
      await supabase.client.from('consent_audit_log').insert([
        {
          'user_id': userId,
          'consent_type': 'terms',
          'action': 'accepted',
          'version': widget.termsVersion ?? '1.0',
        },
        {
          'user_id': userId,
          'consent_type': 'privacy',
          'action': 'accepted',
          'version': widget.privacyVersion ?? '1.0',
        },
        if (_marketingAccepted)
          {
            'user_id': userId,
            'consent_type': 'marketing',
            'action': 'accepted',
          },
      ]);

      widget.onAccepted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false, // Prevent dismissing without consent
      child: Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.security,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gizlilik ve Kullanım Koşulları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Devam etmek için lütfen aşağıdaki koşulları kabul edin.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Terms checkbox
                _ConsentCheckbox(
                  value: _termsAccepted,
                  onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                  required: true,
                  title: 'Kullanım Koşullarını',
                  linkText: 'okudum ve kabul ediyorum',
                  onLinkTap: () => _showDocumentDialog(context, 'terms'),
                ),
                const SizedBox(height: 12),

                // Privacy checkbox
                _ConsentCheckbox(
                  value: _privacyAccepted,
                  onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
                  required: true,
                  title: 'Gizlilik Politikasını',
                  linkText: 'okudum ve kabul ediyorum',
                  onLinkTap: () => _showDocumentDialog(context, 'privacy'),
                ),
                const SizedBox(height: 12),

                // Marketing checkbox (optional)
                _ConsentCheckbox(
                  value: _marketingAccepted,
                  onChanged: (v) => setState(() => _marketingAccepted = v ?? false),
                  required: false,
                  title: 'Kampanya ve duyurulardan',
                  linkText: 'haberdar olmak istiyorum',
                  subtitle: '(İsteğe bağlı)',
                ),
                const SizedBox(height: 24),

                // KVKK notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '6698 sayılı KVKK kapsamında kişisel verileriniz korunmaktadır. '
                          'Verilerinizi istediğiniz zaman silebilirsiniz.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                FilledButton(
                  onPressed: _canProceed && !_isLoading ? _submitConsent : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kabul Et ve Devam Et'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDocumentDialog(BuildContext context, String docType) {
    showDialog(
      context: context,
      builder: (context) => _LegalDocumentDialog(docType: docType),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool required;
  final String title;
  final String linkText;
  final String? subtitle;
  final VoidCallback? onLinkTap;

  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.required,
    required this.title,
    required this.linkText,
    this.subtitle,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(text: '$title '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: onLinkTap,
                            child: Text(
                              linkText,
                              style: TextStyle(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        if (required)
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: colorScheme.error),
                          ),
                      ],
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
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

class _LegalDocumentDialog extends ConsumerWidget {
  final String docType;

  const _LegalDocumentDialog({required this.docType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.read(supabaseServiceProvider);

    return FutureBuilder<Map<String, dynamic>?>(
      future: supabase.client
          .from('legal_documents')
          .select()
          .eq('doc_type', docType)
          .eq('locale', 'tr')
          .eq('is_active', true)
          .order('effective_date', ascending: false)
          .limit(1)
          .maybeSingle(),
      builder: (context, snapshot) {
        return AlertDialog(
          title: Text(
            docType == 'terms' ? 'Kullanım Koşulları' : 'Gizlilik Politikası',
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : snapshot.hasError
                    ? Center(child: Text('Hata: ${snapshot.error}'))
                    : SingleChildScrollView(
                        child: Text(
                          snapshot.data?['content'] ?? 'Döküman bulunamadı.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}

/// Gate widget that shows consent dialog if needed
class LegalConsentGate extends ConsumerWidget {
  final Widget child;

  const LegalConsentGate({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legalAsync = ref.watch(legalRequirementsProvider);

    return legalAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => child, // On error, allow access
      data: (requirements) {
        if (requirements['needsConsent'] == true) {
          // Show consent dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => LegalConsentDialog(
                onAccepted: () {
                  Navigator.pop(context);
                  ref.invalidate(legalRequirementsProvider);
                },
                termsVersion: requirements['currentTermsVersion'],
                privacyVersion: requirements['currentPrivacyVersion'],
              ),
            );
          });
        }
        return child;
      },
    );
  }
}
