// ignore_for_file: file_names, prefer_const_constructors

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:informateach/createTicket.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/main.dart';

String tokenHpTest =
    "d1pgfqYcSRi1Cx02FLxuoG:APA91bFUZ5bD49_x7PS8lPiMS9GWr03bcAUT1gJuNtDZTmwFNBudrNPEpj3k_LPwZ-9oQkarZEPYf2QjWMGvsVkylS5h2qn7eWtilQiC6t1WHnMB3mbYjuDVNsFyovMMWp0yRoFV_dvA";

class ConfirmTicketDialog extends StatefulWidget {
  const ConfirmTicketDialog({super.key});

  @override
  State<ConfirmTicketDialog> createState() => _ConfirmTicketDialogState();
}

class _ConfirmTicketDialogState extends State<ConfirmTicketDialog> {
  Map<String, dynamic> selectedDosen = {'temp': 'temp'};
  Future<void> fetchSelectedDosen() async {
    Map<String, dynamic> selectedDosenTmp = await getSelectedDosen(idDosen);
    setState(() {
      selectedDosen = selectedDosenTmp;
    });
  }

  Future<String?> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    return token;
  }

  @override
  void initState() {
    super.initState;
    fetchSelectedDosen();
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    return Dialog(
      insetPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 44, vertical: 17),
        height: 200,
        width: 330,
        decoration: ShapeDecoration(
          color: Color(0xFF27374D),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFF27374D)),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Your Appointment has been saved",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 11,
          ),
          Text(
            "Please don't be late and make sure to validate attendance! Appointment cancellations can only be made a maximum of 1 hour before the appointment!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Quicksand',
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 13,
          ),
          GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                // MENDAPATKAN TOKEN DEVICE
              },
              child: Container(
                width: 80,
                height: 15,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: Text(
                  "HOME",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF27374D),
                    fontSize: 12,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ))
        ]),
      ),
    );
  }
}
