import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'presentation/bindings/app_binding.dart';
import 'presentation/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
        appleProvider: kReleaseMode ? AppleProvider.deviceCheck : AppleProvider.debug,
      );
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    } on MissingPluginException catch (error) {
      debugPrint('Firebase App Check plugin is unavailable: $error');
    } on PlatformException catch (error) {
      debugPrint('Failed to activate Firebase App Check: ${error.code} ${error.message}');
    }
  }
  await FirebaseAuth.instance.setLanguageCode('vi');
  runApp(const HanziTrainerApp());
}

class HanziTrainerApp extends StatelessWidget {
  const HanziTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.notoSansTextTheme(baseTheme.textTheme.apply(bodyColor: Colors.white));

    return GetMaterialApp(
      title: 'Hanzi Writing Trainer',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFF121418),
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: const Color(0xFF00CFFF),
          secondary: const Color(0xFFFFD166),
          surface: const Color(0xFF161923),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        textTheme: textTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00CFFF),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00CFFF),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ),
      initialRoute: AppPages.initial,
      initialBinding: AppBinding(),
      getPages: AppPages.routes,
    );
  }
}
