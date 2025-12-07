import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:tarek_proj/presentation/screens/auth/personal_info2.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();

  const SignUpPage({super.key});
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController repassController = TextEditingController();
  bool _obscureTextPass = true;
  bool _obscureTextRePass = true;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    repassController.dispose();
    super.dispose();
  }

  void showErrorDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8;
  }

  Future<void> handleSignUp() async {
    String email = emailController.text.trim();
    String password = passController.text.trim();
    String repassword = repassController.text.trim();

    if (email.isEmpty || password.isEmpty || repassword.isEmpty) {
      showErrorDialog("Error", "Please fill in all fields.");
      return;
    }

    if (!isValidEmail(email)) {
      showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    if (!isValidPassword(password)) {
      showErrorDialog(
          "Weak Password", "Password must be at least 8 characters.");
      return;
    }

    if (password != repassword) {
      showErrorDialog("Password Mismatch", "Passwords do not match.");
      return;
    }

    try {
      // Check if email already exists
      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        showErrorDialog("Email Already Registered",
            "This email is already in use. Please use a different email.");
        return;
      }

      // Navigate to Personal Info Page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PersonalInfo2(email: email, password: password)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";

      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use. Try another.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password should be at least 8 characters.";
      }

      showErrorDialog("Error", errorMessage);
    } catch (e) {
      showErrorDialog("Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              const Text(
                "Let's create an account",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                "Step 1: Enter Email & Set Password",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email, color: Colors.indigo),
                  hintText: 'name@gmail.com',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: passController,
                obscureText: _obscureTextPass,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.indigo),
                  hintText: 'Enter Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureTextPass
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureTextPass = !_obscureTextPass;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: repassController,
                obscureText: _obscureTextRePass,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.indigo),
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureTextRePass
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureTextRePass = !_obscureTextRePass;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: handleSignUp,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
