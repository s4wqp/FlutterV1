import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:tarek_proj/presentation/screens/auth/approval_waiting.dart';

class ProvideServices4 extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const ProvideServices4({super.key, required this.registrationData});

  @override
  _ProvideServices4State createState() => _ProvideServices4State();
}

class _ProvideServices4State extends State<ProvideServices4> {
  final TextEditingController additionalDetailsController =
      TextEditingController();

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

    print("OCR Recognized Text: ${recognizedText.text}"); // Debug print

    String? foundID;

    // Strategy 1: strict contiguous 14 digits
    final strictMatch = RegExp(r'\b\d{14}\b').firstMatch(recognizedText.text);
    if (strictMatch != null) {
      foundID = strictMatch.group(0);
    } else {
      // Strategy 2: Loose match (digits with spaces)
      // Capture sequences that look like numbers (digits + spaces)
      // We look for a chunk that starts with a digit, has digits/spaces, and ends with a digit.
      // We limit the search to chunks that could plausibly be IDs.
      final looseMatches = RegExp(r'(?<!\d)\d[\d\s]{12,}\d(?!\d)')
          .allMatches(recognizedText.text);

      for (final match in looseMatches) {
        final raw = match.group(0)!;
        // Clean: remove all spaces
        final clean = raw.replaceAll(RegExp(r'\s+'), '');
        // Validate: must be exactly 14 digits
        if (clean.length == 14) {
          foundID = clean;
          break; // Found it
        }
      }
    }

    setState(() => extractedIDNumber = foundID ?? "No ID Number Found");

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

  Future<String?> _uploadImage(File image, String folderName) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      final path = '$folderName/$fileName';

      // Upload to Supabase Storage bucket 'provider-documents'
      await Supabase.instance.client.storage
          .from('provider-documents')
          .upload(path, image);

      // Get the public URL
      final imageUrl = Supabase.instance.client.storage
          .from('provider-documents')
          .getPublicUrl(path);

      return imageUrl;
    } catch (e) {
      print("Error uploading image to Supabase: $e");
      return null;
    }
  }

  Future<void> _submitAllDetails() async {
    // Basic Validation
    // Require Face and ID Front/Back for everyone. Cert optional? Let's require it for now.
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
      // 1. Create User in Firebase Auth (or use existing)
      final String email = widget.registrationData['email'];
      final String password = widget.registrationData['password'];

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Create user if not already logged in (e.g., if SignUp didn't create it)
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = userCredential.user;
      }

      if (user == null) throw Exception("User creation failed");

      // 2. Upload Images (Current Step)
      String? faceUrl = await _uploadImage(faceImage!, 'face_images');
      String? certUrl =
          await _uploadImage(graduationCertificate!, 'certificates');
      String? idFrontUrl =
          await _uploadImage(personalIdCardFront!, 'id_cards_front');
      String? idBackUrl =
          await _uploadImage(personalIdCardBack!, 'id_cards_back');

      // 3. Upload Vehicle Images (if Provider and exist)
      String? carLicenseUrl;
      String? userLicenseUrl;

      if (widget.registrationData['carLicenseImage'] != null) {
        carLicenseUrl = await _uploadImage(
            widget.registrationData['carLicenseImage'], 'car_licenses');
      }
      if (widget.registrationData['userLicenseImage'] != null) {
        userLicenseUrl = await _uploadImage(
            widget.registrationData['userLicenseImage'], 'user_licenses');
      }

      // 4. Prepare Data for Firestore
      Map<String, dynamic> userData = {
        'uid': user.uid,
        'firstName': widget.registrationData['firstName'],
        'lastName': widget.registrationData['lastName'],
        'arabicName': widget.registrationData['arabicName'],
        'jobTitle': widget.registrationData['jobTitle'],
        'phone': widget.registrationData['phone'],
        'birthDate': widget.registrationData['birthDate'],
        'gender': widget.registrationData['gender'],
        'city': widget.registrationData['city'], // user profile city
        'serviceType': widget.registrationData['serviceType'],
        'isProvider': widget.registrationData['serviceType'] == 'Provider' ||
            widget.registrationData['serviceType'] == 'Both',
        'isSeeker': widget.registrationData['serviceType'] == 'Seeker' ||
            widget.registrationData['serviceType'] == 'Both',
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false, // Email verification status
        'approvalStatus': 'pending', // Initial status

        // Address details (from Step 3)
        'addressDetails': {
          'city': widget.registrationData['city'], // Address city
          'zip_code': widget.registrationData['zip_code'],
          'district': widget.registrationData['district'],
          'street_name': widget.registrationData['street_name'],
          'builder_number': widget.registrationData['builder_number'],
          'floor_number': widget.registrationData['floor_number'],
          'apartment_number': widget.registrationData['apartment_number'],
          'special_marque': widget.registrationData['special_marque'],
        },

        // Verification Docs
        'verificationDocuments': {
          'faceImageUrl': faceUrl,
          'certificateImageUrl': certUrl,
          'idCardFrontUrl': idFrontUrl,
          'idCardBackUrl': idBackUrl,
          'extractedIDNumber': extractedIDNumber,
          // Vehicle Licenses (if applicable)
          if (carLicenseUrl != null) 'carLicenseUrl': carLicenseUrl,
          if (userLicenseUrl != null) 'userLicenseUrl': userLicenseUrl,
        }
      };

      if (widget.registrationData['serviceType'] == 'Provider') {
        userData['providerDetails'] = {
          'provide_catagory': widget.registrationData['provide_catagory'],
          'working_time': widget.registrationData['working_time'],
          'deal_with_gender': widget.registrationData['deal_with_gender'],
          'transportation_type': widget.registrationData['transportation_type'],
          // Vehicle info if applicable
          'vehicle_name': widget.registrationData['vehicle_name'],
          'vehicle_model_year': widget.registrationData['vehicle_model_year'],
          'vehicle_color': widget.registrationData['vehicle_color'],
          'vehicle_number': widget.registrationData['vehicle_number'],
          'car_license_number': widget.registrationData['car_license_number'],
          'user_license_number': widget.registrationData['user_license_number'],
          'carLicenseUrl': carLicenseUrl,
          'userLicenseUrl': userLicenseUrl,
          'additionalDetails': additionalDetailsController.text,
        };
      } else {
        userData['seekerDetails'] = {
          'looking_for_category':
              widget.registrationData['looking_for_category'],
        };
      }

      // 5. Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData);

      // 6. Send Email Verification
      await user.sendEmailVerification();

      if (mounted) {
        Navigator.pop(context); // Maybe clear history?
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ApprovalWaitingPage()),
          (route) => false,
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

                    if (extractedIDNumber != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Extracted ID Number: $extractedIDNumber",
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
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
