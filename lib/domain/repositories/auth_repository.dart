import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get onAuthStateChanged;
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signInAnonymously();
  Future<void> signOut();
}
