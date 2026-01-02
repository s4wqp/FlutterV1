import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:tarek_proj/data/web_services/web_services.dart';
import 'package:tarek_proj/presentation/screens/auth/approval_waiting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProvideServices4 extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const ProvideServices4({super.key, required this.registrationData});

  @override
  _ProvideServices4State createState() => _ProvideServices4State();
}

class _ProvideServices4State extends State<ProvideServices4> {
  final TextEditingController additionalDetailsController =
      TextEditingController();
  final TextEditingController certificationNameController =
      TextEditingController();
  final TextEditingController idNumberController = TextEditingController();

  File? faceImage;
  File? graduationCertificate;
  File? personalIdCardFront;
  File? personalIdCardBack;
  String? extractedIDNumber;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    additionalDetailsController.dispose();
    certificationNameController.dispose();
    idNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String imageType, {bool cameraOnly = false}) async {
    if (cameraOnly) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      _setImage(imageType, pickedFile);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(15),
        height: 160,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                _setImage(imageType, pickedFile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                _setImage(imageType, pickedFile);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setImage(String imageType, XFile? pickedFile) async {
    if (pickedFile != null) {
      setState(() {
        File image = File(pickedFile.path);
        if (imageType == 'Face') {
          faceImage = image;
        } else if (imageType == 'Graduation') {
          graduationCertificate = image;
        } else if (imageType == 'ID_Front') {
          personalIdCardFront = image;
          _scanText(image); // Scan ID card text
        } else if (imageType == 'ID_Back') {
          personalIdCardBack = image;
        }
      });
    }
  }

  Future<void> _scanText(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFile(imageFile);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // Normalize text: Convert Eastern Arabic Numerals to Western
    String fullText = recognizedText.text;
    fullText = fullText
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9');

    print("OCR Normalized Text: $fullText");

    String? foundID;

    // Strategy 1: strict contiguous 14 digits
    final strictMatch = RegExp(r'\b\d{14}\b').firstMatch(fullText);
    if (strictMatch != null) {
      foundID = strictMatch.group(0);
    } else {
      // Strategy 2: Loose match (digits with spaces/newlines)
      // Look for any sequence of 14 digits possibly interrupted by whitespace
      // We explicitly look for a pattern that spans lines or spaces
      // Removing all non-digits from the text and finding a 14-digit block is risky if there are other numbers
      // But for IDs, usually the long number is the ID.

      // Let's try to find all numbers, join them, and look for 14 digits?
      // Or better: regex that allows spaces
      final looseMatches = RegExp(r'\d[\d\s\n-]{12,}\d').allMatches(fullText);

      for (final match in looseMatches) {
        final raw = match.group(0)!;
        final clean = raw.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
        if (clean.length == 14) {
          foundID = clean;
          break;
        }
      }
    }

    setState(() => extractedIDNumber =
        foundID ?? "No ID Number Found (Try improved lighting)");

    textRecognizer.close();
  }

  void _removeImage(String imageType) {
    setState(() {
      if (imageType == 'Face') {
        faceImage = null;
      } else if (imageType == 'Graduation') {
        graduationCertificate = null;
      } else if (imageType == 'ID_Front') {
        personalIdCardFront = null;
        extractedIDNumber = null;
      } else if (imageType == 'ID_Back') {
        personalIdCardBack = null;
      }
    });
  }

  Future<void> _submitAllDetails() async {
    // Basic Validation
    if (faceImage == null ||
        graduationCertificate == null ||
        personalIdCardFront == null ||
        personalIdCardBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required images')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare Data for API
      final regData = widget.registrationData;

      // Helper to map Gender/DealWith to Int
      int mapGenderToInt(String? value) {
        if (value == null) return 1;
        String v = value.toLowerCase();
        if (v == 'male') return 1;
        if (v == 'female') return 2;
        return 1;
      }

      // Helper for Transportation
      int mapTransportationToInt(String? value) {
        if (value == null) return 0;
        String v = value.toLowerCase();
        if (v == 'car') return 1;
        if (v == 'motorbike') return 2;
        if (v == 'bike') return 3;
        if (v == 'none') return 0;
        return 0;
      }

      // Helper for Date Formatting (d/M/yyyy -> yyyy-MM-dd)
      String formatDateForApi(String? date) {
        if (date == null || date.isEmpty) return "";
        try {
          List<String> parts = date.split('/');
          if (parts.length == 3) {
            String day = parts[0].padLeft(2, '0');
            String month = parts[1].padLeft(2, '0');
            String year = parts[2];
            return "$year-$month-$day";
          }
          return date;
        } catch (e) {
          return date;
        }
      }

      // Updated Helper for Category Mapping
      int mapCategoryToInt(String? category, bool isProvider) {
        if (category == null) return isProvider ? 201 : 101;
        String firstCat = category.split(',')[0].trim();

        // 1-Ask assistant ,2-Provide Assistant ,3-both.
        // Seeker (1xx)
        if (!isProvider) {
          if (firstCat.contains("Ride") || firstCat.contains("Motorbike"))
            return 101;
          if (firstCat.contains("Car Driver")) return 102;
          if (firstCat.contains("Companion") || firstCat.contains("Elderly"))
            return 103;
          if (firstCat.contains("Cleaning"))
            return 106; // Using 106 for Clean Home to match 206
          if (firstCat.contains("Teacher") || firstCat.contains("Tutor"))
            return 104;
          return 101; // Default
        }
        // Provider (2xx)
        else {
          if (firstCat.contains("Car Driver") || firstCat.contains("Ride"))
            return 201;
          if (firstCat.contains("Companion") || firstCat.contains("Elderly"))
            return 202;
          if (firstCat.contains("Babysitter")) return 203;
          if (firstCat.contains("Nursing")) return 204;
          if (firstCat.contains("Physical Therapy")) return 205;
          if (firstCat.contains("Cleaning")) return 206;
          if (firstCat.contains("Teacher") || firstCat.contains("Tutor"))
            return 208;
          return 201; // Default
        }
      }

      // Helper for Working Time Mapping
      // 1 morning 2 afternoon 3 evening 4 night 5 all
      int mapWorkingTimeToInt(dynamic times) {
        if (times == null) return 5; // Default All?
        List<String> timeList = [];
        if (times is List) {
          timeList = times.map((e) => e.toString()).toList();
        } else if (times is String) {
          timeList = [times];
        }

        if (timeList.isEmpty) return 5;
        // If multiple selected, maybe return 5 (All)? Or just map the first one?
        // Let's check for 'All' or specific combinations?
        // Simple 1-to-1 mapping for now based on first selection
        String first = timeList.first.toLowerCase();
        if (first == 'morning') return 1;
        if (first == 'afternoon') return 2;
        if (first == 'evening') return 3;
        if (first == 'night') return 4;
        if (first == 'all') return 5;

        // Dynamic fallback logic
        if (timeList.length > 2) return 5; // Assume All if many

        return 5;
      }

      // Helper for Firm ID
      int mapFirmId(String? serviceType) {
        // firm_id make it ststic number 1
        return 1;
      }

      // Helper for User Type ID
      // 1-Ask assistant ,2-Provide Assistant ,3-both
      int mapUserTypeId(String? serviceType) {
        if (serviceType == 'Seeker') return 1;
        if (serviceType == 'Provider') return 2;
        return 3; // Both
      }

      // Map App fields to API fields
      Map<String, dynamic> apiData = {
        // IDs
        'firm_id': mapFirmId(regData['serviceType']),
        'u_type_id': mapUserTypeId(regData['serviceType']),
        'cat_id': mapCategoryToInt(
            regData['provide_catagory'] ?? regData['looking_for_category'],
            regData['serviceType'] == 'Provider'),
        'wt_id': mapWorkingTimeToInt(regData['working_time']),

        // User Info
        'user_f_name': regData['firstName'],
        'user_l_name': regData['lastName'],
        'user_ar_name': regData['arabicName'],
        'user_email': regData['email'],
        'user_password': regData['password'],
        'user_tel_no': regData['phone'],
        'birth_date': formatDateForApi(regData['birthDate']),
        'Gender': mapGenderToInt(regData['gender']),
        'job': regData['jobTitle'],
        'statu': 1, // 1 bending - 2 approval - 3 reject

        // Address Info
        'country': 'Egypt',
        'state': regData['city'],
        // 'city': regData['city'], // Removed as per new JSON which only has 'state', 'district' etc. Wait, JSON has 'state' and 'district', but no 'city' key in JSON example. It has 'state'.
        // Actually JSON has: country, state, district, zip_code, street_name, Building_number, Floor_number, Apartment_number, Lead_mark
        // Existing code had 'city': regData['city'], which might be extra. I will keep 'state' as city.

        'district': regData['district'],
        'zip_code': regData['zip_code'],
        'street_name': regData['street_name'],
        'Building_number': regData['builder_number'],
        'Floor_number': regData['floor_number'],
        'Apartment_number': regData['apartment_number'],

        // Truncate Lead_mark
        'Lead_mark': (regData['special_marque'] != null &&
                regData['special_marque'].toString().length > 20)
            ? regData['special_marque'].toString().substring(0, 20)
            : regData['special_marque'],

        // Missing fields from JSON
        'user_helth_note': null,
        'user_dr_name': null,
        'user_dr_tel_no': null,
        'user_cer': certificationNameController.text.isNotEmpty
            ? certificationNameController.text
            : null,
        'user_Reg_no': null,
        'creation_date': DateTime.now().toIso8601String(),
        'modification_Date': DateTime.now().toIso8601String(),

        // Provider specific
        'deal_with': mapGenderToInt(regData['deal_with_gender']),
        'transportation_type':
            mapTransportationToInt(regData['transportation_type']),
        'user_comment': additionalDetailsController.text,
        'user_DL': regData['user_license_number'],
        'user_car_no': regData['vehicle_number'],
        'user_CL': regData['car_license_number'],
        'user_car_color': regData['vehicle_color'], // Added

        // ID Number
        'user_id': (idNumberController.text.isNotEmpty &&
                RegExp(r'^\d+$').hasMatch(idNumberController.text))
            ? idNumberController.text
            : null,
      };

      // Prepare Files
      Map<String, File> apiFiles = {
        'user_photo': faceImage!,
        'user_cer_photo': graduationCertificate!,
        'user_id_photo': personalIdCardFront!,
        'user_DL_photo':
            personalIdCardBack!, // Is this User License or ID Back? Mapped per existing code.
      };

      if (regData['carPhoto'] != null) {
        apiFiles['user_car_photo'] = regData['carPhoto'];
      }
      if (regData['carLicenseImage'] != null) {
        apiFiles['user_CL_photo'] = regData['carLicenseImage'];
      }
      if (regData['userLicenseImage'] != null) {
        // Maybe user_DL_Photo should be this?
        // But existing code mapped 'personalIdCardBack' to 'user_DL_Photo'.
        // Let's keep existing and add new if needed, OR fix.
        // Request says: 8- user_CL_Photo VARCHAR(40), /car licence photo/
        // Request says: 6- user_car_photo VARCHAR(40), /car photo/
        // Request says: 7- user_CL VARCHAR(20), /car licence No/ (Added above)
        // Request says: 9- user_car_no VARCHAR(20)/ car Number (Added above)

        // Assuming 'user_DL_Photo' in existing code was actually "Driver License" (User License)?
        // But it was assigned `personalIdCardBack` (ID Back).
        // The prompt didn't ask to change `user_DL_Photo` logic, but asked to ADD fields.
        // NOTE: `user_CL` -> Car License. `user_CL_Photo` -> Car License Photo.
        // I'll stick to the requested fields.
      }

      // Call API
      // Call API
      print(
          "DEBUG: Preparing to send files with keys: ${apiFiles.keys.toList()}");
      print("DEBUG: apiData payload: $apiData");

      Response response = await WebServices().registerUser(apiData, apiFiles);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Custom API Success - Now Create Firebase Account
        try {
          // 1. Create User in Firebase Auth
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: regData['email'],
            password: regData['password'],
          );

          // 2. Determine Service Type & Status
          String serviceType = regData['serviceType'] ?? 'Seeker';
          bool isProvider = serviceType == 'Provider';
          bool isSeeker = serviceType == 'Seeker';

          // 3. Save to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'firstName': regData['firstName'],
            'lastName': regData['lastName'],
            'email': regData['email'],
            'phone': regData['phone'],
            'arabicName': regData['arabicName'],
            'serviceType': serviceType,
            'isProvider': isProvider,
            'isSeeker': isSeeker,
            'approvalStatus': 'pending',
            'city': regData['city'],
            'u_type_id': (serviceType == 'Provider') ? 1 : 2,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // 4. Navigate
          if (mounted) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const ApprovalWaitingPage()),
              (route) => false,
            );
          }
        } on FirebaseAuthException catch (e) {
          throw Exception("Firebase Auth Error: ${e.message}");
        } catch (e) {
          throw Exception("Firestore Error: $e");
        }
      } else {
        throw Exception(
            "API Error: ${response.statusCode} - ${response.statusMessage}");
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        String errorMessage = "Connection failed";
        if (e.response != null) {
          String dataString = e.response?.data.toString() ?? "";
          if (dataString.contains("Data too long") &&
              dataString.contains("user_password")) {
            errorMessage =
                "Registration Failed: Password is too long. Please use a password between 8 and 10 characters.";
          } else {
            errorMessage =
                "Server Error ${e.response?.statusCode}: $dataString";
          }
        } else {
          errorMessage = e.message ?? "Unknown error";
        }
        print("Registration Error Details: ${e.response?.data}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 5)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isProvider = widget.registrationData['serviceType'] == 'Provider';

    return Scaffold(
      appBar: AppBar(title: const Text('Document Upload'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      isProvider
                          ? 'Step 4 of 4: Verification'
                          : 'Step 4 of 4: Verification',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Upload Required Documents',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // Certificate Image Upload
                    _buildDocumentUploadSection(
                      title: "1. Certificate Image",
                      description:
                          "Upload a clear photo of your graduation certificate",
                      image: graduationCertificate,
                      imageType: 'Graduation',
                    ),

                    // Certification Name Input
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: certificationNameController,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText:
                              "Certification Name (e.g. Bachelor of Science)",
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          prefixIcon:
                              const Icon(Icons.school, color: Colors.white),
                        ),
                      ),
                    ),

                    // Face Image Upload
                    _buildDocumentUploadSection(
                      title: "2. Face Image",
                      description:
                          "Take a photo of your face (no uploads from gallery)",
                      image: faceImage,
                      imageType: 'Face',
                      cameraOnly: true,
                    ),

                    // ID Card Front Upload
                    _buildDocumentUploadSection(
                      title: "3. ID Card Front",
                      description: "Upload the front side of your ID card",
                      image: personalIdCardFront,
                      imageType: 'ID_Front',
                    ),

                    // ID Card Back Upload
                    _buildDocumentUploadSection(
                      title: "4. ID Card Back",
                      description: "Upload the back side of your ID card",
                      image: personalIdCardBack,
                      imageType: 'ID_Back',
                    ),

                    // Manual ID Input Field (Always detected or manual)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: idNumberController,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "National ID Number (14 Digits)",
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          prefixIcon:
                              const Icon(Icons.badge, color: Colors.white),
                        ),
                      ),
                    ),

                    if (isProvider) ...[
                      const SizedBox(height: 20),
                      const Text(
                        "Additional Details (Optional)",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: additionalDetailsController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: "Any other details...",
                          hintStyle: const TextStyle(color: Colors.white60),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitAllDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Submit & Create Account',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadSection({
    required String title,
    required String description,
    required File? image,
    required String imageType,
    bool cameraOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () => _pickImage(imageType, cameraOnly: cameraOnly),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  image: image != null
                      ? DecorationImage(
                          image: FileImage(image), fit: BoxFit.cover)
                      : null,
                ),
                child: image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                          Text("Upload", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            if (image != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeImage(imageType),
              ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
