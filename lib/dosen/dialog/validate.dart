// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

late String ticketDoc;

class ValidateTicketDialog extends StatefulWidget {
  const ValidateTicketDialog({super.key});

  @override
  State<ValidateTicketDialog> createState() => _ValidateTicketDialogState();
}

class _ValidateTicketDialogState extends State<ValidateTicketDialog> {
  Future<void> validateTicket() async {
    final CollectionReference ticketCollection =
        FirebaseFirestore.instance.collection('tickets');

    final ticket = await ticketCollection.doc(ticketDoc).get();
    if (ticket.exists) {
      await ticketCollection.doc(ticketDoc).update({
        'status': 'Validated',
      });
    }
  }

  Future<Map<String, dynamic>> getTicket() async {
    final CollectionReference ticketRefference =
        FirebaseFirestore.instance.collection('tickets');

    DocumentSnapshot<Object?> querySnapshot =
        await ticketRefference.doc(ticketDoc).get();

    var ticketData = querySnapshot.data() as Map<String, dynamic>;

    var studentQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: ticketData['studentEmail'])
        .get();
    if (studentQuery.docs.isNotEmpty) {
      var studentData = studentQuery.docs.first.data();

      ticketData['studentToken'] = studentData['Token'];
    }
    var dosenQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: ticketData['dosen'])
        .get();
    if (dosenQuery.docs.isNotEmpty) {
      var dosenData = dosenQuery.docs.first.data();

      ticketData['dosenToken'] = dosenData['Token'];
    }

    Map<String, dynamic> ticketFinal = ticketData;
    return ticketFinal;
  }

  Future<void> sendValidateNotification(
      {required String title,
      required String studentMessageBody,
      required String dosenMessageBody}) async {
    Map<String, dynamic> ticket = await getTicket();
    String serverKey =
        'AAAAocHrxW4:APA91bERuV6OS7gveDa9iHOrOrVj6mjPOJ1sFSm4GiZW7idjht6X0M9wjCflL9BQLW8fnTeuJxQmvOaqGahwoBGA9plPIxR-I9LgS9faCbxUY4RlVYtQmUTrqqTn-rkuHrR2zxvkRH3n';
    const url = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final studentMessage = {
      'to': ticket['studentToken'],
      'data': {
        'title': title,
        'body': studentMessageBody,
        'priority': 'high',
        'click-action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'android': {
        'priority': 'high',
      }
    };

    final dosenMessage = {
      'to': ticket['dosenToken'],
      'data': {
        'title': title,
        'body': dosenMessageBody,
        'priority': 'high',
        'click-action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'android': {
        'priority': 'high',
      }
    };

    final sendToStudent = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(studentMessage));
    final sendToDosen = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(dosenMessage));

    if (sendToStudent.statusCode == 200) {
      print('Notifikasi validasi terkirim u/ mahasiswa');
    } else {
      print('Gagal mengirim ke mahasiswa, Kode : ${sendToStudent.statusCode}');
    }
    if (sendToDosen.statusCode == 200) {
      print('Notifikasi validasi terkirim u/ dosen');
    } else {
      print('Gagal mengirim ke mahasiswa, Kode : ${sendToDosen.statusCode}');
    }
  }

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
            "You cannot cancel if you have validated student attendance",
            // ticketDoc,
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
                validateTicket();
                sendValidateNotification(
                    title: 'Kehadiran Tervalidasi',
                    studentMessageBody:
                        'Kehadiranmu telah TERVALIDASI. Ketuk untuk melihat lebih lanjut',
                    dosenMessageBody:
                        'SUKSES melakukan validasi kehadiran. Ketuk untuk melihat lebih lanjut');
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
