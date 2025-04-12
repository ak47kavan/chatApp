import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kri_dhan/screens/splash_screen.dart';
import 'firebase_options.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system colors globally
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Status bar color
      statusBarIconBrightness: Brightness.dark, // Status bar icon brightness
      systemNavigationBarColor: Colors.white, // Navigation bar color
      systemNavigationBarIconBrightness: Brightness.dark, // Navigation bar icon brightness
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AK Chat',
      theme: ThemeData(
        // Global AppBar Theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black), // Icon color
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 19,
          ),
          backgroundColor: Colors.white, // AppBar background
        ),
        scaffoldBackgroundColor: Colors.white, // Global background color
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // BottomNavigationBar background
          selectedItemColor: Colors.blue, // Selected item color
          unselectedItemColor: Colors.grey, // Unselected item color
          elevation: 5, // Optional shadow
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Initialize Firebase asynchronously
_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
