import 'package:flutter/material.dart';
import 'package:tarek_proj/presentation/screens/services/provide_services2.dart';
import 'package:tarek_proj/presentation/screens/services/provide_services3.dart';

class ProvideServices extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const ProvideServices({super.key, required this.registrationData});

  @override
  _ProvideServicesState createState() => _ProvideServicesState();
}

class _ProvideServicesState extends State<ProvideServices> {
  List<String> serviceOptions = [
    // Transportation & Delivery
    "Motorbike Rider",
    "Car Driver",
    "Delivery Service",
    "Package Courier",

    // Home & Property
    "Home Cleaning",
    "Farm Cleaning",
    "Gardening & Landscaping",
    "Handyman & Repairs",
    "Pest Control",

    // Education & Tutoring
    "Private Teacher",
    "Language Tutor",
    "Music Instructor",

    // Care & Companionship
    "Companion / Caregiver",
    "Babysitter",
    "Nursing Care",
    "Physical Therapy",
    "Elderly Assistance",
    "Pet Sitting & Walking",

    // Professional Services
    "IT Support",
    "Graphic Design",
    "Event Planning",
    "Photography & Videography",

    // Miscellaneous
    "Other"
  ];

  Set<String> selectedServices = {};
  TextEditingController otherServiceController = TextEditingController();
  bool isOtherSelected = false;

  @override
  Widget build(BuildContext context) {
    bool isProvider = widget.registrationData['serviceType'] == 'Provider';

    return Scaffold(
      appBar: AppBar(
        title: Text(isProvider ? "Select Service" : "Service Needed"),
        centerTitle: true,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                isProvider
                    ? 'Step 1 of 3: Choose Service'
                    : 'Step 1 of 2: What do you need?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isProvider
                    ? 'Select the type of service you provide:'
                    : 'Select the service you are looking for:',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            if (!isProvider) {
                              // Seeker - Single selection? Let's assume single for easier matching
                              selectedServices.clear();
                              selectedServices.add(option);
                            } else {
                              // Provider - Multi selection allowed (or single based on requirements, let's allow multi for UI but backend might take first)
                              if (isSelected) {
                                selectedServices.remove(option);
                              } else {
                                selectedServices.add(option);
                              }
                            }
                          }
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ||
                                  (option == "Other" && isOtherSelected)
                              ? Colors.indigo
                              : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter your custom service",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (isOtherSelected &&
                        otherServiceController.text.isNotEmpty) {
                      selectedServices.add(otherServiceController.text);
                    }

                    if (selectedServices.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a service."),
                        ),
                      );
                      return;
                    }

                    // Update Data
                    String category = selectedServices.join(", ");
                    if (isProvider) {
                      widget.registrationData['provide_catagory'] = category;
                      // Navigate to Vehicle Details (Step 2)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProvideServices2(
                            registrationData: widget.registrationData,
                          ),
                        ),
                      );
                    } else {
                      widget.registrationData['looking_for_category'] =
                          category;
                      // Navigate to Address (Step 2 for Seeker - skipping Vehicle)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProvideServices3(
                              registrationData: widget.registrationData),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
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
