import 'dart:io';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tarek_proj/presentation/screens/services/provide_services4.dart';

class ProvideServices3 extends StatefulWidget {
  final String selectedTime;
  final List<String> selectedTimes;
  final String selectedGender;

  const ProvideServices3({
    super.key,
    required this.selectedTime,
    required this.selectedTimes,
    required this.selectedGender,
    String? transportationType,
    required String vehicleName,
    required String vehicleColor,
    required String vehicleNumber,
  });

  @override
  _ProvideServices3State createState() => _ProvideServices3State();
}

class _ProvideServices3State extends State<ProvideServices3> {
  Position? _currentPosition;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController builderNumberController = TextEditingController();
  final TextEditingController floorNumberController = TextEditingController();
  final TextEditingController apartmentNumberController =
      TextEditingController();
  final TextEditingController leadMarkController = TextEditingController();
  bool _isLoadingLocation = false;

  // Image files for grid display
  File? faceImage,
      graduationCertificate,
      personalIdCardFront,
      personalIdCardBack;

  @override
  void dispose() {
    cityController.dispose();
    zipCodeController.dispose();
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
          content:
              const Text("Location is disabled. Please enable it in settings."),
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
          const SnackBar(content: Text("Location permission is required.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location permission is permanently denied."),
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
    await _checkLocationPermission();

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          cityController.text = place.locality ?? '';
          zipCodeController.text = place.subLocality ?? '';
          districtController.text = place.administrativeArea ?? '';
          streetNameController.text = place.street ?? '';
          _currentPosition = position;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Location Retrieved: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error retrieving location: $e")),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _fillRandomData() {
    final faker = Faker();
    setState(() {
      cityController.text = faker.address.city();
      zipCodeController.text = faker.address
          .streetName(); // Note: faker streetName isn't zip but keeping logic similar
      districtController.text = faker.address.state();
      streetNameController.text = faker.address.streetName();
      builderNumberController.text =
          faker.randomGenerator.integer(1000, min: 1).toString();
      floorNumberController.text =
          faker.randomGenerator.integer(20, min: 1).toString();
      apartmentNumberController.text =
          faker.randomGenerator.integer(100, min: 1).toString();
      leadMarkController.text = faker.lorem.sentence();
    });
  }

  void _proceedToNextPage() {
    if (cityController.text.isEmpty ||
        zipCodeController.text.isEmpty ||
        districtController.text.isEmpty ||
        streetNameController.text.isEmpty ||
        builderNumberController.text.isEmpty ||
        floorNumberController.text.isEmpty ||
        apartmentNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all address fields")),
      );
      return;
    }

    final addressDetails = {
      "City": cityController.text,
      "Zip Code": zipCodeController.text,
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
        builder: (context) => const ProvideServices4(
          addressDetails: {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad here'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              '2 out of 3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.location_on),
                  label: Text(_isLoadingLocation
                      ? "Getting Location..."
                      : "Get Current Location"),
                ),
                ElevatedButton.icon(
                  onPressed: _fillRandomData,
                  icon: const Icon(Icons.shuffle),
                  label: const Text("Fill Random Data"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _currentPosition != null
                  ? "Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}"
                  : "No location retrieved",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Add grid view for images
            _buildImagesGrid(),

            const SizedBox(height: 20),
            ..._buildAddressFields(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _proceedToNextPage,
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesGrid() {
    List<Widget> imageWidgets = [];

    if (faceImage != null) {
      imageWidgets.add(_buildImageTile(faceImage!, 'Face'));
    }
    if (graduationCertificate != null) {
      imageWidgets.add(_buildImageTile(graduationCertificate!, 'Graduation'));
    }
    if (personalIdCardFront != null) {
      imageWidgets.add(_buildImageTile(personalIdCardFront!, 'ID_Front'));
    }
    if (personalIdCardBack != null) {
      imageWidgets.add(_buildImageTile(personalIdCardBack!, 'ID_Back'));
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: imageWidgets,
    );
  }

  Widget _buildImageTile(File image, String imageType) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _removeImage(imageType),
          ),
        ),
      ],
    );
  }

  void _removeImage(String imageType) {
    setState(() {
      if (imageType == 'Face') {
        faceImage = null;
      } else if (imageType == 'Graduation') {
        graduationCertificate = null;
      } else if (imageType == 'ID_Front') {
        personalIdCardFront = null;
      } else if (imageType == 'ID_Back') {
        personalIdCardBack = null;
      }
    });
  }

  List<Widget> _buildAddressFields() {
    final fields = [
      {
        "label": "City",
        "controller": cityController,
        "icon": Icons.location_city,
        "type": TextInputType.text
      },
      {
        "label": "Zip Code",
        "controller": zipCodeController,
        "icon": Icons.map,
        "type": TextInputType.number
      },
      {
        "label": "District",
        "controller": districtController,
        "icon": Icons.apartment,
        "type": TextInputType.text
      },
      {
        "label": "Street Name",
        "controller": streetNameController,
        "icon": Icons.streetview,
        "type": TextInputType.text
      },
      {
        "label": "Builder Number",
        "controller": builderNumberController,
        "icon": Icons.home,
        "type": TextInputType.number
      },
      {
        "label": "Floor Number",
        "controller": floorNumberController,
        "icon": Icons.arrow_upward,
        "type": TextInputType.number
      },
      {
        "label": "Apartment Number",
        "controller": apartmentNumberController,
        "icon": Icons.apartment,
        "type": TextInputType.number
      },
      {
        "label": "Lead Mark",
        "controller": leadMarkController,
        "icon": Icons.label,
        "type": TextInputType.text
      },
    ];

    return fields
        .map(
          (field) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: field["controller"] as TextEditingController,
              keyboardType: field["type"] as TextInputType,
              decoration: InputDecoration(
                labelText: field["label"] as String,
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: Icon(field["icon"] as IconData),
                prefixIconColor: Colors.blueAccent,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        )
        .toList();
  }
}
