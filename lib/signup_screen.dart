import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // TextField controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // SignUp function for Firebase Authentication
  void signUp() async {
    try {
      // Check if the passwords match
      if (passwordController.text == confirmPasswordController.text) {
        // Create a new user with Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Save user data to Firebase Realtime Database
        // FirebaseDatabase database = FirebaseDatabase.instance;
        // DatabaseReference ref = database.ref('users');  // Reference to 'users' table

        // // Store the user data under the user's UID
        // await ref.child(userCredential.user!.uid).set({
        //   'username': usernameController.text,
        //   'email': emailController.text,
        //   // Optional: You might not want to store password in plain text
        // });

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(
        {
          'preferences': ['all'],
        },
        SetOptions(merge: true), // Merges with existing data
      );

        // On success, show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup successful! Welcome ${userCredential.user?.email}')),
        );

        // Optional: Navigate to another screen after signup
        // Navigator.pushReplacementNamed(context, '/home');

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")),
        );
      }
    } catch (e) {
      // Handle errors (e.g., email already in use)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Upper Gradient Panel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900, // Dark Blue
                    Colors.blue.shade700, // Navy Blue
                    Colors.grey.shade500, // Grey
                    Colors.blue.shade800, // Light Blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 40, left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's get you",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Onboard!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              children: [
                // Background Gradient for the Curved Area
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade900,
                        Colors.blue.shade700,
                        Colors.grey.shade500,
                        Colors.blue.shade800,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // White Bottom Panel with Curved Borders
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          // Username Input Field
                          TextField(
                            controller: usernameController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'Username',
                              labelStyle: const TextStyle(color: Colors.blue),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Email Input Field
                          TextField(
                            controller: emailController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email),
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.blue),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Create Password Input Field
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Create Password',
                              labelStyle: const TextStyle(color: Colors.blue),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Confirm Password Input Field
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Confirm Password',
                              labelStyle: const TextStyle(color: Colors.blue),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Signup Button
                          ElevatedButton(
                            onPressed: signUp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                          const SizedBox(height: 20),
                          // Back to Login
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Go back to the login screen
                            },
                            child: const Text(
                              "Already have an account? Sign in",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
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
}
