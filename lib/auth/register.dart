import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:informateach/dosen/tutorial/tutorial_page.dart';
import 'package:informateach/tutorial/tutorial_page.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  //Sign Up Function
  Future signUp() async {
    if (checkNullTextField()) {
      return showNullValueDialog(context);
    }
    if (passwordMatch()) {
      //MEMBUAT AKUN USER
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (isStudent(_emailController.text.trim())) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TutorialPage()));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DosenTutorialPage()));
      }

      String? token = await FirebaseMessaging.instance.getToken();

      // Calling User Document Function

      createUser(
          _emailController.text.trim(),
          _nameController.text.trim(),
          _nimController.text.trim(),
          _phoneNumberController.text.trim(),
          isStudent(_emailController.text.trim()),
          token!);

      sendEmailVerification();
      return showEmailVerificationSentDialog(context);
    } else {
      return showPassNotMatchDialog(context);
    }
  }

  // Dialog
  // Show Email Verification Sent Dialog
  void showEmailVerificationSentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 17),
              height: 200,
              width: 330,
              decoration: ShapeDecoration(
                  color: Color.fromARGB(255, 228, 235, 240),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFF27374D)),
                      borderRadius: BorderRadius.circular(18))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Email Verification Sent",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Please verificate your email address to use the app",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Quicksand'),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(70, 15),
                          backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          )),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              )),
        );
      },
    );
  }

  // Show Pass Not Match Dialog
  void showPassNotMatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 17),
              height: 200,
              width: 330,
              decoration: ShapeDecoration(
                  color: Color.fromARGB(255, 228, 235, 240),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFF27374D)),
                      borderRadius: BorderRadius.circular(18))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Register Error",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Please input the right password",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Quicksand'),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(70, 15),
                          backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          )),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              )),
        );
      },
    );
  }

  // Show Null Input Dialog
  void showNullValueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 17),
              height: 200,
              width: 330,
              decoration: ShapeDecoration(
                  color: Color.fromARGB(255, 228, 235, 240),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFF27374D)),
                      borderRadius: BorderRadius.circular(18))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Register Error",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Please fill all the text fields",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Quicksand'),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(70, 15),
                          backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          )),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              )),
        );
      },
    );
  }

  //Create User Document Function
  Future createUser(String email, String name, String nim, String phoneNumber,
      bool role, String token) async {
    await FirebaseFirestore.instance.collection('users').add({
      'Email': email,
      'Name': name,
      'NIM': nim,
      'Phone Number': phoneNumber,
      'Student': role,
      'Token': token,
      'Freeze Date': DateTime.now().subtract(const Duration(days: 1)),
    });
  }

  //Check TextField Input
  bool checkNullTextField() {
    if (_emailController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _nimController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      return true;
    }
    return false;
  }

  //Check PassWord Confirm
  bool passwordMatch() {
    if (_passwordController.text == _confirmPasswordController.text) {
      return true;
    }
    return false;
  }

  //Send Email Verification
  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.sendEmailVerification();
  }

  //Checking User Type
  bool isStudent(String email) {
    if (email.contains("@mhs")) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nimController.dispose();
    _phoneNumberController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 135),
              child: const Text(
                'Register',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text(
              'Fill your information below',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 45),
            Container(
              margin: const EdgeInsets.only(left: 42.5),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Name',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5, right: 42.5),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Insert your name!',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ID',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5, right: 42.5),
              child: TextField(
                controller: _nimController,
                decoration: const InputDecoration(
                  labelText: 'Insert your NIM/NIDM!',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Phone Number',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5, right: 42.5),
              child: TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Insert your phone number!',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5, right: 42.5),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Insert your email!',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5, right: 42.5),
              child: TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Insert your new password!',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5, right: 42.5),
              child: TextField(
                obscureText: true,
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm your new password!',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: signUp,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 80, right: 80, top: 10, bottom: 10),
                  backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
              child: const Text(
                'Register',
                style: TextStyle(fontFamily: 'Quicksand', fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 42.5),
              child: Row(
                children: [
                  const Text(
                    'Do you have an account?',
                    style: TextStyle(fontFamily: 'Quicksand', fontSize: 15),
                  ),
                  TextButton(
                    onPressed: widget.showLoginPage,
                    child: const Text(
                      'Login',
                      style: TextStyle(fontFamily: 'Quicksand', fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 135,
            ),
          ],
        ),
      ),
    ));
  }
}
