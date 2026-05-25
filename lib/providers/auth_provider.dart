import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._firestoreService) {
    _listenToAuthChanges();
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;

  StreamSubscription<User?>? _authSubscription;
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  bool get isAuthenticated => _firebaseUser != null;
  String? get errorMessage => _errorMessage;
  String get displayName => _userModel?.name ?? 'Bạn';

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final UserCredential credential = await _authService
          .loginWithEmailPassword(email: email.trim(), password: password);
      await _syncUser(credential.user);
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } catch (_) {
      _errorMessage = 'Đăng nhập thất bại. Vui lòng thử lại.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final UserCredential credential = await _authService
          .registerWithEmailPassword(email: email.trim(), password: password);

      final User? user = credential.user;
      if (user == null) {
        _errorMessage = 'Không thể tạo tài khoản mới.';
        return false;
      }

      final UserModel profile = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.saveUser(profile);
      _firebaseUser = user;
      _userModel = profile;
      _isCheckingAuth = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } catch (_) {
      _errorMessage = 'Đăng ký thất bại. Vui lòng thử lại.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    _isCheckingAuth = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_firebaseUser == null) {
      return;
    }
    _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
    notifyListeners();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authService.authStateChanges().listen((
      User? user,
    ) async {
      await _syncUser(user);
    });
  }

  Future<void> _syncUser(User? user) async {
    _firebaseUser = user;

    if (user == null) {
      _userModel = null;
      _isCheckingAuth = false;
      notifyListeners();
      return;
    }

    try {
      _userModel =
          await _firestoreService.getUser(user.uid) ??
          UserModel(
            uid: user.uid,
            name:
                user.displayName ??
                user.email?.split('@').first ??
                'Người dùng',
            email: user.email ?? '',
            createdAt: user.metadata.creationTime ?? DateTime.now(),
          );
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email hoặc mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu phải có ít nhất 6 ký tự.';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhiều lần. Vui lòng thử lại sau.';
      default:
        return error.message ?? 'Đã xảy ra lỗi xác thực.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
