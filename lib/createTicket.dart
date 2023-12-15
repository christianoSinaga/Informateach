// import 'dart:js_util';

// ignore_for_file: file_names, prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:informateach/confirmTicket.dart';
import 'package:informateach/dialog/dialogError.dart';
import 'package:informateach/main.dart';

String? finalSelectedDay;
String? finalSelectedTime;
String? finalPurpose;
String dosen = idDosen;

Future<Map<String, dynamic>> getSelectedDosen(String email) async {
  try {
    var dosenQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: email)
        .get();

    if (dosenQuery.docs.isNotEmpty) {
      Map<String, dynamic> dosenData = dosenQuery.docs.first.data();
      return dosenData;
    } else {
      throw Exception("No Dosen Found");
    }
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future<List<String>> getDosenSchedule(String day, String email) async {
  final CollectionReference dosenScheduleCollection =
      FirebaseFirestore.instance.collection('tickets');

  // Ganti 'day' dengan field yang sesuai dengan struktur dokumen Firestore
  QuerySnapshot<Object?> querySnapshot = await dosenScheduleCollection
      .where('day', isEqualTo: day)
      .where('dosen', isEqualTo: email)
      .get();

  List<String> timeList = [];

  querySnapshot.docs.forEach((doc) {
    String time = doc['time'];
    String status;
    if (doc['available'] == true) {
      status = "AVAILABLE";
    } else {
      status = "BOOKED";
    }

    timeList.add('$time        $status');
  });

  return timeList;
}

class CreateTicket extends StatefulWidget {
  const CreateTicket({super.key});

  @override
  State<CreateTicket> createState() => _CreateTicketState();
}

String getDayName(String date) {
  int weekDayNumber = DateTime.parse(date).weekday;
  switch (weekDayNumber) {
    case 1:
      return "Mon";
    case 2:
      return "Tue";
    case 3:
      return "Wed";
    case 4:
      return "Thur";
    case 5:
      return "Fri";
    case 6:
      return "Sat";
    case 7:
      return "Sun";
    default:
      return "null";
  }
}

class _CreateTicketState extends State<CreateTicket> {
  String idDosenNow = idDosen;
  Map<String, dynamic> selectedDosen = {'temp': "temp"};
  late List<String> dosenSchedule;

  String selectedDay =
      "${DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)}";
  String? selectedTime;
  TextEditingController _purposeController = TextEditingController();
  List<String> dosenScheduleList = [];

  Future<void> fetchDosenSchedule() async {
    List<String> schedule = await getDosenSchedule(selectedDay, idDosen);
    setState(() {
      dosenScheduleList = schedule;
    });
  }

  Future<void> bookTicket({required String ticketDoc}) async {
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
          'available': false,
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchSelectedDosen() async {
    Map<String, dynamic> selectedDosenTmp = await getSelectedDosen(idDosen);
    setState(() {
      selectedDosen = selectedDosenTmp;
    });
  }

  DateTime _getSunday(DateTime date) {
    int weekday = date.weekday;
    if (weekday == 7) return date;
    return date.subtract(Duration(days: weekday));
  }

  List<String> getCurrentWeek() {
    List<String> currentWeek = [];
    var now = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    var sunday = _getSunday(now);
    for (int i = 0; i < 7; i++) {
      String dayname = sunday.add(Duration(days: i)).toString();
      String status;
      if (now.isAfter(DateTime.parse(dayname))) {
        status = 'LAMPAU';
      } else {
        status = 'BELUM';
      }
      currentWeek.add('$dayname     $status');
    }
    return currentWeek;
  }

  @override
  void initState() {
    super.initState();
    dosenSchedule = getCurrentWeek();
    fetchDosenSchedule();
    fetchSelectedDosen();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDosen['temp'] == 'temp') {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white10,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white10,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: 337,
                            height: 163,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(39, 55, 77, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    selectedDosen["Image"] ??
                                        'style/img/DefaultIcon.png',
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
                                ),
                                const SizedBox(width: 20),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        selectedDosen["Name"]!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                      Text(
                                        selectedDosen["NIM"]!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 49,
                        ),
                        Container(
                          width: 400,
                          height: 55,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AboutDosen()));
                                    },
                                    child: Text(
                                      "ABOUT",
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(.2),
                                        fontSize: 20,
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                      ),
                                    )),
                                Image.asset("style/img/Line 2.png"),
                                GestureDetector(
                                  child: const Text(
                                    "SCHEDULE",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                    ),
                                  ),
                                )
                              ]),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 177,
                              child: SingleChildScrollView(
                                child: Column(
                                    children: dosenSchedule.map((day) {
                                  List dayDetails = day.split('     ');
                                  String dayName = getDayName(dayDetails[0]);
                                  bool isPassed = dayDetails[1] == 'LAMPAU';
                                  bool isSelected =
                                      selectedDay == dayDetails[0];
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!isPassed) {
                                          setState(() {
                                            selectedDay = dayDetails[0];
                                          });
                                        }
                                        fetchDosenSchedule();
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 40,
                                        decoration: ShapeDecoration(
                                            color: isSelected
                                                ? const Color(0xFF3687E5)
                                                : isPassed
                                                    ? const Color(0xFF27374D)
                                                    : Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    color: Color(0xFFD9D9D9),
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(7))),
                                        child: Center(
                                            child: Text(
                                          dayName,
                                          style: TextStyle(
                                              color: isSelected || isPassed
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontFamily: 'Quicksand',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        )),
                                      ),
                                    ),
                                  );
                                }).toList()),
                              ),
                            ),
                            Image.asset("style/img/Line 4.png"),
                            SizedBox(
                              height: 177,
                              width: 190,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: dosenScheduleList.map((time) {
                                    List<String> timeInfo =
                                        time.split("        ");
                                    String jam = timeInfo[0];
                                    String status = timeInfo[1];

                                    bool isAvailable = status == "AVAILABLE";
                                    bool isSelected = selectedTime == jam;

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isAvailable) {
                                              print(
                                                  "Jam $jam sudah terbooking");
                                              selectedTime =
                                                  isSelected ? null : jam;
                                            }
                                          });
                                        },
                                        child: Container(
                                          width: 188,
                                          height: 40,
                                          decoration: ShapeDecoration(
                                            color: isSelected
                                                ? const Color(0xFF3687E5)
                                                : (isAvailable
                                                    ? Colors.white
                                                    : const Color(0xFF27374D)),
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFD9D9D9)),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(time,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : (isAvailable
                                                          ? Colors.black
                                                          : Colors.white),
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(left: 37),
                              child: const Text(
                                "PURPOSE",
                                style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                        Container(
                          width: 320,
                          height: 91,
                          decoration: ShapeDecoration(
                            color: const Color(0x33526D82),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, color: Color(0xFF27374D)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _purposeController,
                              decoration: const InputDecoration(
                                border: InputBorder
                                    .none, // Hapus border internal dari TextField
                                hintText: 'Enter your purpose',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              style: const TextStyle(color: Colors.black45),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              GestureDetector(
                onTap: () {
                  finalSelectedTime = selectedTime;
                  dosen = selectedDosen['Email'];
                  finalPurpose = _purposeController.text;
                  finalSelectedDay = selectedDay;
                  String ticketDoc =
                      "${selectedDosen['Email']}-$selectedDay-$selectedTime";
                  if (_purposeController.text.isEmpty) {
                    return dialogErrorHandling(
                        context, "Please fill the purpose field");
                  }
                  if (finalSelectedTime == null) {
                    return dialogErrorHandling(context, "Please choose a time");
                  } else {
                    bookTicket(ticketDoc: ticketDoc);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConfirmTicket()));
                  }
                },
                child: Container(
                    width: 400,
                    height: 86,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF27374D),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "SELECT",
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
        ));
  }
}
