import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarek_proj/presentation/screens/auth/Login.dart';
import 'package:tarek_proj/presentation/screens/profile/ProfileScreen.dart';

class ServicesHomeScreen extends StatefulWidget {
  const ServicesHomeScreen({super.key});

  @override
  State<ServicesHomeScreen> createState() => _ServicesHomeScreenState();
}

class _ServicesHomeScreenState extends State<ServicesHomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const ServicesHomeContent(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff030927),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff0d173e),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Services'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class ServicesHomeContent extends StatefulWidget {
  const ServicesHomeContent({super.key});

  @override
  State<ServicesHomeContent> createState() => _ServicesHomeContentState();
}

class _ServicesHomeContentState extends State<ServicesHomeContent> {
  // Service Options similar to SearchService but for display/selection
  final List<Map<String, dynamic>> serviceCategories = [
    {
      "title": "Transportation",
      "icon": Icons.motorcycle,
      "services": [
        "Need Motorbike Ride",
        "Need Car Ride",
        "Need Delivery Service",
        "Need Package Courier"
      ]
    },
    {
      "title": "Home & Property",
      "icon": Icons.home_repair_service,
      "services": [
        "Need Home Cleaning",
        "Need Farm Cleaning",
        "Need Gardening/Landscaping",
        "Need Handyman Services",
        "Need Pest Control"
      ]
    },
    {
      "title": "Education",
      "icon": Icons.school,
      "services": [
        "Need Private Teacher",
        "Need Language Tutor",
        "Need Music Instructor"
      ]
    },
    {
      "title": "Care & Health",
      "icon": Icons.health_and_safety,
      "services": [
        "Need Companion/Caregiver",
        "Need Babysitter",
        "Need Nursing Care",
        "Need Physical Therapy",
        "Need Elderly Assistance",
        "Need Pet Care"
      ]
    },
    {
      "title": "Professional",
      "icon": Icons.work,
      "services": [
        "Need IT Support",
        "Need Graphic Design",
        "Need Event Planning",
        "Need Photography/Videography"
      ]
    },
    {
      "title": "Other",
      "icon": Icons.more_horiz,
      "services": ["Other Service Needed"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff030927),
      appBar: AppBar(
        backgroundColor: const Color(0xff030927),
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              } catch (e) {
                print("Logout error: $e");
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(
                Icons.logout,
                color: Colors.white,
                size: 26,
              ),
            ),
          )
        ],
        title: const Text(
          'Services Home',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What service are you looking for?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemCount: serviceCategories.length,
                itemBuilder: (context, index) {
                  final category = serviceCategories[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to details or sub-list for this category
                      // For now, just show a snackbar or placeholder
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Selected ${category['title']}")));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff2d3142),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            size: 40,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            category['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${(category['services'] as List).length} services",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
