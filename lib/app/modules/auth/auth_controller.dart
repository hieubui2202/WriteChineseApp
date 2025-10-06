import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../controllers/progress_controller.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  AuthController({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  final Rxn<User> _user = Rxn<User>();
  bool _initialized = false;

  User? get user => _user.value;

  @override
  void onReady() {
    super.onReady();
    _user.bindStream(_auth.authStateChanges());
    ever<User?>(_user, _setInitialScreen);
  }

  Future<void> _setInitialScreen(User? user) async {
    if (!_initialized) {
      _initialized = true;
      if (user == null) {
        Get.offAllNamed(Routes.AUTH);
      } else {
        await Get.find<ProgressController>().bootstrap(user);
        Get.offAllNamed(Routes.HOME);
      }
    } else if (user != null) {
      await Get.find<ProgressController>().bootstrap(user);
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.AUTH);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      await Get.find<ProgressController>().bootstrap(result.user);
    } catch (error) {
      Get.snackbar(
        'Sign-in failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      await Get.find<ProgressController>().bootstrap(result.user);
    } catch (error) {
      Get.snackbar(
        'Unable to start trial',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await Get.find<ProgressController>().clear();
    Get.offAllNamed(Routes.AUTH);
  }
}
