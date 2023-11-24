// ignore_for_file: file_names, prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/dosen/navbarConnected/profile.dart';

class ConfirmSchedule extends StatefulWidget {
  const ConfirmSchedule({super.key});

  @override
  State<ConfirmSchedule> createState() => _ConfirmScheduleState();
}

DateTime _getSunday(DateTime date) {
  int weekday = date.weekday;
  if (weekday == 7) return date;
  return date.subtract(Duration(days: weekday));
}

Future<void> createTicketDocs(
    Map<String, List<String>?> selectedTimesMap) async {
  final CollectionReference ticketsCollection =
      FirebaseFirestore.instance.collection('tickets');

  String? userEmail = FirebaseAuth.instance.currentUser!.email;

  selectedTimesMap.forEach((day, times) async {
    for (String time in times!) {
      String ticketID = '$userEmail-$day-$time';
      final existingDoc = await ticketsCollection.doc(ticketID).get();

      if (!existingDoc.exists) {
        await ticketsCollection.doc(ticketID).set({
          'dosen': userEmail,
          'day': day,
          'time': time,
          'available': true,
          // tambahkan properti lain yang mungkin kamu butuhkan
        });
      }
    }
  });
}

late String test;
late Map<String, List<String>?> scheduleFixed;

class _ConfirmScheduleState extends State<ConfirmSchedule> {
  late var _focusDate = DateTime.now();
  final EasyInfiniteDateTimelineController _controller =
      EasyInfiniteDateTimelineController();

  @override
  Widget build(BuildContext context) {
    final sunday = _getSunday(_focusDate);
    String formatedDate =
        DateTime.utc(_focusDate.year, _focusDate.month, _focusDate.day)
            .toString();
    test = formatedDate;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(
            height: 22,
          ),
          Container(
            padding: const EdgeInsets.only(left: 18, right: 21, top: 18),
            width: 390,
            height: 136,
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
            child: Column(children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "CREATE SCHEDULE",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hi, ${currentDosen['Name']!}",
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Please note that schedule updates can only be done once a week on Sunday.",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                  ),
                ),
              )
            ]),
          ),
          const SizedBox(
            height: 33,
          ),
          EasyInfiniteDateTimeLine(
            activeColor: Color(0xFF27374D),
            dayProps: const EasyDayProps(
              dayStructure: DayStructure.dayNumDayStr,
              height: 50,
              width: 80,
            ),
            controller: _controller,
            firstDate: sunday,
            focusDate: _focusDate,
            lastDate: sunday.add(const Duration(days: 6)),
            showTimelineHeader: false,
            onDateChange: (selectedDate) {
              setState(() {
                _focusDate = selectedDate;
              });
            },
          ),
          const SizedBox(
            height: 21,
          ),
          const Divider(
            thickness: 1,
            color: Colors.black12,
            indent: 30,
            endIndent: 30,
          ),
          const SizedBox(
            height: 11,
          ),
          Container(
            width: 360,
            height: 255,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(7),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ]),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (BuildContext context, int index) {
                if (scheduleFixed[formatedDate] != null) {
                  return _buildTimeTile(scheduleFixed[formatedDate]![index]);
                } else {
                  return _buildTimeTile("Kosong");
                }
              },
              itemCount: scheduleFixed[formatedDate]?.length,
            ),
          ),
          SizedBox(
            height: 200,
          ),
          GestureDetector(
            onTap: () async {
              await createTicketDocs(scheduleFixed);
              Navigator.pop(context);
            },
            child: Container(
              width: 350,
              height: 45,
              decoration: ShapeDecoration(
                  color: Color(0xFF27374D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
              child: Center(
                child: Text(
                  'CONIRM',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Quicksand',
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

Widget _buildTimeTile(String time) {
  return GestureDetector(
    child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(vertical: 2),
        width: 58,
        height: 30,
        decoration: ShapeDecoration(
          color: Color(0xFF27374D),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(fontFamily: 'Quicksand', color: Colors.white),
          ),
        )),
    onTap: () => print(test),
  );
}
