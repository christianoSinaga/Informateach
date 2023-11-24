import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/dosen/editProfile.dart';
import 'package:informateach/dosen/landingPage.dart';
import 'package:informateach/utils.dart';

Map<String, String> dosenNow = {
  "Email": "gheasekar@unesa.ac.id",
  "Name": "Ghea Sekar Palupi, S.Kom., M.I.M",
  "NIP": "123456789123456",
  "Phone": "123456789123",
  "Gender": "Female",
};

class ProfileDosen extends StatefulWidget {
  const ProfileDosen({super.key});

  @override
  State<ProfileDosen> createState() => _ProfileDosenState();
}

class _ProfileDosenState extends State<ProfileDosen> {
  late TextEditingController _nameController,
      _phoneController,
      _nipController,
      _genderController,
      _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: currentDosen["Email"]);
    _nameController = TextEditingController(text: currentDosen["Name"]);
    _nipController = TextEditingController(text: currentDosen["NIM"]);
    _phoneController =
        TextEditingController(text: currentDosen["Phone Number"]);
    _genderController = TextEditingController(
        text: currentDosen["Gender"] == null
            ? 'Mohon Diisi'
            : currentDosen['Gender']);
  }

  @override
  Widget build(BuildContext context) {
    getCurrentDosen();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(left: 14, top: 11),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset('style/img/LogoInformateach.png'),
                )),
            Stack(
              children: [
                currentDosen['Image'] != null
                    ? Container(
                        margin: const EdgeInsets.only(top: 44),
                        child: ClipOval(
                          child: Image.network(
                            currentDosen['Image']!,
                            height: 180,
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                        ))
                    : Container(
                        margin: const EdgeInsets.only(top: 44),
                        child: ClipOval(
                          child: Image.asset(
                            'style/img/DefaultIcon.png',
                            height: 180,
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ],
            ),

            //Email Dosen Container
            Container(
                margin: const EdgeInsets.only(left: 28, top: 45),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: _emailController,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            //Name Dosen Container
            Container(
                margin: const EdgeInsets.only(left: 28),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: _nameController,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            //NIP Dosen Container
            Container(
                margin: const EdgeInsets.only(left: 28),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "NIP",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: _nipController,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            //Phone Number Container
            const SizedBox(
              height: 15,
            ),
            Container(
                margin: const EdgeInsets.only(left: 28),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Phone Number",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: _phoneController,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            //Gender Dosen Container
            const SizedBox(
              height: 15,
            ),
            Container(
                margin: const EdgeInsets.only(left: 28),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Gender",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: _genderController,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 68,
            ),

            //Log Out Button and Edit Profile Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfileDosen()));
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(115, 45),
                      backgroundColor: const Color.fromRGBO(82, 109, 130, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      )),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print(FirebaseAuth.instance.currentUser?.email);
                    FirebaseAuth.instance.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(115, 45),
                    backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 160,
            )
          ],
        ),
      ),
    );
  }
}
