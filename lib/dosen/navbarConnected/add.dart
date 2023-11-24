import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:informateach/confirmTicket.dart';
import 'package:informateach/dosen/confirmSchedule.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/dosen/navbarConnected/profile.dart';

class AddTicket extends StatefulWidget {
  const AddTicket({super.key});

  @override
  State<AddTicket> createState() => _AddTicketState();
}

DateTime _getSunday(DateTime date) {
  int weekday = date.weekday;
  if (weekday == 7) return date;
  return date.subtract(Duration(days: weekday));
}

String _getDayName(String datePerWeek) {
  switch (datePerWeek) {
    case "1":
      return "Monday";
    case "2":
      return "Tuesday";
    case "3":
      return "Wednesday";
    case "4":
      return "Thursday";
    case "5":
      return "Friday";
    case "6":
      return "Saturday";
    case "7":
      return "Sunday";
    default:
      return "Salah";
  }
}

class SelectedTime {
  final DateTime date;
  final String time;

  SelectedTime({required this.date, required this.time});
}

class _AddTicketState extends State<AddTicket> {
  List<String> selectedTimes = [];
  List<String> availableTimes = List.generate(
      11, (index) => (index + 7).toString().padLeft(2, '0') + ':00');
  final EasyInfiniteDateTimelineController _controller =
      EasyInfiniteDateTimelineController();
  late var _focusDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final sunday = _getSunday(_focusDate);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    "Hi, ${currentDosen["Name"]!}",
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
                    side: const BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(7),
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
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildTimeTile(availableTimes[index]);
                  },
                  itemCount: availableTimes.length,
                )),
            const SizedBox(
              height: 80,
            ),
            GestureDetector(
              onTap: () {
                Map<String, List<String>?> selectedTimesMap = {};
                List<String> dates = [];
                for (int i = 0; i < 7; i++) {
                  String selectedDate = DateTime.utc(
                          sunday.add(Duration(days: i)).year,
                          sunday.add(Duration(days: i)).month,
                          sunday.add(Duration(days: i)).day)
                      .toString();
                  dates.add(
                      '${sunday.add(Duration(days: i)).weekday.toString()}, $selectedDate');
                }
                dates.forEach((date) {
                  List<String> dateSplit = date.split(", ");
                  String day = dateSplit[1];
                  selectedTimesMap[day] = [];
                  selectedTimes.forEach((time) {
                    List<String> timeSplit = time.split(", ");
                    String dateNow = timeSplit[0];
                    String timeNow = timeSplit[1];
                    if (dateNow == day) {
                      selectedTimesMap[day]?.add(timeNow);
                    }
                  });
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ConfirmSchedule()));
                scheduleFixed = selectedTimesMap;
              },
              child: Container(
                  width: 329,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: Color(0xFF27374D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
            ),
            SizedBox(
              height: 150,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile(String time) {
    bool isSelected = selectedTimes.contains(
        '${DateTime.utc(_focusDate.year, _focusDate.month, _focusDate.day)}, ${time}');

    return GestureDetector(
        onTap: () {
          setState(() {
            setState(() {
              if (isSelected) {
                selectedTimes.remove(
                    '${DateTime.utc(_focusDate.year, _focusDate.month, _focusDate.day)}, ${time}');
              } else {
                selectedTimes.add(
                    '${DateTime.utc(_focusDate.year, _focusDate.month, _focusDate.day)}, ${time}');
              }
            });
          });
        },
        child: Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.symmetric(vertical: 2),
            width: 58,
            height: 30,
            decoration: ShapeDecoration(
              color: isSelected ? Color(0xFF27374D) : Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: isSelected ? Colors.white : Colors.black),
              ),
            )));
  }
}
