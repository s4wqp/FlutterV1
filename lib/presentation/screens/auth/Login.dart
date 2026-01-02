import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'SignUp.dart';
import 'approval_waiting.dart';
import 'package:tarek_proj/presentation/screens/home/Choice.dart';
import 'package:tarek_proj/presentation/screens/home/HomePage.dart';
import 'package:tarek_proj/presentation/screens/home/ServicesHomeScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<Map<String, String>> sponsors = [
    {
      "image": "images/amazon.png",
      "android_url":
          "https://play.google.com/store/apps/details?id=com.amazon.mShop.android.shopping",
      "ios_url": "https://apps.apple.com/app/amazon-shopping/id297606951"
    },
    {
      "image": "images/talabat.png",
      "android_url":
          "https://play.google.com/store/apps/details?id=com.talabat",
      "ios_url": "https://apps.apple.com/app/talabat/id451001072"
    },
    {
      "image": "images/uber.png",
      "android_url":
          "https://play.google.com/store/apps/details?id=com.ubercab",
      "ios_url": "https://apps.apple.com/app/uber/id368677368"
    },
  ];

  int currentIndex = 0;
  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Rotate banner ads every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          currentIndex = (currentIndex + 1) % sponsors.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Function to launch Play Store or App Store
  void _launchAppStore(String androidUrl, String iosUrl) async {
    final String url = Platform.isAndroid ? androidUrl : iosUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showErrorDialog("Error", "Could not launch $url");
      }
    }
  }

  Future<void> handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorDialog("Error", "Please fill in all fields.");
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Check approval status
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final approvalStatus = doc.data()?['approvalStatus'] ?? 'pending';
          final String? serviceType = doc.data()?['serviceType'];

          // Logic to check isProvider/isSeeker with fallback to serviceType string
          final bool isProvider = doc.data()?['isProvider'] ??
              (serviceType == 'Provider' || serviceType == 'Both');
          final bool isSeeker = doc.data()?['isSeeker'] ??
              (serviceType == 'Seeker' || serviceType == 'Both');

          if (approvalStatus == 'approved') {
            if (mounted) {
              if (isProvider) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Homepage()),
                );
              } else if (isSeeker) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ServicesHomeScreen()),
                );
              } else {
                // Should not happen if data is correct, but fallback to Choice
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Choice(registrationData: {})),
                );
              }
            }
          } else if (approvalStatus == 'pending') {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ApprovalWaitingPage(
                        targetScreen: isProvider
                            ? const Homepage()
                            : (isSeeker
                                ? const ServicesHomeScreen()
                                : const Choice(registrationData: {})))),
              );
            }
          } else if (approvalStatus == 'rejected') {
            showErrorDialog("Account Rejected",
                "Your account has been rejected. Please contact support.");
            await _auth.signOut();
          }
        } else {
          // User exists in Auth but not in Firestore (legacy user or partial registration)
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const Choice(registrationData: {})),
              (Route<dynamic> route) => false,
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      // More specific error messages
      String errorMsg = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        errorMsg = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Wrong password provided for that user.";
      } else if (e.code == 'invalid-email') {
        errorMsg = "The email address is not valid.";
      } else if (e.code == 'user-disabled') {
        errorMsg = "This user has been disabled.";
      } else if (e.code == 'too-many-requests') {
        errorMsg = "Too many requests. Try again later.";
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
      showErrorDialog("Login Failed", errorMsg);
    } catch (e) {
      showErrorDialog("Login Failed", "An unexpected error occurred.");
    }
  }

  void showErrorDialog(String title, String message) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: GestureDetector(
          onTap: () {
            _launchAppStore(
              sponsors[currentIndex]["android_url"]!,
              sponsors[currentIndex]["ios_url"]!,
            );
          },
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(sponsors[currentIndex]["image"]!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            // This makes the screen scrollable
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome!',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          "I'm waiting for you, please fill your info",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5, bottom: 5),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.indigo),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            hintText: 'name@gmail.com',
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5, bottom: 5),
                            child: Text(
                              'Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.indigo),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            hintText: '********',
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Adjust spacing for Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Forgot Password Logic
                            },
                            child: const Text('Forgot Password?',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignUpPage()),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
