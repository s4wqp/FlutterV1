import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:tarek_proj/presentation/screens/auth/personal_info3.dart';

import 'SignUp.dart';

class PersonalInfo2 extends StatefulWidget {
  final String email;
  final String password;

  const PersonalInfo2({super.key, required this.email, required this.password});

  @override
  _PersonalInfo2State createState() => _PersonalInfo2State();
}

class _PersonalInfo2State extends State<PersonalInfo2> {
  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController arabicNameController = TextEditingController();

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

  void handleNext() {
    String englishName = englishNameController.text.trim();
    String arabicName = arabicNameController.text.trim();

    if (englishName.isEmpty || arabicName.isEmpty) {
      showErrorDialog("Error", "Please fill in all fields.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfo3(
          email: widget.email,
          password: widget.password,
          englishName: englishName,
          arabicName: arabicName,
        ),
      ),
    );
  }

  void handlePrevious() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Info')),
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
            children: [
              const SizedBox(height: 70),
              const Text(
                "Step 2 of 4",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 50),

              // English Name Input
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 5, bottom: 5),
                  child: Text(
                    'English Name',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TextField(
                controller: englishNameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  hintText: 'John Doe',
                  hintStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 30),

              // Arabic Name Input
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 5, bottom: 5),
                  child: Text(
                    'الاسم بالعربية',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TextField(
                controller: arabicNameController,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.person, color: Colors.indigo),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  hintText: 'محمد أحمد',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button (Now Saves Email & Password)
                  ElevatedButton(
                    onPressed: handlePrevious,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Previous',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),

                  // Next Button
                  ElevatedButton(
                    onPressed: handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Next',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
