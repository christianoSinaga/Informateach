// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

late String ticketDelDoc;

class DeleteTicketDialog extends StatelessWidget {
  Future<void> deleteTicket() async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('tickets').doc(ticketDelDoc);

      await documentReference.delete();
    } catch (e) {
      print(e);
    }
  }

  const DeleteTicketDialog({super.key});

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
            "Are you sure?",
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
            "Are you sure to delete this ticket?",
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
          GestureDetector(
              onTap: () {
                deleteTicket();
                Navigator.pop(context);
              },
              child: Container(
                width: 100,
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: Text(
                  "Confirm",
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
