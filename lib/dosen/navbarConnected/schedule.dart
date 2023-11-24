// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:informateach/dosen/dialog/cancel.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/dosen/dialog/validate.dart';

class ScheduleDosen extends StatefulWidget {
  const ScheduleDosen({super.key});

  @override
  State<ScheduleDosen> createState() => _ScheduleDosenState();
}

class _ScheduleDosenState extends State<ScheduleDosen> {
  //LIST YANG AKAN DITAMPILKAN KE INTERFACE
  late List<Map<String, dynamic>> listTicket = [];
  late List<String> dates = [];

  //FUNGSI FUNGSI BANTUAN YANG DIPERLUKAN
  //FUNGSI UNTUK MENDAPATKAN TIKET BERDASARKAN HARI
  Future<List<Map<String, dynamic>>> getListTicket() async {
    await getCurrentDosen();
    final CollectionReference ticketCollection =
        FirebaseFirestore.instance.collection('tickets');

    QuerySnapshot<Object?> querySnapshot = await ticketCollection
        .where('dosen', isEqualTo: currentDosen['Email'])
        .get();

    List<Map<String, dynamic>> listTicketTmp = [];

    for (var ticketDoc in querySnapshot.docs) {
      var ticketData = ticketDoc.data() as Map<String, dynamic>;
      List<String> dateDetails = ticketData['day'].toString().split(' ');
      String dayName = getDayName(ticketData['day'].toString());
      ticketData['formatedDate'] = "$dayName, ${dateDetails[0]}";

      //MENGUBAH FORMAT EMAIL MAHASISWA MENJADI NAMA
      if (ticketData.containsKey('studentEmail')) {
        var studentQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('Email', isEqualTo: ticketData['studentEmail'])
            .get();
        if (studentQuery.docs.isNotEmpty) {
          var studentData =
              studentQuery.docs.first.data() as Map<String, dynamic>;

          ticketData['studentName'] = studentData['Name'];
          ticketData['studentNim'] = studentData['NIM'];
        }
      }

      listTicketTmp.add(ticketData);
    }

    return listTicketTmp;
  }

  Future<void> fetchListTicket() async {
    List<Map<String, dynamic>> tickets = await getListTicket();
    // print(tickets);
    setState(() {
      listTicket = tickets;
    });
  }

  //FUNGSI UNTUK MENDAPATKAN LIST HARI
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

  DateTime _getSunday(DateTime date) {
    int weekday = date.weekday;
    if (weekday == 7) return date;
    return date.subtract(Duration(days: weekday));
  }

  void getCurrentWeek() {
    List<String> currentWeek = [];
    var now = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    var sunday = _getSunday(now);
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = sunday.add(Duration(days: i));
      List<String> dateDetails = currentDay.toString().split(' ');
      String dayName = getDayName(currentDay.toString());
      currentWeek.add("$dayName, ${dateDetails[0]}");
    }
    setState(() {
      dates = currentWeek;
    });
  }

  //STATES MANAGEMENT
  @override
  void initState() {
    super.initState();
    getCurrentWeek();
    fetchListTicket();
  }

  @override
  Widget build(BuildContext context) {
    getCurrentDosen();
    fetchListTicket();
    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          backgroundColor: const Color.fromRGBO(29, 55, 77, .4),
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              "INFORMATEACH",
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Image.asset(
              "style/img/unesa 2.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final dateData = dates[index];
                // final data = listTicket[index];
                // return Text(data['day']);
                return _buildTimeSlot(dateData, listTicket);
              },
              childCount: dates.length,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTimeSlot(String time, List<Map<String, dynamic>> tickets) {
    late List<Map<String, dynamic>> ticketTmp = [];
    for (var ticket in tickets) {
      if (ticket['formatedDate'] == time) {
        ticketTmp.add(ticket);
      }
    }
    return Column(
      children: [
        SizedBox(
          height: 19,
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
        SizedBox(
          height: 19,
        ),
        (ticketTmp.isEmpty)
            ? Text(
                "Tidak ada tiket untuk hari ini",
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              )
            : Column(
                children:
                    ticketTmp.map((ticket) => _buildTicket(ticket)).toList(),
              ),
      ],
    );
  }

  Widget _buildTicket(Map<String, dynamic> ticket) {
    return Container(
      width: 323,
      height: 80,
      margin: EdgeInsets.only(bottom: 15),
      decoration: ShapeDecoration(
        color: Color.fromARGB(255, 235, 240, 245),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: [
          BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0)
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 17,
          ),
          Text(
            ticket['time'],
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 14),
          VerticalDivider(
            color: Colors.black,
            thickness: 1,
            indent: 5,
            endIndent: 5,
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 5,
              ),
              Text(
                ticket['studentName'] == null
                    ? "Tiket Masih Kosong"
                    : ticket['studentName'],
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                ticket['studentNim'] == null ? "" : ticket['studentNim'],
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                ),
              ),
              Text(
                (ticket['purpose'] == null)
                    ? ""
                    : (ticket['purpose'] == "")
                        ? "Tujuan tidak tertulis"
                        : ticket['purpose'],
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: (ticket['status'] == 'Waiting for validation')
                    ? [
                        SizedBox(
                          width: 65,
                        ),
                        GestureDetector(
                          onTap: () {
                            ticketDoc =
                                "${ticket['dosen']}-${ticket['day']}-${ticket['time']}";
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ValidateTicketDialog();
                                });
                          },
                          child: Container(
                            width: 78,
                            height: 16,
                            decoration: ShapeDecoration(
                                color: Color(0xFF27374D),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            child: Text(
                              "Validate",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3687E5),
                                  fontSize: 12),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            ticketCancelDoc =
                                "${ticket['dosen']}-${ticket['day']}-${ticket['time']}";
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CancelTicketDialog();
                                });
                          },
                          child: Container(
                            width: 60,
                            height: 16,
                            decoration: ShapeDecoration(
                                color: Color(0xFF27374D),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                            child: Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF0000),
                                  fontSize: 12),
                            ),
                          ),
                        )
                      ]
                    : (ticket['status'] == 'Validated' ||
                            ticket['status'] == 'Cancelled')
                        ? [
                            SizedBox(
                              width: 140,
                            ),
                            Text("${ticket['status']}",
                                style: TextStyle(
                                    color: ticket['status'] == 'Validated'
                                        ? const Color(0xFF0165FC)
                                        : const Color(0xFFFF0000),
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w600)),
                          ]
                        : [
                            SizedBox(
                              width: 150,
                            ),
                            Container(
                              width: 60,
                              height: 16,
                              decoration: ShapeDecoration(
                                  color: Color(0xFF27374D),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              child: Text(
                                "Delete",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF0000),
                                    fontSize: 12),
                              ),
                            )
                          ],
              )
            ],
          )
        ],
      ),
    );
  }
}
