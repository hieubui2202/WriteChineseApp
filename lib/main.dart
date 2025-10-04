import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

// Import the generated Firebase options file
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hanzi Writer App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121418),
        primaryColor: const Color(0xFF0d1117),
        
        // Define a custom font for the app if you have one
        // fontFamily: 'Noto Sans SC',

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00CFFF), // Neon Blue
          secondary: Color(0xFF78E08F),
          surface: Color(0xFF0d1117),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.white),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00CFFF), // Neon Blue
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

