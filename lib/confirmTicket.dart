// ignore_for_file: file_names, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:informateach/createTicket.dart';
import 'package:informateach/dialog/confirmTicketDialog.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/dosen/dialog/freezed_acc.dart';
import 'package:informateach/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Map<String, dynamic> ticket = {};

class ConfirmTicket extends StatefulWidget {
  const ConfirmTicket({super.key});

  @override
  State<ConfirmTicket> createState() => _ConfirmTicketState();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class _ConfirmTicketState extends State<ConfirmTicket> {
  Map<String, dynamic> selectedDosen = {'temp': 'temp'};
  Future<void> fetchSelectedDosen() async {
    Map<String, dynamic> selectedDosenTmp = await getSelectedDosen(idDosen);
    setState(() {
      selectedDosen = selectedDosenTmp;
    });
  }

  Future<void> editTicket({
    required String ticketDoc,
    required String studentEmail,
    String? purpose,
  }) async {
    try {
      var ticketRef = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketDoc)
          .get();
      if (ticketRef.exists) {
        await FirebaseFirestore.instance
            .collection('tickets')
            .doc(ticketDoc)
            .update({
          'studentEmail': studentEmail,
          'available': false,
          'status': 'Waiting for validation',
          'purpose': purpose,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> cancelBookTicket({required String ticketDoc}) async {
    try {
      var ticketRef = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketDoc)
          .get();
      if (ticketRef.exists) {
        await FirebaseFirestore.instance
            .collection('tickets')
            .doc(ticketDoc)
            .update({
          'available': true,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendNotification(
      {required String studentToken,
      required String dosenToken,
      required String title,
      required String studentMessageBody,
      required String dosenMessageBody,
      String? day,
      String? time,
      String? action,
      int? id}) async {
    String serverKey =
        'AAAAocHrxW4:APA91bERuV6OS7gveDa9iHOrOrVj6mjPOJ1sFSm4GiZW7idjht6X0M9wjCflL9BQLW8fnTeuJxQmvOaqGahwoBGA9plPIxR-I9LgS9faCbxUY4RlVYtQmUTrqqTn-rkuHrR2zxvkRH3n';
    const url = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final studentMessage = {
      'to': studentToken,
      'data': {
        'title': title,
        'body': studentMessageBody,
        'action': action,
        'id': id,
        'day': day,
        'time': time,
        'priority': 'high', // Prioritas tinggi
        'click-action':
            'FLUTTER_NOTIFICATION_CLICK', // Aksi saat notifikasi diklik
      },
      'android': {
        'priority': 'high',
      }
    };

    final dosenMessage = {
      'to': dosenToken,
      'data': {
        'title': title,
        'body': dosenMessageBody,
        'action': action,
        'id': id,
        'day': day,
        'time': time,
        'priority': 'high',
        'content-available': 1,
        'click-action': 'FLUTTER_NOTIFICATION_CLICK'
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
      print('Notifikasi untuk mahasiswa terkirim!');
    } else {
      print(
          'Gagal mengirim notifikasi. Kode status: ${sendToStudent.statusCode}');
    }
    if (sendToDosen.statusCode == 200) {
      print('Notifikasi untuk dosen terkirim!');
    } else {
      print(
          'Gagal mengirim notifikasi. Kode status: ${sendToDosen.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    ticket = {
      "Dosen": dosen,
      "Date": finalSelectedDay,
      "Time": finalSelectedTime,
      "Purpose": finalPurpose,
      "Gambar": "style/img/testDosen1.png",
    };
    fetchSelectedDosen();
    tz.initializeTimeZones();
  }

  Future<bool> _onBackPressed() async {
    String ticketDoc =
        "${selectedDosen['Email']}-$finalSelectedDay-$finalSelectedTime";
    await cancelBookTicket(ticketDoc: ticketDoc);
    print('Tiket terbatalkan');
    return true;
  }

  bool checkFreeze() {
    if (DateTime.now()
        .isAfter((currentUser['Freeze Date'] as Timestamp).toDate())) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    List<String> dateDetails = ticket['Date'].toString().split(' ');
    String dayName = getDayName(ticket['Date']);
    if (selectedDosen['temp'] == 'temp') {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white10,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white10,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
            child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 286,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF27374D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Your Appoinment",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )),
              ),
              SizedBox(
                height: 31,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    selectedDosen['Image'] ?? 'style/img/DefaultIcon.png',
                    width: 101,
                    height: 138,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Handle error loading image
                      return Image.asset(
                        'style/img/DefaultIcon.png',
                        width: 101,
                        height: 138,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  SizedBox(
                    width: 31,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "${selectedDosen['Name']}",
                          style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${selectedDosen["Email"]}",
                          style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 47,
              ),
              Divider(
                height: 0,
                thickness: .3,
                color: Colors.black,
              ),
              SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dayName}, ${dateDetails[0]}',
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "${ticket["Time"]} WIB",
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Name   : ${currentUser['Name'] ?? 'Test'}",
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                "NIM      : ${currentUser["NIM"] ?? 'Test'}",
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 19,
              ),
              Text(
                "PURPOSE",
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 14),
              Container(
                width: 400,
                height: 146,
                decoration: ShapeDecoration(
                  color: Color(0x33526D82),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFF27374D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(ticket["Purpose"])),
              ),
              SizedBox(
                height: 94,
              ),
              GestureDetector(
                onTap: () async {
                  await getCurrentUser();
                  String ticketDoc =
                      "${selectedDosen['Email']}-$finalSelectedDay-$finalSelectedTime";
                  int notificationId = ticketDoc.hashCode;
                  // MENGUBAH DOKUMEN TIKET
                  if (checkFreeze()) {
                    await editTicket(
                      ticketDoc: ticketDoc,
                      studentEmail: currentUser['Email'],
                      purpose: ticket['Purpose'],
                    );
                    // MENGIRIM NOTIFIKASI
                    sendNotification(
                        id: notificationId,
                        action: 'create',
                        studentToken: currentUser['Token'],
                        dosenToken: selectedDosen['Token'],
                        title: "Ticket Created",
                        day: finalSelectedDay,
                        time: finalSelectedTime,
                        studentMessageBody:
                            "Tiket berhasil dibuat untuk ${selectedDosen['Name']}",
                        dosenMessageBody:
                            "Seseorang telah membuat janji dengan anda!. Ketuk untuk melihat!");

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmTicketDialog();
                        });
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FreezedWarning();
                        });
                  }
                },
                child: Container(
                    width: 400,
                    height: 86,
                    decoration: ShapeDecoration(
                      color: Color(0xFF27374D),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "CONFIRM",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Quicksand',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              )
            ],
          ),
        )),
      ),
    );
  }
}
