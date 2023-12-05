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
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
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
