import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuthDataSource? dataSource})
      : _dataSource = dataSource ?? FirebaseAuthDataSource();

  final FirebaseAuthDataSource _dataSource;

  @override
  Stream<AuthUser?> get onAuthStateChanged => _dataSource.onAuthStateChanged;

  @override
  Future<AuthUser?> signInAnonymously() => _dataSource.signInAnonymously();

  @override
  Future<AuthUser?> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<void> signOut() => _dataSource.signOut();
}
