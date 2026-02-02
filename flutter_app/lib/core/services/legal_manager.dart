import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../env/env.dart';

/// Legal document types
enum LegalDocType {
  terms,
  privacy,
  kvkk,
}

/// Legal document model
class LegalDocument {
  final String id;
  final LegalDocType docType;
  final String version;
  final String title;
  final String content;
  final String locale;
  final DateTime effectiveDate;
  final bool isActive;

  const LegalDocument({
    required this.id,
    required this.docType,
    required this.version,
    required this.title,
    required this.content,
    required this.locale,
    required this.effectiveDate,
    required this.isActive,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id'] as String,
      docType: _parseDocType(json['doc_type'] as String),
      version: json['version'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      locale: json['locale'] as String? ?? 'tr',
      effectiveDate: DateTime.parse(json['effective_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static LegalDocType _parseDocType(String type) {
    switch (type.toLowerCase()) {
      case 'terms':
        return LegalDocType.terms;
      case 'privacy':
        return LegalDocType.privacy;
      case 'kvkk':
        return LegalDocType.kvkk;
      default:
        return LegalDocType.terms;
    }
  }
}

/// User consent status
class ConsentStatus {
  final bool termsAccepted;
  final String? termsVersion;
  final DateTime? termsAcceptedAt;
  final bool privacyAccepted;
  final String? privacyVersion;
  final DateTime? privacyAcceptedAt;
  final bool marketingConsent;
  final DateTime? marketingConsentAt;

  const ConsentStatus({
    this.termsAccepted = false,
    this.termsVersion,
    this.termsAcceptedAt,
    this.privacyAccepted = false,
    this.privacyVersion,
    this.privacyAcceptedAt,
    this.marketingConsent = false,
    this.marketingConsentAt,
  });

  factory ConsentStatus.fromJson(Map<String, dynamic> json) {
    return ConsentStatus(
      termsAccepted: json['terms_accepted_at'] != null,
      termsVersion: json['terms_version'] as String?,
      termsAcceptedAt: json['terms_accepted_at'] != null
          ? DateTime.parse(json['terms_accepted_at'] as String)
          : null,
      privacyAccepted: json['privacy_accepted_at'] != null,
      privacyVersion: json['privacy_version'] as String?,
      privacyAcceptedAt: json['privacy_accepted_at'] != null
          ? DateTime.parse(json['privacy_accepted_at'] as String)
          : null,
      marketingConsent: json['marketing_consent'] as bool? ?? false,
      marketingConsentAt: json['marketing_consent_at'] != null
          ? DateTime.parse(json['marketing_consent_at'] as String)
          : null,
    );
  }

  bool get isFullyConsented => termsAccepted && privacyAccepted;
}

/// Legal requirements check result
class LegalRequirementsResult {
  final bool requiresTermsAcceptance;
  final bool requiresPrivacyAcceptance;
  final String? currentTermsVersion;
  final String? currentPrivacyVersion;
  final LegalDocument? termsDocument;
  final LegalDocument? privacyDocument;

  const LegalRequirementsResult({
    this.requiresTermsAcceptance = false,
    this.requiresPrivacyAcceptance = false,
    this.currentTermsVersion,
    this.currentPrivacyVersion,
    this.termsDocument,
    this.privacyDocument,
  });

  bool get requiresAction => requiresTermsAcceptance || requiresPrivacyAcceptance;
}

/// Legal Manager Service
class LegalManager {
  final SupabaseClient _client;

  LegalManager(this._client);

  /// Get current required versions from app config
  Future<Map<String, String>> _getRequiredVersions() async {
    try {
      final termsResponse = await _client
          .from('app_config')
          .select('value')
          .eq('key', 'current_terms_version')
          .single();

      final privacyResponse = await _client
          .from('app_config')
          .select('value')
          .eq('key', 'current_privacy_version')
          .single();

      // Values are stored as JSON strings, so we need to parse them
      String termsVersion = '1.0';
      String privacyVersion = '1.0';

      if (termsResponse['value'] != null) {
        final value = termsResponse['value'];
        termsVersion = value is String ? value.replaceAll('"', '') : value.toString();
      }

      if (privacyResponse['value'] != null) {
        final value = privacyResponse['value'];
        privacyVersion = value is String ? value.replaceAll('"', '') : value.toString();
      }

      return {
        'terms': termsVersion,
        'privacy': privacyVersion,
      };
    } catch (e) {
      debugPrint('Failed to get required versions: $e');
      return {'terms': '1.0', 'privacy': '1.0'};
    }
  }

  /// Get user's current consent status
  Future<ConsentStatus?> getUserConsentStatus(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('''
            terms_version,
            terms_accepted_at,
            privacy_version,
            privacy_accepted_at,
            marketing_consent,
            marketing_consent_at
          ''')
          .eq('user_id', userId)
          .single();

      return ConsentStatus.fromJson(response);
    } catch (e) {
      debugPrint('Failed to get consent status: $e');
      return null;
    }
  }

  /// Check if user needs to accept any legal documents
  Future<LegalRequirementsResult> checkLegalRequirements(String userId) async {
    final requiredVersions = await _getRequiredVersions();
    final consentStatus = await getUserConsentStatus(userId);

    if (consentStatus == null) {
      // No profile yet, need to accept all
      return LegalRequirementsResult(
        requiresTermsAcceptance: true,
        requiresPrivacyAcceptance: true,
        currentTermsVersion: requiredVersions['terms'],
        currentPrivacyVersion: requiredVersions['privacy'],
        termsDocument: await _getLatestDocument(LegalDocType.terms),
        privacyDocument: await _getLatestDocument(LegalDocType.privacy),
      );
    }

    final requiresTerms = !consentStatus.termsAccepted ||
        consentStatus.termsVersion != requiredVersions['terms'];

    final requiresPrivacy = !consentStatus.privacyAccepted ||
        consentStatus.privacyVersion != requiredVersions['privacy'];

    LegalDocument? termsDoc;
    LegalDocument? privacyDoc;

    if (requiresTerms) {
      termsDoc = await _getLatestDocument(LegalDocType.terms);
    }
    if (requiresPrivacy) {
      privacyDoc = await _getLatestDocument(LegalDocType.privacy);
    }

    return LegalRequirementsResult(
      requiresTermsAcceptance: requiresTerms,
      requiresPrivacyAcceptance: requiresPrivacy,
      currentTermsVersion: requiredVersions['terms'],
      currentPrivacyVersion: requiredVersions['privacy'],
      termsDocument: termsDoc,
      privacyDocument: privacyDoc,
    );
  }

  /// Get latest legal document of a type
  Future<LegalDocument?> _getLatestDocument(
    LegalDocType docType, {
    String locale = 'tr',
  }) async {
    try {
      final docTypeStr = docType.name;
      final response = await _client
          .from('legal_documents')
          .select()
          .eq('doc_type', docTypeStr)
          .eq('locale', locale)
          .eq('is_active', true)
          .order('effective_date', ascending: false)
          .limit(1)
          .single();

      return LegalDocument.fromJson(response);
    } catch (e) {
      debugPrint('Failed to get legal document: $e');
      return null;
    }
  }

  /// Record user consent
  Future<bool> recordConsent({
    required String userId,
    required LegalDocType docType,
    required String version,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      // Call the database function to log consent
      await _client.rpc('log_consent', params: {
        'p_user_id': userId,
        'p_consent_type': docType.name,
        'p_action': 'accepted',
        'p_version': version,
        'p_ip_address': ipAddress,
        'p_user_agent': userAgent,
      });

      return true;
    } catch (e) {
      debugPrint('Failed to record consent: $e');
      return false;
    }
  }

  /// Accept both terms and privacy
  Future<bool> acceptAllRequired({
    required String userId,
    required String termsVersion,
    required String privacyVersion,
    String? ipAddress,
    String? userAgent,
  }) async {
    final termsResult = await recordConsent(
      userId: userId,
      docType: LegalDocType.terms,
      version: termsVersion,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );

    final privacyResult = await recordConsent(
      userId: userId,
      docType: LegalDocType.privacy,
      version: privacyVersion,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );

    return termsResult && privacyResult;
  }

  /// Update marketing consent
  Future<bool> updateMarketingConsent({
    required String userId,
    required bool consent,
  }) async {
    try {
      await _client.rpc('log_consent', params: {
        'p_user_id': userId,
        'p_consent_type': 'marketing',
        'p_action': consent ? 'accepted' : 'withdrawn',
      });

      return true;
    } catch (e) {
      debugPrint('Failed to update marketing consent: $e');
      return false;
    }
  }

  /// Request data deletion (GDPR/KVKK right)
  Future<bool> requestDataDeletion(String userId) async {
    try {
      await _client.rpc('log_consent', params: {
        'p_user_id': userId,
        'p_consent_type': 'data_deletion',
        'p_action': 'requested',
      });

      // In a real app, this would trigger a background job to delete user data
      // For now, we just log the request

      return true;
    } catch (e) {
      debugPrint('Failed to request data deletion: $e');
      return false;
    }
  }
}

// ============================================================================
// RIVERPOD PROVIDERS
// ============================================================================

/// Legal Manager provider
final legalManagerProvider = Provider<LegalManager?>((ref) {
  if (!Env.isConfigured) return null;

  try {
    return LegalManager(Supabase.instance.client);
  } catch (e) {
    return null;
  }
});

/// Legal requirements state
class LegalRequirementsState {
  final bool isLoading;
  final LegalRequirementsResult? result;
  final String? error;

  const LegalRequirementsState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  LegalRequirementsState copyWith({
    bool? isLoading,
    LegalRequirementsResult? result,
    String? error,
  }) {
    return LegalRequirementsState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }

  bool get requiresAction => result?.requiresAction ?? false;
}

/// Legal requirements notifier
class LegalRequirementsNotifier extends StateNotifier<LegalRequirementsState> {
  final LegalManager? _manager;
  final String? _userId;

  LegalRequirementsNotifier(this._manager, this._userId)
      : super(const LegalRequirementsState()) {
    if (_userId != null) {
      checkRequirements();
    }
  }

  Future<void> checkRequirements() async {
    if (_manager == null || _userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _manager.checkLegalRequirements(_userId);
      state = LegalRequirementsState(result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> acceptAll() async {
    if (_manager == null || _userId == null) return false;
    if (state.result == null) return false;

    final termsVersion = state.result!.currentTermsVersion ?? '1.0';
    final privacyVersion = state.result!.currentPrivacyVersion ?? '1.0';

    final success = await _manager.acceptAllRequired(
      userId: _userId,
      termsVersion: termsVersion,
      privacyVersion: privacyVersion,
    );

    if (success) {
      await checkRequirements();
    }

    return success;
  }
}

/// Legal requirements provider
final legalRequirementsProvider =
    StateNotifierProvider<LegalRequirementsNotifier, LegalRequirementsState>((ref) {
  final manager = ref.watch(legalManagerProvider);
  final userId = Env.isConfigured
      ? Supabase.instance.client.auth.currentUser?.id
      : null;

  return LegalRequirementsNotifier(manager, userId);
});

// ============================================================================
// UI COMPONENTS
// ============================================================================

/// Legal consent dialog that blocks the app until accepted
class LegalConsentDialog extends ConsumerWidget {
  const LegalConsentDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legalState = ref.watch(legalRequirementsProvider);

    if (legalState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final result = legalState.result;
    if (result == null || !result.requiresAction) {
      return const SizedBox.shrink();
    }

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Yasal Onay Gerekli',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Devam etmek için aşağıdaki belgeleri kabul etmeniz gerekmektedir.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Terms
            if (result.requiresTermsAcceptance && result.termsDocument != null)
              _DocumentSection(
                title: result.termsDocument!.title,
                content: result.termsDocument!.content,
              ),

            if (result.requiresTermsAcceptance && result.requiresPrivacyAcceptance)
              const SizedBox(height: 16),

            // Privacy
            if (result.requiresPrivacyAcceptance && result.privacyDocument != null)
              _DocumentSection(
                title: result.privacyDocument!.title,
                content: result.privacyDocument!.content,
              ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(legalRequirementsProvider.notifier)
                    .acceptAll();

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Kabul Ediyorum'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentSection extends StatelessWidget {
  final String title;
  final String content;

  const _DocumentSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget that wraps the app and shows legal dialog when needed
class LegalGate extends ConsumerWidget {
  final Widget child;

  const LegalGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legalState = ref.watch(legalRequirementsProvider);

    // Show dialog if legal acceptance required
    if (legalState.result?.requiresAction == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const LegalConsentDialog(),
        );
      });
    }

    return child;
  }
}
