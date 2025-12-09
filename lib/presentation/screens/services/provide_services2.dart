import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tarek_proj/presentation/screens/services/provide_services3.dart';

class ProvideServices2 extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const ProvideServices2({super.key, required this.registrationData});

  @override
  _ProvideServices2State createState() => _ProvideServices2State();
}

class _ProvideServices2State extends State<ProvideServices2> {
  int _currentImageIndex = 0;
  late Timer _timer;
  Set<String> selectedTimes = {};
  String? selectedGender;
  String? selectedTransportation;
  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();

  // New Controllers and Variables
  final TextEditingController carLicenseController = TextEditingController();
  final TextEditingController userLicenseController = TextEditingController();
  String? selectedCarModelYear;
  File? carLicenseImage;
  File? userLicenseImage;
  final ImagePicker _picker = ImagePicker();

  // Generate years list (e.g., 1980 current year + 1)
  final List<String> carModelYears = List.generate(
          DateTime.now().year - 1980 + 2, (index) => (1980 + index).toString())
      .reversed
      .toList();

  final List<String> sponsorImages = [
    'images/img1.jpeg',
    'images/img2.jpeg',
    'images/img3.jpeg',
    'images/img4.png',
  ];

  final List<String> transportationOptions = [
    'None',
    'Car',
    'Motorbike',
    'Bike'
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % sponsorImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    vehicleNameController.dispose();
    vehicleColorController.dispose();
    vehicleNumberController.dispose();
    carLicenseController.dispose();
    userLicenseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _processImage(ImageSource.camera, type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _processImage(ImageSource.gallery, type);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(ImageSource source, String type) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    File file = File(image.path);
    setState(() {
      if (type == 'car') {
        carLicenseImage = file;
      } else {
        userLicenseImage = file;
      }
    });

    // Process OCR
    final inputImage = InputImage.fromFile(file);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    print("--- Extracted Data for $type License ---");
    _extractAndPrintData(recognizedText.text);
    print("----------------------------------------");

    textRecognizer.close();
  }

  void _extractAndPrintData(String text) {
    // Basic heuristics for extraction
    // ID: Look for 14 digits (Egypt national ID format)
    final idRegex = RegExp(r'\b\d{14}\b');
    final idMatch = idRegex.firstMatch(text);
    if (idMatch != null) {
      print("ID: ${idMatch.group(0)}");
    } else {
      print("ID: Not Found");
    }

    // Dates: Look for dd/mm/yyyy or yyyy/mm/dd
    final dateRegex = RegExp(r'\b\d{2,4}[/-]\d{2}[/-]\d{2,4}\b');
    final dates = dateRegex.allMatches(text);

    // Sort logic could be complex (which is creation vs end),
    // for now just printing all found dates.
    // Usually creation date is earlier than end date.
    List<String> foundDates = dates.map((m) => m.group(0)!).toList();

    if (foundDates.isNotEmpty) {
      // Attempt to parse and sort to guess which is which
      print("Found Dates: $foundDates");
      // A simple heuristic: earliest is creation, latest is end?
      // This depends heavily on the license format.
    } else {
      print("Dates: Not Found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          flexibleSpace: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: Container(
              key: ValueKey<int>(_currentImageIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(sponsorImages[_currentImageIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black87,
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Step 2-2: Working State',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Working Time Selection
              const Text(
                'Choose working time:\n(Note: You can select multiple)',
                style: TextStyle(fontSize: 18, color: CupertinoColors.white),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 60,
                children: [
                  buildCircleButton("Morning", Icons.wb_sunny),
                  buildCircleButton("Afternoon", Icons.wb_twilight),
                  buildCircleButton("Night", Icons.nights_stay),
                ],
              ),
              const SizedBox(height: 40),

              // Gender Selection
              const Text(
                'Who do you want to deal with?',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildGenderButton("Male"),
                  const SizedBox(width: 20),
                  buildGenderButton("Female"),
                  const SizedBox(width: 20),
                  buildGenderButton("NeverMind"),
                ],
              ),
              const SizedBox(height: 40),

              // Transportation Selection
              const Text(
                'Do you have transportation?',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: transportationOptions.map((option) {
                  return ChoiceChip(
                    label: Text(option),
                    selected: selectedTransportation == option,
                    onSelected: (selected) {
                      setState(() {
                        selectedTransportation = selected ? option : null;
                        if (!selected) {
                          vehicleNameController.clear();
                          vehicleColorController.clear();
                          vehicleNumberController.clear();
                        }
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: selectedTransportation == option
                          ? Colors.white
                          : Colors.white,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Vehicle Details (only shown for Car or Motorbike)
              if (selectedTransportation == 'Car' ||
                  selectedTransportation == 'Motorbike')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Details',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Vehicle Name
                    TextField(
                      controller: vehicleNameController,
                      decoration: InputDecoration(
                        labelText: '${selectedTransportation} Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    // Vehicle Model (Year Dropdown)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCarModelYear,
                          hint: Text(
                            'Select ${selectedTransportation} Model Year',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          dropdownColor: Colors.grey[800],
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          isExpanded: true,
                          items: carModelYears.map((String year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text(year,
                                  style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedCarModelYear = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: vehicleColorController,
                      decoration: InputDecoration(
                        labelText: '${selectedTransportation} Color',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: vehicleNumberController,
                      decoration: InputDecoration(
                        labelText: '${selectedTransportation} Number',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'License Details',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Car License Text
                    TextField(
                      controller: carLicenseController,
                      decoration: const InputDecoration(
                        labelText: 'Car License Number',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    // User License Text
                    TextField(
                      controller: userLicenseController,
                      decoration: const InputDecoration(
                        labelText: 'User License Number',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // Image Pickers
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text("Car License Image",
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => _pickImage('car'),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: carLicenseImage != null
                                      ? Image.file(carLicenseImage!,
                                          fit: BoxFit.cover)
                                      : const Icon(Icons.camera_alt,
                                          color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              const Text("User License Image",
                                  style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => _pickImage('user'),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: userLicenseImage != null
                                      ? Image.file(userLicenseImage!,
                                          fit: BoxFit.cover)
                                      : const Icon(Icons.camera_alt,
                                          color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedTimes.isEmpty || selectedGender == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Please select working time and gender")),
                      );
                      return;
                    }

                    if ((selectedTransportation == 'Car' ||
                            selectedTransportation == 'Motorbike') &&
                        (vehicleNameController.text.isEmpty ||
                            selectedCarModelYear == null ||
                            vehicleColorController.text.isEmpty ||
                            vehicleNumberController.text.isEmpty ||
                            carLicenseController.text.isEmpty ||
                            userLicenseController.text.isEmpty ||
                            carLicenseImage == null ||
                            userLicenseImage == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Please fill all vehicle and license details")),
                      );
                      return;
                    }

                    // Update registration data
                    widget.registrationData['working_time'] =
                        selectedTimes.toList();
                    widget.registrationData['deal_with_gender'] =
                        selectedGender;
                    widget.registrationData['transportation_type'] =
                        selectedTransportation;

                    if (selectedTransportation == 'Car' ||
                        selectedTransportation == 'Motorbike') {
                      widget.registrationData['vehicle_name'] =
                          vehicleNameController.text;
                      widget.registrationData['vehicle_model_year'] =
                          selectedCarModelYear;
                      widget.registrationData['vehicle_color'] =
                          vehicleColorController.text;
                      widget.registrationData['vehicle_number'] =
                          vehicleNumberController.text;
                      widget.registrationData['car_license_number'] =
                          carLicenseController.text;
                      widget.registrationData['user_license_number'] =
                          userLicenseController.text;

                      // Images
                      widget.registrationData['carLicenseImage'] =
                          carLicenseImage;
                      widget.registrationData['userLicenseImage'] =
                          userLicenseImage;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProvideServices3(
                          registrationData: widget.registrationData,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCircleButton(String text, IconData icon) {
    bool isSelected = selectedTimes.contains(text);
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected ? selectedTimes.remove(text) : selectedTimes.add(text);
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isSelected ? Colors.green : Colors.blueAccent,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget buildGenderButton(String gender) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedGender = gender;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedGender == gender ? Colors.green : Colors.blueAccent,
      ),
      child: Text(gender, style: const TextStyle(color: Colors.white)),
    );
  }
}
