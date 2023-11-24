// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:informateach/dialog/confirmCancelTicketDialog.dart';

class CancelTicketDialog extends StatefulWidget {
  const CancelTicketDialog({super.key});

  @override
  State<CancelTicketDialog> createState() => _CancelTicketDialogState();
}

class _CancelTicketDialogState extends State<CancelTicketDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 17),
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
              Text(
                "Are you sure to cancel this ticket?",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 11,
              ),
              Text(
                "Ticket cancellations can only be made a maximum of 1 hour before the meeting time with the lecturer. Please confirm again!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(70, 15),
                          padding: const EdgeInsets.all(0),
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
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(70, 15),
                          padding: const EdgeInsets.all(0),
                          backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          )),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmCancelTicketDialog();
                            });
                      },
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              )
            ],
          )),
    );
  }
}
