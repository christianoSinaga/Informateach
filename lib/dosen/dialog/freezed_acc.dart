// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:informateach/dosen/database/db.dart';

class FreezedWarning extends StatelessWidget {
  FreezedWarning({super.key});
  final freezedDate = currentUser['Freeze Date'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          height: 180,
          width: 200,
          decoration: ShapeDecoration(
            color: Color(0xFF27374D),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: Color(0xFF27374D)),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "Your Account Has Been Freezed",
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
              "You can't create or cancel ticket until ${freezedDate.toDate()}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quicksand',
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ]),
        ));
  }
}
