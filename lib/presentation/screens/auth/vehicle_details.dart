import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tarek_proj/presentation/screens/auth/address_registration.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class VehicleDetails extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String arabicName;
  final String jobTitle;
  final String phone;
  final String birthDate;
  final String gender;
  final String city;
  final String serviceType;
  final String category;
  final List<String> workingTime;
  final String dealWith;

  const VehicleDetails({
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
    required this.category,
    required this.workingTime,
    required this.dealWith,
  });

  @override
  _VehicleDetailsState createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  String transportationType = "None";
  final List<String> transportOptions = ["None", "Car", "Motorbike", "Bike"];

  final TextEditingController carNameController = TextEditingController();
  final TextEditingController carColorController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();
  final TextEditingController carLicenseNumController = TextEditingController();
  final TextEditingController userLicenseNumController =
      TextEditingController();

  String? selectedCarModel;
  final List<String> carModelYears = List.generate(
          DateTime.now().year - 1980 + 2, (index) => (1980 + index).toString())
      .reversed
      .toList();

  File? carLicenseImage;
  File? userLicenseImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isCar) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isCar) {
          carLicenseImage = File(image.path);
        } else {
          userLicenseImage = File(image.path);
        }
      });
    }
  }

  void handleNext() {
    // Validation
    if (transportationType != "None" && transportationType != "Bike") {
      if (carNameController.text.isEmpty ||
          selectedCarModel == null ||
          carColorController.text.isEmpty ||
          carNumberController.text.isEmpty ||
          carLicenseNumController.text.isEmpty ||
          userLicenseNumController.text.isEmpty ||
          carLicenseImage == null ||
          userLicenseImage == null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: "Error",
          desc: "Please fill all vehicle and license details.",
          btnOkOnPress: () {},
        ).show();
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressRegistration(
          email: widget.email,
          password: widget.password,
          firstName: widget.firstName,
          lastName: widget.lastName,
          arabicName: widget.arabicName,
          jobTitle: widget.jobTitle,
          phone: widget.phone,
          birthDate: widget.birthDate,
          gender: widget.gender,
          city: widget.city,
          serviceType: widget.serviceType,
          // Provider fields
          category: widget.category,
          workingTime: widget.workingTime,
          dealWith: widget.dealWith,
          transportationType: transportationType,
          carName: carNameController.text,
          carModel: selectedCarModel,
          carColor: carColorController.text,
          carNumber: carNumberController.text,
          carLicenseNumber: carLicenseNumController.text,
          userLicenseNumber: userLicenseNumController.text,
          carLicenseImage: carLicenseImage,
          userLicenseImage: userLicenseImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showCarDetails =
        transportationType == "Car" || transportationType == "Motorbike";

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text("Transportation Type",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: transportOptions.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: transportationType == type,
                      onSelected: (selected) {
                        setState(() {
                          transportationType = selected ? type : "None";
                        });
                      },
                      selectedColor: Colors.indigo,
                      labelStyle: TextStyle(
                          color: transportationType == type
                              ? Colors.white
                              : Colors.black),
                    );
                  }).toList(),
                ),
                if (showCarDetails) ...[
                  const SizedBox(height: 30),
                  const Text("Vehicle Details",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: carNameController,
                    decoration: InputDecoration(
                      labelText: "Vehicle Name",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.white.withOpacity(0.8),
                    child: DropdownButton<String>(
                      value: selectedCarModel,
                      hint: const Text("Model Year"),
                      isExpanded: true,
                      items: carModelYears.map((y) {
                        return DropdownMenuItem(value: y, child: Text(y));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCarModel = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: carColorController,
                    decoration: InputDecoration(
                        labelText: "Color",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: carNumberController,
                    decoration: InputDecoration(
                        labelText: "Plate Number",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 30),
                  const Text("License Details",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: carLicenseNumController,
                    decoration: InputDecoration(
                        labelText: "Vehicle License Number",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: userLicenseNumController,
                    decoration: InputDecoration(
                        labelText: "Driver License Number",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Car License Photo",
                                style: TextStyle(color: Colors.white)),
                            IconButton(
                              icon: Icon(Icons.camera_alt,
                                  color: carLicenseImage != null
                                      ? Colors.green
                                      : Colors.white),
                              onPressed: () => _pickImage(true),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Driver License Photo",
                                style: TextStyle(color: Colors.white)),
                            IconButton(
                              icon: Icon(Icons.camera_alt,
                                  color: userLicenseImage != null
                                      ? Colors.green
                                      : Colors.white),
                              onPressed: () => _pickImage(false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                    onPressed: handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: const Text("Next",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
