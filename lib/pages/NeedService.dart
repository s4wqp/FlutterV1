import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'SearchService.dart';

class NeedServicePage extends StatefulWidget {
  @override
  _NeedServicePageState createState() => _NeedServicePageState();
}

class _NeedServicePageState extends State<NeedServicePage> {
  List<String> serviceOptions = [
    "Need Rider",
    "Ask Driver My car",
    "Ask clean home",
    "Ask clean Farm",
    "Ask Teacher",
    "Ask companion",
    "Baby sitter",
    "Provide nursing",
    "Provide physical therapy",
    "Other"
  ];

  Set<String> selectedServices = {};
  TextEditingController otherServiceController = TextEditingController();
  bool isOtherSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Service"),
        centerTitle: true,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Step 2: Choose a Service',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select the type of service you need:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: serviceOptions.length,
                  itemBuilder: (context, index) {
                    String option = serviceOptions[index];
                    bool isSelected = selectedServices.contains(option);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (option == "Other") {
                            isOtherSelected = !isOtherSelected;
                            if (!isOtherSelected) {
                              otherServiceController.clear();
                              selectedServices.removeWhere((service) =>
                                  serviceOptions.contains(service));
                            }
                          } else {
                            if (isSelected) {
                              selectedServices.remove(option);
                            } else {
                              selectedServices.add(option);
                            }
                          }
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected || (option == "Other" && isOtherSelected)
                              ? Colors.indigo
                              : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (isOtherSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextField(
                    controller: otherServiceController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter your custom service",
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 20),

              /// **Submit Button**
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (isOtherSelected && otherServiceController.text.isNotEmpty) {
                      selectedServices.add(otherServiceController.text);
                    }

                    if (selectedServices.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please select at least one service."),
                        ),
                      );
                      return;
                    }

                    print("Selected Services: $selectedServices");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProvideServicesPage2(selectedTime: '', selectedTimes: [], selectedGender: '',),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProvideServicesPage2 extends StatefulWidget {
  final String selectedTime;

  ProvideServicesPage2({
    required this.selectedTime,
    required List<String> selectedTimes,
    required String selectedGender,
  });

  @override
  _ProvideServicesPage2State createState() => _ProvideServicesPage2State();
}

class _ProvideServicesPage2State extends State<ProvideServicesPage2> {
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
        builder: (context) => ProvideServicesPage3(),
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
              '2 out of 3',
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


class ProvideServicesPage3 extends StatefulWidget {
  const ProvideServicesPage3({Key? key}) : super(key: key);

  @override
  _ProvideServicesPage3State createState() => _ProvideServicesPage3State();
}

class _ProvideServicesPage3State extends State<ProvideServicesPage3> {
  String? selectedTransportation;
  final TextEditingController numberOfVehiclesController = TextEditingController();
  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController additionalDetailsController = TextEditingController();

  File? faceImage, graduationCertificate, personalIdCard;
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(15),
        height: 160,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                _setImage(imageType, pickedFile);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                _setImage(imageType, pickedFile);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setImage(String imageType, XFile? pickedFile) {
    if (pickedFile != null) {
      setState(() {
        File image = File(pickedFile.path);
        if (imageType == 'Face') {
          faceImage = image;
        } else if (imageType == 'Graduation') {
          graduationCertificate = image;
        } else if (imageType == 'ID') {
          personalIdCard = image;
        }
      });
    }
  }

  void _removeImage(String imageType) {
    setState(() {
      if (imageType == 'Face') {
        faceImage = null;
      } else if (imageType == 'Graduation') {
        graduationCertificate = null;
      } else if (imageType == 'ID') {
        personalIdCard = null;
      }
    });
  }

  void _submitTransportationDetails() {
    if (faceImage == null || graduationCertificate == null || personalIdCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload all required images')),
      );
      return;
    }

    if (selectedTransportation != null && selectedTransportation != "None") {
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
      appBar: AppBar(title: Text('Ad here'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              SizedBox(height: 20,),
              Text(
                '3 out of 3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40,),
              Text(
                'Select Transportation Type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.indigo,
                value: selectedTransportation,
                hint: Text('Choose Transportation', style: TextStyle(color: Colors.white)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blueGrey.withOpacity(0.2),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                ),
                onChanged: (value) => setState(() => selectedTransportation = value),
                items: ['Bike', 'Car', 'Scooter', 'None']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: Colors.white))))
                    .toList(),
              ),

              if (selectedTransportation != null && selectedTransportation != 'None') ...[
                _buildTextField(numberOfVehiclesController, 'Number of Vehicles', Icons.format_list_numbered),
                _buildTextField(vehicleNameController, 'Vehicle Name', Icons.directions_car),
                _buildTextField(vehicleColorController, 'Vehicle Color', Icons.color_lens),
                _buildTextField(additionalDetailsController, 'Additional Details (Optional)', Icons.info, maxLines: 3),
              ],

              SizedBox(height: 40),
              Text('Upload these important images\n1- Your Face\n2- Graduation Certificate\n3- Personal ID Card',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageUploadSection('Face Image', faceImage, 'Face'),
                  _buildImageUploadSection('Graduation Certificate', graduationCertificate, 'Graduation'),
                  _buildImageUploadSection('Personal ID Card', personalIdCard, 'ID'),
                ],
              ),

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
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(imageType),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              image: imageFile != null
                  ? DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover)
                  : null,
            ),
            child: imageFile == null
                ? Icon(Icons.add_a_photo, color: Colors.grey, size: 40)
                : null,
          ),
        ),
        if (imageFile != null)
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeImage(imageType),
          ),
      ],
    );
  }
}