// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Forgot Password",
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Insert your email to recieve reset password link",
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: 45,
          ),
          Container(
            margin: EdgeInsets.only(left: 42.5),
            child: Align(
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
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 42.5),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Insert Email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 45,
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: _emailController.text);
                } catch (e) {
                  print(e);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 80, right: 80, top: 10, bottom: 10),
                  backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
              child: Text(
                'Send',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 20,
                ),
              ))
        ],
      )),
    );
  }
}
