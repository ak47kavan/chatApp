import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kri_dhan/api/apis.dart';
import 'package:kri_dhan/main.dart';
import 'package:kri_dhan/screens/auth/login_screen.dart';
import 'package:kri_dhan/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _welcomeAnimation;
  late Animation<double> _kavanAnimation;
  late Animation<double> _imageAnimation;

  @override
  void initState() {
    super.initState();

    // Single animation controller for all animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Animations for Welcome Text, Image, and Developed By AK Kavan Text
    _welcomeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _kavanAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _imageAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start all animations at the same time
    _controller.forward();

    // Navigate to the next screen after animations
    Future.delayed(const Duration(seconds: 4), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle( const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white));

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const loginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    const backgroundColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Animated Image
          Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: FadeTransition(
              opacity: _imageAnimation,
              child: ScaleTransition(
                scale: _imageAnimation,
                child: Image.asset(
                  "images/phone.png", // Ensure the image is correctly placed in the assets folder
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Animated "Welcome to AK Chat"
          Positioned(
            top: mq.height * .45,
            width: mq.width,
            child: FadeTransition(
              opacity: _welcomeAnimation,
              child: ScaleTransition(
                scale: _welcomeAnimation,
                child: Text(
                  "Welcome to AK Chat",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // Animated "Developed By AK Kavan"
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: Column(
              children: [
                // "Developed By"
                FadeTransition(
                  opacity: _kavanAnimation,
                  child: ScaleTransition(
                    scale: _kavanAnimation,
                    child: Text(
                      "Developed By",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // "AK Kavan"
                FadeTransition(
                  opacity: _kavanAnimation,
                  child: ScaleTransition(
                    scale: _kavanAnimation,
                    child: Text(
                      "AK Kavan",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lobster(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
