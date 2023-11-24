// ignore_for_file: file_names, prefer_const_constructors

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/dosen/landingPage.dart';
import 'package:informateach/dosen/navbarConnected/profile.dart';
import 'package:informateach/utils.dart';

class EditProfileDosen extends StatefulWidget {
  const EditProfileDosen({super.key});

  @override
  State<EditProfileDosen> createState() => _EditProfileDosenState();
}

class _EditProfileDosenState extends State<EditProfileDosen> {
  Future<bool> editCurrentUserProfile(
      String name, String phone, String gender, String nim,
      [String? img]) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      var dosenQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('Email', isEqualTo: user?.email)
          .get();
      if (dosenQuery.docs.isNotEmpty) {
        var userDocument =
            dosenQuery.docs.first.reference; // Mendapatkan referensi dokumen
        if (img != null) {
          await userDocument.update({
            'Name': name,
            'Phone Number': phone,
            'Gender': gender,
            'NIM': nim,
          });
        } else {
          await userDocument.update({
            'Name': name,
            'Phone Number': phone,
            'Gender': gender,
            'NIM': nim,
            'Image': img,
          });
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> uploadProfilePict(Uint8List image) async {
    User? user = FirebaseAuth.instance.currentUser;
    Reference ref =
        FirebaseStorage.instance.ref().child('userProfilePict/${user?.email}');
    UploadTask upload = ref.putData(image);
    TaskSnapshot snapshot = await upload;
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  late TextEditingController _nameController,
      _phoneController,
      _nipController,
      _genderController,
      _emailController;

  void saveChanges() async {
    String imgLink = await uploadProfilePict(img!);
    bool done = await editCurrentUserProfile(
        _nameController.text,
        _phoneController.text,
        _genderController.text,
        _nipController.text,
        imgLink);
    if (done) {
      Navigator.pop(context);
    }
  }

  void selectImage() async {
    Uint8List selectedImg = await pickImage(ImageSource.gallery);
    setState(() {
      img = selectedImg;
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: currentDosen["Email"]);
    _nameController = TextEditingController(text: currentDosen["Name"]);
    _nipController = TextEditingController(text: currentDosen["NIM"]);
    _phoneController =
        TextEditingController(text: currentDosen["Phone Number"]);
    _genderController =
        TextEditingController(text: currentDosen["Gender"] ?? 'Male');
  }

  @override
  Widget build(BuildContext context) {
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
                img != null
                    ? Container(
                        margin: const EdgeInsets.only(top: 44),
                        child: ClipOval(
                          child: Image.memory(
                            img!,
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
                Positioned(
                  child: IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: selectImage,
                  ),
                  bottom: -10,
                  right: 4,
                )
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
                enabled: true,
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
                enabled: true,
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
                enabled: true,
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
              child: DropdownButtonFormField(
                value: _genderController.text,
                items: ['Male', 'Female'].map((String gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _genderController.text = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 68,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    saveChanges();
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(115, 45),
                      backgroundColor: const Color.fromRGBO(82, 109, 130, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      )),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(115, 45),
                    backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
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
