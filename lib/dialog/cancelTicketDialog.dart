// ignore_for_file: file_names, prefer_const_constructors

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:informateach/dosen/database/db.dart';
import 'package:http/http.dart' as http;

late String ticketMahasiswaCancel;

class CancelTicketDialog extends StatefulWidget {
  const CancelTicketDialog({super.key});

  @override
  State<CancelTicketDialog> createState() => _CancelTicketDialogState();
}

class _CancelTicketDialogState extends State<CancelTicketDialog> {
  final ticketCounts = currentUser['Cancelled Tickets'] == 3
      ? 0
      : currentUser['Cancelled Tickets'];
  //MENDAPATKAN TOKEN DARI MAHASISWA DAN DOSEN YANG DIBUTUHKAN UNTUK MENGIRIM NOTIFIKASI
  Future<Map<String, dynamic>> getTicket() async {
    final CollectionReference ticketRefference =
        FirebaseFirestore.instance.collection('tickets');

    DocumentSnapshot<Object?> querySnapshot =
        await ticketRefference.doc(ticketMahasiswaCancel).get();

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

  //MENGIRIM NOTIFIKASI DENGAN TOKEN TOKEN YANG SUDAH DIDAPAT
  Future<void> sendCancelNotification(
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
        'id': ticketMahasiswaCancel.hashCode,
        'action': 'cancel',
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
        'id': ticketMahasiswaCancel.hashCode,
        'action': 'cancel',
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

  Future<void> cancelTicket() async {
    await getCurrentUser();
    final CollectionReference ticketCollection =
        FirebaseFirestore.instance.collection('tickets');
    final ticket = await ticketCollection.doc(ticketMahasiswaCancel).get();
    if (ticket.exists) {
      try {
        //MEMERIKSA JUMLAH TIKET YANG DIBATALKAN MAHASISWA
        if (currentUser['Cancelled Tickets'] != 3) {
          //MEMBATALKAN TIKET JIKA MAHASISWA BELUM MENCAPAI BATAS CANCEL TICKET
          await ticketCollection.doc(ticketMahasiswaCancel).update({
            'status': 'Cancelled',
          });
          //MENAMBAHKAN JUMLAH TIKET YANG DIBATALKAN MAHASISWA
          var userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('Email', isEqualTo: currentUser['Email'])
              .get();
          if (userQuery.docs.isNotEmpty) {
            var userDocument = userQuery.docs.first.reference;
            var userData = userQuery.docs.first.data();
            int cancelledTickets = userData['Cancelled Tickets'] ?? 0;
            await userDocument.update({
              'Cancelled Tickets': (cancelledTickets + 1),
            });

            sendCancelNotification(
                title: 'TIKET DIBATALKAN',
                studentMessageBody:
                    'Anda telah membatalkan tiket. Ingatlah bahwa mahasiswa memiliki batas 3 kali untuk membatalkan tiket',
                dosenMessageBody:
                    'Salah satu tiket anda DIBATALKAN oleh MAHASISWA. Ketuk untuk melihat lebih lanjut!');
            if (cancelledTickets == 2) {
              await userDocument.update({
                'Freeze Date': DateTime.now().add(Duration(days: 1)),
              });
            }
          }
        } else {
          //MEMERIKSA APAKAH KONDISI MAHASISWA SUDAH MELEWATI MASA FREEZED/BANNED
          //KONDISI MAHASISWA SUDAH MELEWATI KONDISI FREEZED/BANNED
          if (DateTime.now().isAfter(
            (currentUser['Freeze Date'] as Timestamp).toDate(),
          )) {
            //MERESET JUMLAH TIKET YANG DIBATALKAN MAHASISWA
            var userQuery = await FirebaseFirestore.instance
                .collection('users')
                .where('Email', isEqualTo: currentUser['Email'])
                .get();
            if (userQuery.docs.isNotEmpty) {
              var userDocument = userQuery.docs.first.reference;
              await userDocument.update({
                'Cancelled Tickets': 1,
              });
            }
            sendCancelNotification(
                title: 'TIKET DIBATALKAN',
                studentMessageBody:
                    'Anda telah membatalkan tiket. Ingatlah bahwa mahasiswa memiliki batas 3 kali untuk membatalkan tiket',
                dosenMessageBody:
                    'Salah satu tiket anda DIBATALKAN oleh MAHASISWA. Ketuk untuk melihat lebih lanjut!');
            //MEMBATALKAN TIKET
            await ticketCollection.doc(ticketMahasiswaCancel).update({
              'status': 'Cancelled',
            });
          }
          //KONDISI MAHASISWA SEDANG DALAM KONDISI FREEZED/BANNED
          else {
            print('MAHASISWA SEDANG DALAM KONDISI BANNED');
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }

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
                "You already cancelled $ticketCounts tickets. If you already cancelled 3 tickets, your account will be banned",
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
                        cancelTicket();
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
