import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tarek_proj/pages/Choice.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController repassController = TextEditingController();
  bool _obscureTextPass = true;
  bool _obscureTextRePass = true;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    repassController.dispose();
    super.dispose();
  }

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

  bool isValidEmail(String email) {
    final RegExp emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8;
  }

  Future<void> handleSignUp() async {
    String email = emailController.text.trim();
    String password = passController.text.trim();
    String repassword = repassController.text.trim();

    if (email.isEmpty || password.isEmpty || repassword.isEmpty) {
      showErrorDialog("Error", "Please fill in all fields.");
      return;
    }

    if (!isValidEmail(email)) {
      showErrorDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    if (!isValidPassword(password)) {
      showErrorDialog("Weak Password", "Password must be at least 8 characters.");
      return;
    }

    if (password != repassword) {
      showErrorDialog("Password Mismatch", "Passwords do not match.");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Ensure userCredential.user is not null before sending verification email
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();

        // Navigate to Verify Email Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PersonalInfo2(email: email, password: password)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";

      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use. Try another.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password should be at least 8 characters.";
      }

      showErrorDialog("Error", errorMessage);
    } catch (e) {
      showErrorDialog("Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70),
              Text(
                "Let's create an account",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "Step 1: Enter Email & Set Password",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.indigo),
                  hintText: 'name@gmail.com',
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: passController,
                obscureText: _obscureTextPass,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                  hintText: 'Enter Password',
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureTextPass ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureTextPass = !_obscureTextPass;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: repassController,
                obscureText: _obscureTextRePass,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                  hintText: 'Confirm Password',
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureTextRePass
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureTextRePass = !_obscureTextRePass;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: handleSignUp,
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// 2 out of 4 - Personal Information Step



class PersonalInfo2 extends StatefulWidget {
  final String email;
  final String password;

  PersonalInfo2({required this.email, required this.password});

  @override
  _PersonalInfo2State createState() => _PersonalInfo2State();
}

class _PersonalInfo2State extends State<PersonalInfo2> {
  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController arabicNameController = TextEditingController();

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

  void handleNext() {
    String englishName = englishNameController.text.trim();
    String arabicName = arabicNameController.text.trim();

    if (englishName.isEmpty || arabicName.isEmpty) {
      showErrorDialog("Error", "Please fill in all fields.");
      return;
    }

    print("Proceeding to Next Signup Step...");
    // Navigate to next step of sign-up
  }

  void handlePrevious() {
    Navigator.pop(context, {"email": widget.email, "password": widget.password});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Info')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 70),
              Text(
                textAlign: TextAlign.center,
                "2 out of 4",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 70),
              TextField(
                controller: englishNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.indigo),
                  labelText: 'English Name',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: arabicNameController,
                textDirection: TextDirection.rtl, // Ensure right-to-left text direction
                textAlign: TextAlign.right, // Align text to the right
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.indigo),
                  labelText: 'الاسم بالعربية',
                  hintText: 'محمد أحمد',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: handlePrevious,
                    child: Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalInfo3(email: '', password: '', englishName: '', arabicName: '',),
                        ),
                      );
                    },
                    child: Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3 out of 4 - Personal Information Step


class PersonalInfo3 extends StatefulWidget {
  final String email;
  final String password;
  final String englishName;
  final String arabicName;

  PersonalInfo3({
    required this.email,
    required this.password,
    required this.englishName,
    required this.arabicName,
  });

  @override
  _PersonalInfo3State createState() => _PersonalInfo3State();
}
class _PersonalInfo3State extends State<PersonalInfo3> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

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

  bool isValidPhoneNumber(String phone) {
    final RegExp phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  void pickBirthDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        birthDateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  void handleNext() {
    String phone = phoneController.text.trim();
    String birthDate = birthDateController.text.trim();

    if (phone.isEmpty || birthDate.isEmpty) {
      showErrorDialog("Error", "Please fill in all fields.");
      return;
    }

    if (!isValidPhoneNumber(phone)) {
      showErrorDialog("Invalid Phone", "Please enter a valid phone number.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfo4(
          email: widget.email,
          password: widget.password,
          englishName: widget.englishName,
          arabicName: widget.arabicName,
          phone: phone,
          birthDate: birthDate,
        ),
      ),
    );
  }

  void handlePrevious() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ad here'),centerTitle: true,),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
                image: AssetImage(
                    'images/bg.jpg',
                ),
            ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                  '3 out 4',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),),
              SizedBox(height: 80),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: Colors.indigo),
                  labelText: 'Phone Number',
                  hintText: '+201234567890',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 60),
              TextField(
                controller: birthDateController,
                readOnly: true,
                onTap: pickBirthDate,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.indigo),
                  labelText: 'Birth Date',
                  hintText: 'Select Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: handlePrevious, child: Text('Previous')),
                  ElevatedButton(onPressed: handleNext, child: Text('Next')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//4 out of 4 - Personal Information Step




class PersonalInfo4 extends StatefulWidget {
  final String email;
  final String password;
  final String englishName;
  final String arabicName;
  final String phone;
  final String birthDate;

  PersonalInfo4({
    required this.email,
    required this.password,
    required this.englishName,
    required this.arabicName,
    required this.phone,
    required this.birthDate,
  });

  @override
  _PersonalInfo4State createState() => _PersonalInfo4State();
}

class _PersonalInfo4State extends State<PersonalInfo4> {
  String selectedGender = "Male";
  String selectedCity = "Cairo";
  final List<String> egyptianCities = [
    "Cairo", "Alexandria", "Giza", "Luxor", "Aswan", "Sharm El-Sheikh", "Hurghada"
  ];

  void handlePrevious() {
    Navigator.pop(context);
  }

  void handleNext() {
    print("Finalizing Signup...");
    print("Email: ${widget.email}");
    print("Password: ${widget.password}");
    print("English Name: ${widget.englishName}");
    print("Arabic Name: ${widget.arabicName}");
    print("Phone: ${widget.phone}");
    print("Birth Date: ${widget.birthDate}");
    print("Gender: $selectedGender");
    print("City: $selectedCity");

    // Navigate to homepage or confirmation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Choice()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ad here'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '4 out of 4',
                  style: TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 50),

              Text(
                "Select Gender",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              ToggleButtons(
                fillColor: Colors.white24,
                selectedColor: Colors.white,
                color: Colors.white,
                isSelected: [selectedGender == "Male", selectedGender == "Female"],
                onPressed: (index) {
                  setState(() {
                    selectedGender = index == 0 ? "Male" : "Female";
                  });
                },
                children: [
                  Padding(padding: EdgeInsets.all(10), child: Text("Male")),
                  Padding(padding: EdgeInsets.all(10), child: Text("Female")),
                ],
                borderRadius: BorderRadius.circular(15),
              ),
              SizedBox(height: 70),

              // City Selection
              Text(
                "Select City",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo, width: 1),
                ),
                child: DropdownButton<String>(
                  value: selectedCity,
                  isExpanded: true,
                  icon: Icon(Icons.location_city, color: Colors.indigo),
                  underline: SizedBox(),
                  style: TextStyle(fontSize: 16, color: Colors.black),
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
              SizedBox(height: 40),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: handlePrevious,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.grey[800],
                    ),
                    child: Text('Previous', style: TextStyle(fontSize: 16,color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: handleNext,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.indigo,
                    ),
                    child: TextButton(
                        onPressed: (){
                          Navigator.pushReplacement(
                              context,MaterialPageRoute(
                            builder: (context) => Choice(),));
                        },
                        child: Text(
                            'Finish',
                            style: TextStyle(
                                fontSize: 16,color: Colors.white
                            ))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

