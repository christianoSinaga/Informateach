import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:informateach/auth/forgot_pass.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        print(e.code);
        showSignInErrorDialog(context, e);
      } else {
        // Jika e bukan instance dari FirebaseAuthException, tampilkan pesan default
        print("An error occurred during sign-in: $e");
      }
    }
  }

  void showSignInErrorDialog(BuildContext context, FirebaseAuthException e) {
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
                    "Login Error",
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
                        getSignInErrorMessage(e),
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
                        "HOME",
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

  String getSignInErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'User not found. Please check your email.';
      case 'invalid-credential':
        return 'Wrong email or password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';
      default:
        return 'An error occurred while signing in. Please try again later.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Hi! Welcome back, you have been missed',
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
                  labelText: 'Insert your password!',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 42.5),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPassword()));
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontFamily: 'Quicksand', fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                signIn();
              },

              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const MyAppMahasiswa(
              //               initialPage: 0,
              //             )));
              // Navigator.push(
              // context,
              // MaterialPageRoute(
              // builder: (context) => MyAppDosen(
              // initialPage: 0,
              // )));

              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 80, right: 80, top: 10, bottom: 10),
                  backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
              child: const Text(
                'Login',
                style: TextStyle(fontFamily: 'Quicksand', fontSize: 20),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 42.5),
              child: Row(
                children: [
                  const Text(
                    'Do not have an account?',
                    style: TextStyle(fontFamily: 'Quicksand', fontSize: 15),
                  ),
                  TextButton(
                    onPressed: widget.showRegisterPage,
                    child: const Text(
                      'Register',
                      style: TextStyle(fontFamily: 'Quicksand', fontSize: 15),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
