import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'approval_waiting.dart';

class PersonalInfo4 extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String arabicName;
  final String jobTitle;
  final String phone;
  final String birthDate;

  const PersonalInfo4({
    super.key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.arabicName,
    required this.jobTitle,
    required this.phone,
    required this.birthDate,
  });

  @override
  _PersonalInfo4State createState() => _PersonalInfo4State();
}

class _PersonalInfo4State extends State<PersonalInfo4> {
  String selectedGender = "Male";
  String selectedCity = "Cairo";
  final List<String> egyptianCities = [
    "Cairo",
    "Alexandria",
    "Giza",
    "Luxor",
    "Aswan",
    "Sharm El-Sheikh",
    "Hurghada"
  ];

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

  void showLoadingDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: "Processing",
      desc: "Saving your information...",
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void hideLoadingDialog() {
    Navigator.pop(context);
  }

  void handlePrevious() {
    Navigator.pop(context);
  }

  Future<void> handleNext() async {
    print("Finalizing Signup...");
    print("Email: ${widget.email}");
    print("First Name: ${widget.firstName}");
    print("Last Name: ${widget.lastName}");
    print("Arabic Name: ${widget.arabicName}");
    print("Job Title: ${widget.jobTitle}");
    print("Phone: ${widget.phone}");
    print("Birth Date: ${widget.birthDate}");
    print("Gender: $selectedGender");
    print("City: $selectedCity");

    showLoadingDialog();

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.email, password: widget.password);

      User? user = userCredential.user;

      if (user == null) {
        hideLoadingDialog();
        showErrorDialog("Error", "Failed to create user. Please try again.");
        return;
      }

      print("Attempting to update Firestore for user: ${user.uid}");

      // Send verification email
      if (!user.emailVerified) {
        try {
          await user.sendEmailVerification();
          print("Verification email sent to ${user.email}");
        } catch (e) {
          print("Failed to send verification email: $e");
        }
      }
      // Save complete user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'englishName':
            "${widget.firstName} ${widget.lastName}", // Optional: keep composite name for easier display if needed
        'arabicName': widget.arabicName,
        'jobTitle': widget.jobTitle,
        'phone': widget.phone,
        'birthDate': widget.birthDate,
        'gender': selectedGender,
        'city': selectedCity,
        'approvalStatus': 'pending', // pending, approved, rejected
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      });
      print("Firestore update successful for user: ${user.uid}");

      hideLoadingDialog();

      // Navigate to approval waiting page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ApprovalWaitingPage()),
      );
    } on FirebaseAuthException catch (e) {
      hideLoadingDialog();
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use. Try another.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password should be at least 8 characters.";
      }
      showErrorDialog("Registration Error", errorMessage);
    } catch (e) {
      hideLoadingDialog();
      print("Firestore update failed: $e");
      if (e is FirebaseException && e.code == 'permission-denied') {
        showErrorDialog("Permission Error",
            "Unable to save your information. Please check app permissions.");
      } else {
        showErrorDialog(
            "Error", "Failed to save your information. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demographics'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Step 4 of 4',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              const Text(
                "Select Gender",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              ToggleButtons(
                fillColor: Colors.white24,
                selectedColor: Colors.white,
                color: Colors.white,
                isSelected: [
                  selectedGender == "Male",
                  selectedGender == "Female"
                ],
                onPressed: (index) {
                  setState(() {
                    selectedGender = index == 0 ? "Male" : "Female";
                  });
                },
                borderRadius: BorderRadius.circular(15),
                children: const [
                  Padding(padding: EdgeInsets.all(10), child: Text("Male")),
                  Padding(padding: EdgeInsets.all(10), child: Text("Female")),
                ],
              ),
              const SizedBox(height: 70),

              // City Selection
              const Text(
                "Select City",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo, width: 1),
                ),
                child: DropdownButton<String>(
                  value: selectedCity,
                  isExpanded: true,
                  icon: const Icon(Icons.location_city, color: Colors.indigo),
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  dropdownColor: Colors.white,
                  items: egyptianCities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCity = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: handlePrevious,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.grey[800],
                    ),
                    child: const Text('Previous',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: handleNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.indigo,
                    ),
                    child: const Text('Finish',
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
