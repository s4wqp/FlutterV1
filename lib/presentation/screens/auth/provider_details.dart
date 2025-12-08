import 'package:flutter/material.dart';
import 'package:tarek_proj/presentation/screens/auth/vehicle_details.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ProviderDetails extends StatefulWidget {
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
  final String serviceType; // "Provider"

  const ProviderDetails({
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
  });

  @override
  _ProviderDetailsState createState() => _ProviderDetailsState();
}

class _ProviderDetailsState extends State<ProviderDetails> {
  final List<String> categories = [
    "Car Driver",
    "Motorbike Rider",
    "Delivery Service",
    "Home Cleaning",
    "Gardening",
    "Private Teacher",
    "Other"
  ];
  String? selectedCategory;

  Set<String> selectedWorkingTimes = {};
  String? selectedDealWith;

  void showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void handleNext() {
    if (selectedCategory == null) {
      showErrorDialog("Please select a service category.");
      return;
    }
    if (selectedWorkingTimes.isEmpty) {
      showErrorDialog("Please select at least one working time.");
      return;
    }
    if (selectedDealWith == null) {
      showErrorDialog("Please select who you deal with.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetails(
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
          category: selectedCategory!,
          workingTime: selectedWorkingTimes.toList(),
          dealWith: selectedDealWith!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Details')),
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
                const Text(
                  "Service Category",
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
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    hint: const Text("Select Category"),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategory = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Working Time",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: ["Morning", "Afternoon", "Night"].map((time) {
                    final bool isSelected = selectedWorkingTimes.contains(time);
                    return FilterChip(
                      label: Text(time),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedWorkingTimes.add(time);
                          } else {
                            selectedWorkingTimes.remove(time);
                          }
                        });
                      },
                      selectedColor: Colors.indigo,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Who to deal with?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["Male", "Female", "Nevermind"].map((deal) {
                    return ChoiceChip(
                      label: Text(deal),
                      selected: selectedDealWith == deal,
                      onSelected: (selected) {
                        setState(() {
                          selectedDealWith = selected ? deal : null;
                        });
                      },
                      selectedColor: Colors.indigo,
                      labelStyle: TextStyle(
                          color: selectedDealWith == deal
                              ? Colors.white
                              : Colors.black),
                    );
                  }).toList(),
                ),
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
