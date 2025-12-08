import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tarek_proj/presentation/screens/auth/approval_waiting.dart';

class AddressRegistration extends StatefulWidget {
  // All previous fields
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String arabicName;
  final String jobTitle;
  final String phone;
  final String birthDate;
  final String gender;
  final String city; // Current P4 city choice
  final String serviceType;

  // Provider fields (optional)
  final String? category;
  final List<String>? workingTime;
  final String? dealWith;
  final String? transportationType;
  final String? carName;
  final String? carModel;
  final String? carColor;
  final String? carNumber;
  final String? carLicenseNumber;
  final String? userLicenseNumber;
  final File? carLicenseImage;
  final File? userLicenseImage;
  final String? lookingForCategory;

  const AddressRegistration({
    super.key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.arabicName,
    required this.jobTitle,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.city,
    required this.serviceType,
    this.category,
    this.workingTime,
    this.dealWith,
    this.transportationType,
    this.carName,
    this.carModel,
    this.carColor,
    this.carNumber,
    this.carLicenseNumber,
    this.userLicenseNumber,
    this.carLicenseImage,
    this.userLicenseImage,
    this.lookingForCategory,
  });

  @override
  _AddressRegistrationState createState() => _AddressRegistrationState();
}

class _AddressRegistrationState extends State<AddressRegistration> {
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController buildingNumController = TextEditingController();
  final TextEditingController floorNumController = TextEditingController();
  final TextEditingController aptNumController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  void showLoadingDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: "Processing",
      desc: "Creating your account...",
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void hideLoadingDialog() {
    Navigator.pop(context);
  }

  void showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: "Error",
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  Future<String?> _uploadImage(File image, String folderName) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folderName/$fileName';

      // Ensure Supabase is initialized in main.dart
      await Supabase.instance.client.storage
          .from('provider-documents')
          .upload(path, image);

      return Supabase.instance.client.storage
          .from('provider-documents')
          .getPublicUrl(path);
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  Future<void> handleFinish() async {
    if (countryController.text.isEmpty ||
        stateController.text.isEmpty ||
        districtController.text.isEmpty ||
        streetNameController.text.isEmpty ||
        buildingNumController.text.isEmpty) {
      showErrorDialog("Please fill in the required address fields.");
      return;
    }

    showLoadingDialog();

    try {
      // 1. Create User
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.email, password: widget.password);
      User? user = userCredential.user;

      if (user == null) {
        hideLoadingDialog();
        showErrorDialog("Failed to create user.");
        return;
      }

      String? carLicenseUrl;
      String? userLicenseUrl;

      // 2. Upload Images (if Provider and images exist)
      if (widget.serviceType == "Provider" &&
          widget.carLicenseImage != null &&
          widget.userLicenseImage != null) {
        carLicenseUrl =
            await _uploadImage(widget.carLicenseImage!, 'car_licenses');
        userLicenseUrl =
            await _uploadImage(widget.userLicenseImage!, 'user_licenses');
      }

      // 3. Prepare Data
      Map<String, dynamic> userData = {
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'englishName': "${widget.firstName} ${widget.lastName}",
        'arabicName': widget.arabicName,
        'jobTitle': widget.jobTitle,
        'phone': widget.phone,
        'birthDate': widget.birthDate,
        'gender': widget.gender,
        'city': widget.city,
        'email': widget.email,
        'uid': user.uid,
        'approvalStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'services_select': widget.serviceType,
        'address': {
          'country': countryController.text,
          'state': stateController.text,
          'district': districtController.text,
          'zip_code': int.tryParse(zipCodeController.text) ?? 0,
          'street_name': streetNameController.text,
          'Building_number': int.tryParse(buildingNumController.text) ?? 0,
          'Floor_number': int.tryParse(floorNumController.text) ?? 0,
          'Apartment_number': int.tryParse(aptNumController.text) ?? 0,
          'Lead_mark': landmarkController.text,
        }
      };

      if (widget.serviceType == "Provider") {
        userData.addAll({
          'provide_catagory': widget.category,
          'working_time': widget.workingTime,
          'deal_with': widget.dealWith,
          'transportation_type': widget.transportationType ?? "None",
          'can_name': widget
              .carName, // Mapped to can_name (car_name in my thoughts, but can_name in code request)
          'car_model': widget.carModel,
          'car_color': widget.carColor,
          'car_number': widget.carNumber,
          'car_liences_number': widget.carLicenseNumber,
          'user_liences_number': widget.userLicenseNumber,
          'photo_car_liences': carLicenseUrl,
          'photo_user_liences': userLicenseUrl,
        });
      } else if (widget.serviceType == "Seeker") {
        userData.addAll({
          'looking_for_category': widget.lookingForCategory,
        });
      }

      // 4. Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData);

      // 5. Send Email Verification
      if (!user.emailVerified) {
        try {
          await user.sendEmailVerification();
        } catch (e) {
          print("Email send error: $e");
        }
      }

      hideLoadingDialog();

      // 6. Navigate
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ApprovalWaitingPage()),
        (route) => false,
      );
    } catch (e) {
      hideLoadingDialog();
      print("Registration Error: $e");
      showErrorDialog("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Address Details')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(countryController, "Country"),
                _buildTextField(stateController, "State"),
                _buildTextField(districtController, "District"),
                _buildTextField(zipCodeController, "Zip Code", isNumber: true),
                _buildTextField(streetNameController, "Street Name"),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            buildingNumController, "Building No",
                            isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildTextField(floorNumController, "Floor No",
                            isNumber: true)),
                  ],
                ),
                _buildTextField(aptNumController, "Apartment No",
                    isNumber: true),
                _buildTextField(landmarkController, "Landmark (Lead Mark)"),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: handleFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text("Finish Registration",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
