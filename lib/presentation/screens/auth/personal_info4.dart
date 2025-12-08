import 'package:flutter/material.dart';
import 'package:tarek_proj/presentation/screens/auth/provider_details.dart';
import 'package:tarek_proj/presentation/screens/auth/address_registration.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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
  String serviceType = "Seeker"; // Default or "Provide"
  String? lookingForCategory;
  final List<String> categories = [
    "Car Driver",
    "Motorbike Rider",
    "Delivery Service",
    "Home Cleaning",
    "Gardening",
    "Private Teacher",
    "Other"
  ];

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

  void handlePrevious() {
    Navigator.pop(context);
  }

  void handleNext() {
    print("Step 4 complete. Navigate to next step based on service type.");

    if (serviceType == "Provider") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderDetails(
            email: widget.email,
            password: widget.password,
            firstName: widget.firstName,
            lastName: widget.lastName,
            arabicName: widget.arabicName,
            jobTitle: widget.jobTitle,
            phone: widget.phone,
            birthDate: widget.birthDate,
            gender: selectedGender,
            city: selectedCity,
            serviceType: "Provider",
          ),
        ),
      );
    } else {
      // Seeker
      if (lookingForCategory == null) {
        showErrorDialog(
            "Required", "Please select what service you are looking for.");
        return;
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
            gender: selectedGender,
            city: selectedCity,
            serviceType: "Seeker",
            lookingForCategory: lookingForCategory,
          ),
        ),
      );
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
          child: SingleChildScrollView(
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
                const SizedBox(height: 30),

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
                const SizedBox(height: 30),

                // City Selection
                const Text(
                  "Select City",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 30),

                // Service Selection
                const Text(
                  "I want to...",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => serviceType = "Seeker"),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: serviceType == "Seeker"
                                ? Colors.indigo
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.search, size: 40, color: Colors.white),
                              SizedBox(height: 5),
                              Text("Find Services",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => serviceType = "Provider"),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: serviceType == "Provider"
                                ? Colors.indigo
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.work, size: 40, color: Colors.white),
                              SizedBox(height: 5),
                              Text("Provide Services",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                if (serviceType == "Seeker") ...[
                  const Text(
                    "What are you looking for?",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.indigo, width: 1),
                    ),
                    child: DropdownButton<String>(
                      value: lookingForCategory,
                      isExpanded: true,
                      hint: const Text("Select Service Needed"),
                      icon: const Icon(Icons.search, color: Colors.indigo),
                      underline: const SizedBox(),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      dropdownColor: Colors.white,
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          lookingForCategory = newValue;
                        });
                      },
                    ),
                  ),
                ],

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
                      child: const Text('Next',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
