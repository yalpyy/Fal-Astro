import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/birth_profile.dart';
import '../../data/repositories/profile_repository.dart';
import 'auth_provider.dart';

/// Profile repository provider - returns null if Supabase not configured
final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final client = ref.watch(safeSupabaseClientProvider);
  if (client == null) return null;
  return ProfileRepository(client);
});

/// User profile state
class ProfileState {
  final UserProfile? profile;
  final BirthProfile? birthProfile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.birthProfile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? profile,
    BirthProfile? birthProfile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      birthProfile: birthProfile ?? this.birthProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasProfile => profile != null;
  bool get hasBirthProfile => birthProfile != null;
  bool get isOnboarded => hasBirthProfile;
}

/// Profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository? _repository;

  ProfileNotifier(this._repository) : super(const ProfileState());

  Future<void> loadProfile() async {
    if (_repository == null) {
      // Unconfigured - no profile to load
      state = const ProfileState(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getProfile();
      final birthProfile = await _repository.getBirthProfile();
      state = ProfileState(
        profile: profile,
        birthProfile: birthProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
    String? locale,
  }) async {
    if (_repository == null) {
      state = state.copyWith(error: 'Supabase not configured');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.updateProfile(
        name: name,
        avatarUrl: avatarUrl,
        locale: locale,
      );
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveBirthProfile({
    required DateTime birthDate,
    DateTime? birthTime,
    required String birthCity,
    required String birthCountry,
    String timezone = 'Europe/Istanbul',
    bool unknownTime = false,
    double? latitude,
    double? longitude,
  }) async {
    if (_repository == null) {
      state = state.copyWith(error: 'Supabase not configured');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final birthProfile = await _repository.saveBirthProfile(
        birthDate: birthDate,
        birthTime: birthTime,
        birthCity: birthCity,
        birthCountry: birthCountry,
        timezone: timezone,
        unknownTime: unknownTime,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(birthProfile: birthProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = const ProfileState();
  }
}

/// Profile state provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final notifier = ProfileNotifier(ref.watch(profileRepositoryProvider));

  // Load profile when auth state changes
  ref.listen(authProvider, (previous, next) {
    if (next.isAuthenticated && !previous!.isAuthenticated) {
      notifier.loadProfile();
    } else if (!next.isAuthenticated) {
      notifier.clear();
    }
  });

  // Initial load if already authenticated
  final authState = ref.read(authProvider);
  if (authState.isAuthenticated) {
    notifier.loadProfile();
  }

  return notifier;
});

/// Has birth profile provider
final hasBirthProfileProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).hasBirthProfile;
});

/// Is onboarded provider
final isOnboardedProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isOnboarded;
});

/// User's zodiac sign provider
final zodiacSignProvider = Provider<String?>((ref) {
  return ref.watch(profileProvider).birthProfile?.zodiacSign;
});
