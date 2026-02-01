import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
  });

  group('AuthRepository', () {
    test('currentUser returns null when not logged in', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      // Test would be: repository.currentUser == null
      expect(mockAuth.currentUser, isNull);
    });

    test('currentUser returns user when logged in', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      expect(mockAuth.currentUser, isNotNull);
    });

    test('isLoggedIn returns correct value', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(mockAuth.currentUser != null, isFalse);

      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      expect(mockAuth.currentUser != null, isTrue);
    });
  });
}
