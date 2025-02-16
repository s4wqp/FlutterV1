import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tarek_proj/pages/Login.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchServicePage extends StatefulWidget {
  @override
  _SearchServicePageState createState() => _SearchServicePageState();
}

class _SearchServicePageState extends State<SearchServicePage> {
  int _currentImageIndex = 0;
  late Timer _timer;
  Set<String> selectedTimes = {}; // Stores multiple selections
  String? selectedGender; // Stores male, female, or both

  final List<String> sponsorImages = [
    'images/img1.jpeg',
    'images/img2.jpeg',
    'images/img3.jpeg',
    'images/img4.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % sponsorImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          flexibleSpace: AnimatedSwitcher(
            duration: Duration(milliseconds: 800),
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text(
              'Step 4: Provide a Service',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),

            // Working Time Selection
            Text(
              'Choose working time:\n(Note: You can select multiple)',
              style: TextStyle(fontSize: 20, color: CupertinoColors.white),
            ),
            SizedBox(height: 30),
            Wrap(
              spacing: 60,
              children: [
                buildCircleButton("Morning", Icons.wb_sunny),
                buildCircleButton("Afternoon", Icons.wb_twilight),
                buildCircleButton("Night", Icons.nights_stay),
              ],
            ),
            SizedBox(height: 60),

            // Gender Selection
            Text(
              'Who do you want to deal with?',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildGenderButton("Male"),
                SizedBox(width: 20),
                buildGenderButton("Female"),
                SizedBox(width: 20),
                buildGenderButton("Both"),
              ],
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                if (selectedTimes.isEmpty || selectedGender == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select working time and gender")),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchServicePage2(
                      selectedTimes: selectedTimes.toList(),
                      selectedGender: selectedGender!, selectedTime: '',
                    ),
                  ),
                );
              },
              child: Text("Submit"),
            ),
           ],
        ),
      ),
    );
  }

  // Working Time Selection Button
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
          SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // Gender Selection Button
  Widget buildGenderButton(String gender) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedGender = gender;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedGender == gender ? Colors.green : Colors.blueAccent,
      ),
      child: Text(gender, style: TextStyle(color: Colors.white)),
    );
  }
}


// -------------------- SEARCH SERVICE PAGE 2 -------------------- //




class SearchServicePage2 extends StatefulWidget {
  final String selectedTime;

  SearchServicePage2({
    required this.selectedTime,
    required List<String> selectedTimes,
    required String selectedGender,
  });

  @override
  _SearchServicePage2State createState() => _SearchServicePage2State();
}

class _SearchServicePage2State extends State<SearchServicePage2> {
  Position? _currentPosition;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController builderNumberController = TextEditingController();
  final TextEditingController floorNumberController = TextEditingController();
  final TextEditingController apartmentNumberController = TextEditingController();
  final TextEditingController leadMarkController = TextEditingController();

  @override
  void dispose() {
    cityController.dispose();
    areaController.dispose();
    districtController.dispose();
    streetNameController.dispose();
    builderNumberController.dispose();
    floorNumberController.dispose();
    apartmentNumberController.dispose();
    leadMarkController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location is disabled. Please enable it in settings."),
          action: SnackBarAction(
            label: "Open Settings",
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is required.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location permission is permanently denied."),
          action: SnackBarAction(
            label: "Open Settings",
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return;
    }
  }

  Future<void> _getCurrentLocation() async {
    await _checkLocationPermission(); // Ensure permissions before retrieving location

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Location Retrieved: ${position.latitude}, ${position.longitude}",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error retrieving location: $e")),
      );
    }
  }

  void _proceedToNextPage() {
    if (cityController.text.isEmpty ||
        areaController.text.isEmpty ||
        districtController.text.isEmpty ||
        streetNameController.text.isEmpty ||
        builderNumberController.text.isEmpty ||
        floorNumberController.text.isEmpty ||
        apartmentNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all address fields")),
      );
      return;
    }

    final addressDetails = {
      "City": cityController.text,
      "Area": areaController.text,
      "District": districtController.text,
      "Street Name": streetNameController.text,
      "Builder Number": builderNumberController.text,
      "Floor Number": floorNumberController.text,
      "Apartment Number": apartmentNumberController.text,
      "Lead Mark": leadMarkController.text,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchServicePage3(addressDetails: addressDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ad here'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              '2 out of 4',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: Icon(Icons.location_on),
              label: Text("Get Current Location"),
            ),
            SizedBox(height: 20),
            Text(
              _currentPosition != null
                  ? "Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}"
                  : "No location retrieved",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 20),
            ..._buildAddressFields(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _proceedToNextPage,
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAddressFields() {
    final fields = [
      {"label": "City", "controller": cityController, "icon": Icons.location_city},
      {"label": "Area", "controller": areaController, "icon": Icons.map},
      {"label": "District", "controller": districtController, "icon": Icons.apartment},
      {"label": "Street Name", "controller": streetNameController, "icon": Icons.streetview},
      {"label": "Builder Number", "controller": builderNumberController, "icon": Icons.home},
      {"label": "Floor Number", "controller": floorNumberController, "icon": Icons.arrow_upward},
      {"label": "Apartment Number", "controller": apartmentNumberController, "icon": Icons.apartment},
      {"label": "Lead Mark", "controller": leadMarkController, "icon": Icons.label},
    ];

    return fields
        .map(
          (field) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          style: TextStyle(color: Colors.white),
          controller: field["controller"] as TextEditingController,
          decoration: InputDecoration(
            labelText: field["label"] as String,
            labelStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(field["icon"] as IconData),
            prefixIconColor: Colors.blueAccent,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    )
        .toList();
  }
}



// -------------------- SEARCH SERVICE PAGE 3 -------------------- //




class SearchServicePage3 extends StatefulWidget {
  final Map<String, String> addressDetails;

  SearchServicePage3({required this.addressDetails});

  @override
  _SearchServicePage3State createState() => _SearchServicePage3State();
}

class _SearchServicePage3State extends State<SearchServicePage3> {
  String? selectedTransportation;
  final TextEditingController numberOfVehiclesController = TextEditingController();
  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController additionalDetailsController = TextEditingController();

  File? faceImage;
  File? graduationCertificate;
  File? personalIdCard;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    numberOfVehiclesController.dispose();
    vehicleNameController.dispose();
    vehicleColorController.dispose();
    additionalDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String imageType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (imageType == 'Face') {
          faceImage = File(pickedFile.path);
        } else if (imageType == 'Graduation') {
          graduationCertificate = File(pickedFile.path);
        } else if (imageType == 'ID') {
          personalIdCard = File(pickedFile.path);
        }
      });
    }
  }

  void _submitTransportationDetails() {
    if (faceImage == null || graduationCertificate == null || personalIdCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload all required images')),
      );
      return;
    }

    if (selectedTransportation != "None") {
      if (numberOfVehiclesController.text.isEmpty ||
          vehicleNameController.text.isEmpty ||
          vehicleColorController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all vehicle details')),
        );
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VerifyEmailPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transportation Details'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Text(
                'Select Transportation Type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              DropdownButton<String>(
                dropdownColor: Colors.indigo,
                value: selectedTransportation,
                hint: Text('Choose Transportation', style: TextStyle(color: Colors.white)),
                style: TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => selectedTransportation = value),
                items: ['Bike', 'Car', 'Scooter', 'None']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),

              if (selectedTransportation != null && selectedTransportation != 'None') ...[
                _buildTextField(numberOfVehiclesController, 'Number of Vehicles', Icons.format_list_numbered),
                _buildTextField(vehicleNameController, 'Vehicle Name', Icons.directions_car),
                _buildTextField(vehicleColorController, 'Vehicle Color', Icons.color_lens),
                _buildTextField(additionalDetailsController, 'Additional Details (Optional)', Icons.info, maxLines: 3),
              ],

              SizedBox(height: 20),
              _buildImageUploadSection('Face Image', faceImage, 'Face'),
              _buildImageUploadSection('Graduation Certificate', graduationCertificate, 'Graduation'),
              _buildImageUploadSection('Personal ID Card', personalIdCard, 'ID'),

              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitTransportationDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
        ),
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildImageUploadSection(String label, File? imageFile, String imageType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(imageType),
                  icon: Icon(Icons.upload),
                  label: Text("Upload"),
                ),
                if (imageFile != null) SizedBox(width: 10),
                if (imageFile != null) Image.file(imageFile, width: 80, height: 80, fit: BoxFit.cover),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    checkEmailVerification();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerification();
    });
  }

  Future<void> checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      setState(() => isEmailVerified = true);
      timer?.cancel();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Verify Email')), body: Center(child: Text("Check your email!")));
  }
}



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page'), centerTitle: true),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigoAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Welcome!",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? "User",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.blue),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login page
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to the Home Page!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
