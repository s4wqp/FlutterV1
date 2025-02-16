import 'dart:async';
import 'package:flutter/material.dart';

import 'BothServices.dart';
import 'NeedService.dart';
import 'SearchService.dart';

class Choice extends StatefulWidget {
  const Choice({Key? key}) : super(key: key);

  @override
  State<Choice> createState() => _ChoiceState();
}

class _ChoiceState extends State<Choice> {
  Set<String> selectedOptions = {}; // Stores selected options

  final PageController _pageController = PageController(initialPage: 0);
  int _currentImageIndex = 0;
  late Timer _timer;

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
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentImageIndex < sponsorImages.length - 1) {
        _currentImageIndex++;
      } else {
        _currentImageIndex = 0;
      }
      _pageController.animateToPage(
        _currentImageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void toggleSelection(String option) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option);
      } else {
        selectedOptions.add(option);
      }
    });
  }

  void navigateToSelectedPages() {
    if (selectedOptions.length == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BothServicesPage()),
      );
    } else if (selectedOptions.contains("Provide a service")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NeedServicePage()),
      );
    } else if (selectedOptions.contains("Looking for a service")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchServicePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // AppBar height
        child: AppBar(
          backgroundColor: Colors.black87,
          title: SizedBox(
            height: 80, // Fill entire AppBar
            child: PageView.builder(
              controller: _pageController,
              itemCount: sponsorImages.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(sponsorImages[index]),
                      fit: BoxFit.cover, // Fill the AppBar completely
                    ),
                  ),
                );
              },
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('images/bg.jpg'),
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 100),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Awesome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We're so close",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
            Text(
              "Step 2 : Select what you need.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Text(
              "You want to:\n Note: You can select both",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCircleButton("Provide a service", Icons.add_card),
                SizedBox(width: 50),
                buildCircleButton("Looking for a service", Icons.search),
              ],
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: selectedOptions.isNotEmpty ? navigateToSelectedPages : null, // Disable if nothing is selected
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedOptions.isNotEmpty ? Colors.blueGrey[700] : Colors.grey[800],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                "Next",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCircleButton(String title, IconData icon) {
    bool isSelected = selectedOptions.contains(title);
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => toggleSelection(title),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(25),
            backgroundColor: isSelected ? Colors.blueAccent : Colors.blueGrey[700],
            elevation: isSelected ? 10 : 5,
          ),
          child: Icon(icon, size: 35, color: Colors.white),
        ),
        SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.blueAccent : Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}