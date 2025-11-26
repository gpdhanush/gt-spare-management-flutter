import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file', // For Google Drive access
    ],
  );

  AuthService._init();

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      EasyLoading.show(status: 'Signing in...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        _currentUser = account;
        EasyLoading.dismiss();
        return account;
      }
      EasyLoading.dismiss();
      return null;
    } catch (error) {
      EasyLoading.dismiss();
      EasyLoading.showError('Sign in failed: ${error.toString()}');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      EasyLoading.show(status: 'Signing out...');
      await _googleSignIn.signOut();
      _currentUser = null;
      EasyLoading.dismiss();
    } catch (error) {
      EasyLoading.dismiss();
      EasyLoading.showError('Sign out failed: ${error.toString()}');
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        _currentUser = account;
      }
      return account;
    } catch (error) {
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final GoogleSignInAuthentication auth =
          await _currentUser!.authentication;
      return auth.accessToken;
    } catch (error) {
      return null;
    }
  }
}
