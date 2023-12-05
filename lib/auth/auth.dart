// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:informateach/auth/acc_auth.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/dosen/landingPage.dart';
import 'package:informateach/main.dart';
import 'package:showcaseview/showcaseview.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data;
            late bool mahasiswa = user!.email!.contains("@mhs");
            if (mahasiswa) {
              return MyAppMahasiswa(initialPage: 0);
            } else {
              return MyAppDosen(initialPage: 0);
            }
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}
