import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart'; // Import your LoginScreen
import 'signup_screen.dart'; // Import your SignupScreen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _englishTextAnimation;
  late Animation<Offset> _urduTextAnimation;
  late Animation<Offset> _buttonAnimation;

  bool _showButtons = false;
  bool _moveTextUp = false; // Flag for moving text up

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Duration for text slide-in
      vsync: this,
    );

    // Create animations for text and buttons
    _englishTextAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Start from the left
      end: Offset.zero, // End at the original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _urduTextAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0), // Start from the right
      end: Offset.zero, // End at the original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _buttonAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from below
      end: Offset.zero, // End at the original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Start the animations for text
    _controller.forward();

    // After text animation finishes, wait 10 seconds then move text up and show buttons
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 10), () {
          setState(() {
            _moveTextUp = true; // Trigger text upward movement
          });

          // Show buttons after moving text
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _showButtons = true; // Trigger button animation
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Set background color to light blue
      body: Stack(
        children: [
          // Background animation
          Center(
            child: Lottie.asset(
              "assets/animations/news.json", // Your animation file
              repeat: true, // Run once
            ),
          ),
          // Sliding text overlay at the bottom center
          _buildSlidingText(),
          // Sliding buttons from the bottom (only if showButtons is true)
          if (_showButtons) _buildSlidingButtons(),
        ],
      ),
    );
  }

  Widget _buildSlidingText() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // English text sliding from the left
          SlideTransition(
            position: _englishTextAnimation,
            child: Padding(
              padding: EdgeInsets.only(bottom: _moveTextUp ? 20.0 : 5.0), // Move up if the flag is set
              child: const Text(
                "Fori Feed",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rye',
                  color: Colors.blue,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(128, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Urdu text sliding from the right
          SlideTransition(
            position: _urduTextAnimation,
            child: Padding(
              padding: EdgeInsets.only(bottom: _moveTextUp ? 159.0 : 30.0), // Move up if the flag is set
              child: const Text(
                "فوری فیڈ",
                style: TextStyle(
                  fontFamily: 'BombayBlack',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: _buttonAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Login button
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen with sliding transition
                  Navigator.push(
                    context,
                    _createRoute(const LoginScreen()), // Use custom route
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 17),
                ),
              ),
              const SizedBox(height: 7), // Space between buttons
              // Signup button
              ElevatedButton(
                onPressed: () {
                  // Navigate to signup screen with sliding transition
                  Navigator.push(
                    context,
                    _createRoute(const SignupScreen()), // Use custom route
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Signup',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom route for sliding transition
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from the right
        const end = Offset.zero; // End at the original position
        const curve = Curves.easeInOut;

        var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 800), // Increased duration for slower sliding
    );
  }
}
