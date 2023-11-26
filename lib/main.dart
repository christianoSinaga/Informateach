// ignore_for_file: use_key_in_widget_constructors, avoid_print, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'dart:io';
import 'dart:typed_data';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:informateach/auth/auth.dart';
import 'package:informateach/createTicket.dart';
import 'package:informateach/dialog/cancelTicketDialog.dart';
import 'package:informateach/dosen/database/db.dart';
import 'package:informateach/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Uint8List? _image;
// late bool showBottomNavBar;
late bool showBottomNavBar;
late String idDosen;

Future<bool> editCurrentUserProfile(
    String name, String phone, String gender, String nim,
    [String? img]) async {
  User? user = FirebaseAuth.instance.currentUser;
  try {
    var userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: user?.email)
        .get();
    if (userQuery.docs.isNotEmpty) {
      var userDocument =
          userQuery.docs.first.reference; // Mendapatkan referensi dokumen
      if (img != null) {
        await userDocument.update({
          'Name': name,
          'Phone Number': phone,
          'Gender': gender,
          'NIM': nim,
          'Image': img,
        });
      } else {
        await userDocument.update({
          'Name': name,
          'Phone Number': phone,
          'Gender': gender,
          'NIM': nim,
        });
      }
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e);
    return false;
  }
}

Future<void> _checkPendingNotificationRequests() async {
  final List<PendingNotificationRequest> pendingNotificationRequests =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  print('${pendingNotificationRequests.length} pending notification ');

  for (PendingNotificationRequest pendingNotificationRequest
      in pendingNotificationRequests) {
    print(pendingNotificationRequest.id.toString() +
        " " +
        (pendingNotificationRequest.payload ?? ""));
  }
  print('NOW ' + tz.TZDateTime.now(tz.local).toString());
}

Future<void> cancellAllNotif() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> scheduleNotification({
  required String title,
  required String body,
  required int id,
  required String action,
  String? day,
  String? hour,
}) async {
  //KONFIGURASI NOTIFIKASI
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'tiket_2',
    'schedule_tiket',
    importance: Importance.high,
    priority: Priority.low,
  );
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  if (action == 'create') {
    List<String> dayOnly = day!.split(' ');
    DateTime formatedDate = DateTime.parse(dayOnly[0] + ' ' + hour!);
    DateTime fixDate = formatedDate.subtract(Duration(hours: 1));
    var scheduledTime = tz.TZDateTime.from(fixDate, tz.local);
    var time =
        tz.TZDateTime.from(DateTime.now().add(Duration(seconds: 5)), tz.local);
    //CREATE SCHEDULED NOTIFICATION
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Scheduled Notif',
      'Anda memiliki pertemuan 1 jam lagi. Ketuk untuk melihat lebih lanjut',
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '$scheduledTime',
    );
    print("Scheduled Notif Created");
  } else if (action == 'cancel') {
    //CANCEL SCHEDULED NOTIFICATION
    await flutterLocalNotificationsPlugin.cancel(id);
    print("Notification cancelled");
  }
}

Future<void> showNotification(String title, String body, int id) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'tiket_1', // Ganti dengan ID channel yang sesuai
    'notif_tiket', // Ganti dengan nama channel yang sesuai
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: 'your_custom_data', // Ganti dengan data kustom yang sesuai
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      "${message.data['action']} a notification with id : ${message.data['id']}");
  scheduleNotification(
    title: message.data['title'] ?? 'Default Title',
    body: message.data['body'] ?? 'Default Body',
    id: int.tryParse(message.data['id'] ?? '0') ?? 0,
    action: message.data['action'] ?? 'action',
    day: message.data['day'] ?? 'Default Day',
    hour: message.data['time'] ?? 'Default Time',
  );
  // Menampilkan notifikasi lokal
  showNotification(
    message.data['title'] ?? 'Notification Title',
    message.data['body'] ?? 'Notification Body',
    int.tryParse(message.data['id'] ?? '0') ?? 0,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  //RECEIVE NOTIFICATION
  //FOREGROUND SITUATION
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        "${message.data['action']} a notification with id : ${message.data['id']}");

    scheduleNotification(
      title: message.data['title'] ?? 'Default Title',
      body: message.data['body'] ?? 'Default Body',
      id: int.tryParse(message.data['id'] ?? '0') ?? 0,
      action: message.data['action'] ?? 'create',
      day: message.data['day'] ?? 'Default Day',
      hour: message.data['time'] ?? 'Default Time',
    );
    showNotification(
      message.data['title'] ?? 'Notification Title',
      message.data['body'] ?? 'Notification Body',
      int.tryParse(message.data['id'] ?? '0') ?? 0,
    );
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handling when the app is opened from a terminated state
    print('Message Opened App: ${message.notification?.body}');

    showNotification(
      message.notification?.title ?? 'Notification Title',
      message.notification?.body ?? 'Notification Body',
      int.tryParse(message.data['id'] ?? '0') ?? 0,
    );
  });

  //BACKGROUND SITUATION
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Auth(),
    );
  }
}

// ignore: must_be_immutable

class MyAppMahasiswaContainer extends StatelessWidget {
  const MyAppMahasiswaContainer({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyAppMahasiswa(
        initialPage: 0,
      ),
    );
  }
}

class MyAppMahasiswa extends StatefulWidget {
  final int initialPage;
  const MyAppMahasiswa({Key? key, required this.initialPage}) : super(key: key);

  @override
  State<MyAppMahasiswa> createState() => _MyAppMahasiswaState();
}

class _MyAppMahasiswaState extends State<MyAppMahasiswa> {
  var indexPage = 0;
  late final PageController _pageController;
  late final NotchBottomBarController _controller;

  Future<void> editCurrentUserToken(String token) async {
    User user = FirebaseAuth.instance.currentUser!;
    try {
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('Email', isEqualTo: user.email)
          .get();
      if (userQuery.docs.isNotEmpty) {
        var userDocument = userQuery.docs.first.reference;
        await userDocument.update({'Token': token});
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkDeviceToken() async {
    await getCurrentUser();
    final deviceToken = await FirebaseMessaging.instance.getToken();
    if (currentUser['Token'] != deviceToken) {
      await editCurrentUserToken(deviceToken!);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _controller = NotchBottomBarController(index: widget.initialPage);
    checkDeviceToken();
  }

  final List<Widget> bottomBarPages = [
    HomepageMahasiswa(),
    TicketMahasiswaPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            _controller.jumpTo(index);
            setState(() {
              indexPage = index;
            });
          },
          children: List.generate(
              bottomBarPages.length, (index) => bottomBarPages[index]),
        ),
        extendBody: true,
        bottomNavigationBar: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          onTap: (index) {
            _controller.jumpTo(index);
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 400),
                curve: Curves.decelerate);
            setState(() {
              indexPage = index;
            });
          },
          color: Colors.white,
          showLabel: false,
          notchColor: Colors.black87,
          bottomBarItems: const [
            BottomBarItem(
              inActiveItem: Icon(
                Icons.calendar_month,
                color: Colors.blueGrey,
              ),
              activeItem: Icon(
                Icons.calendar_month,
                color: Colors.blueAccent,
              ),
              itemLabel: 'Schedule',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.confirmation_number,
                color: Colors.blueGrey,
              ),
              activeItem: Icon(
                Icons.confirmation_number,
                color: Colors.blueAccent,
              ),
              itemLabel: 'Ticket',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.person,
                color: Colors.blueGrey,
              ),
              activeItem: Icon(
                Icons.person,
                color: Colors.blueAccent,
              ),
              itemLabel: 'Profile',
            )
          ],
        ));
  }
}

class HomepageMahasiswa extends StatefulWidget {
  @override
  _HomepageMahasiswaState createState() => _HomepageMahasiswaState();
}

Future<List<Map<String, dynamic>>> getListDosen() async {
  final CollectionReference dosenCollection =
      FirebaseFirestore.instance.collection('users');

  QuerySnapshot<Object?> querySnapshot =
      await dosenCollection.where('Student', isEqualTo: false).get();

  List<Map<String, dynamic>> dosenList = [];
  querySnapshot.docs.forEach((doc) {
    dosenList.add(doc.data() as Map<String, dynamic>);
  });

  return dosenList;
}

class _HomepageMahasiswaState extends State<HomepageMahasiswa> {
  late List<Map<String, dynamic>> listDosen = [];
  late TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredDosenList = [];

  Future<void> fetchDosenList() async {
    List<Map<String, dynamic>> dosen = await getListDosen();
    setState(() {
      listDosen = dosen;
      filteredDosenList = listDosen;
    });
  }

  void initState() {
    super.initState();
    fetchDosenList();
  }

  void filterDosenList(String query) {
    List<Map<String, dynamic>> filteredList = [];

    if (query.isNotEmpty) {
      filteredList = listDosen
          .where((dosen) =>
              dosen["Name"]!.toLowerCase().contains(query.toLowerCase()) ||
              dosen["NIM"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      filteredList = List.from(listDosen);
    }

    setState(() {
      filteredDosenList = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color.fromRGBO(39, 55, 77, .40),
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INFORMATEACH',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              background: Image.asset(
                "style/img/unesa 2.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (filteredDosenList.isEmpty) {
                  return Container(
                    margin: EdgeInsets.only(top: 19, left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Daftar Dosen",
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: 'Cari dosen...',
                                hintStyle: TextStyle(color: Colors.black),
                              ),
                              style: const TextStyle(color: Colors.black),
                              onChanged: (value) {
                                // Handle search query changes
                                filterDosenList(value);
                              },
                            ),
                          ),
                        ]),
                        Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Center(
                                child: Text(
                              "Dosen yang anda cari tidak tersedia",
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 20,
                              ),
                            ))),
                      ],
                    ),
                  );
                }
                final data = filteredDosenList[index];
                if (index == 0) {
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 19, left: 20, right: 20),
                        child: Row(children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              "Daftar Dosen",
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: 'Cari dosen...',
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Quicsand',
                              ),
                              onChanged: (value) {
                                // Handle search query changes
                                filterDosenList(value);
                              },
                            ),
                          ),
                        ]),
                      ),
                      GestureDetector(
                        onTap: () {
                          idDosen = data["Email"]!;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutDosen()),
                          );
                        },
                        child: Container(
                          width: 285,
                          height: 140,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(39, 55, 77, 1),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, .60),
                                offset: Offset(0, 1),
                                spreadRadius: 3,
                                blurRadius: 7,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  data["Image"] ?? 'style/img/DefaultIcon.png',
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
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      data["Name"]!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'Quicksand',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                    ),
                                    Text(
                                      data["NIM"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'Quicksand',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                } else if (index == listDosen.length - 1) {
                  return GestureDetector(
                      onTap: () {
                        idDosen = data["Email"]!;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutDosen()));
                      },
                      child: Container(
                        width: 160,
                        height: 138,
                        margin: const EdgeInsets.only(
                            top: 15, left: 50, bottom: 90, right: 50),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(39, 55, 77, 1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, .60),
                              offset: Offset(0, 1),
                              spreadRadius: 3,
                              blurRadius: 7,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data["Image"] ?? 'style/img/DefaultIcon.png',
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
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 38),
                                    child: Text(
                                      data["Name"]!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'Quicksand',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Text(
                                    data["NIM"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Quicksand',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                } else {
                  return GestureDetector(
                      onTap: () {
                        idDosen = data["Email"]!;
                        setState(() {
                          showBottomNavBar = false;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutDosen()));
                      },
                      child: Container(
                        width: 160,
                        height: 138,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(39, 55, 77, 1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, .60),
                              offset: Offset(0, 1),
                              spreadRadius: 3,
                              blurRadius: 7,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data["Image"] ?? 'style/img/DefaultIcon.png',
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
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 38),
                                    child: Text(
                                      data["Name"]!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'Quicksand',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Text(
                                    data["NIM"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Quicksand',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                }
              },
              childCount:
                  filteredDosenList.isEmpty ? 1 : filteredDosenList.length,
            ),
          ),
        ],
      ),
    );
  }
}

class AboutDosen extends StatefulWidget {
  const AboutDosen({Key? key}) : super(key: key);

  @override
  State<AboutDosen> createState() => _AboutDosenState();
}

// Future<Map<String, dynamic>> getSelectedDosen(String email) async {
//   try {
//     var dosenQuery = await FirebaseFirestore.instance
//         .collection('users')
//         .where('Email', isEqualTo: email)
//         .get();

//     if (dosenQuery.docs.isNotEmpty) {
//       Map<String, dynamic> dosenData = dosenQuery.docs.first.data();
//       return dosenData;
//     } else {
//       throw Exception("No Dosen Found");
//     }
//   } catch (e) {
//     print(e);
//     rethrow;
//   }
// }

class _AboutDosenState extends State<AboutDosen> {
  String idDosenNow = idDosen;
  Map<String, dynamic> selectedDosen = {'temp': 'temp'};
  Future<void> fetchSelectedDosen() async {
    Map<String, dynamic> selectedDosenTmp = await getSelectedDosen(idDosen);
    setState(() {
      selectedDosen = selectedDosenTmp;
    });
  }

  @override
  void initState() {
    super.initState();
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAppMahasiswa(initialPage: 0)));
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Center(
                child: Column(
          children: [
            Image.network(
              selectedDosen["Image"] ?? 'style/img/DefaultIcon.png',
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
            const SizedBox(
              height: 19,
            ),
            Container(
                width: 256,
                height: 44,
                margin: const EdgeInsets.all(0),
                decoration: ShapeDecoration(
                  color: const Color(0xFF27374D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadows: [
                    const BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    selectedDosen["Name"],
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                )),
            const SizedBox(
              height: 17,
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
                        child: const Text(
                      "ABOUT",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    )),
                    Image.asset("style/img/Line 2.png"),
                    GestureDetector(
                      child: Text(
                        "SCHEDULE",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.2),
                          fontSize: 20,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateTicket()));
                      },
                    )
                  ]),
            ),
            const SizedBox(
              height: 55,
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    margin: const EdgeInsets.only(
                      left: 35,
                    ),
                    child: const Text(
                      "Program Studi",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ))),
            Container(
              width: 325,
              height: 37,
              padding: const EdgeInsets.only(left: 10),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(selectedDosen["Prodi"] == null
                      ? 'Kosong'
                      : selectedDosen["Prodi"])),
            ),
            const SizedBox(
              height: 18,
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    margin: const EdgeInsets.only(
                      left: 35,
                    ),
                    child: const Text(
                      "NIP",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ))),
            Container(
              width: 325,
              height: 37,
              padding: const EdgeInsets.only(left: 10),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(selectedDosen["NIM"]!)),
            ),
            const SizedBox(
              height: 18,
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    margin: const EdgeInsets.only(
                      left: 35,
                    ),
                    child: const Text(
                      "NIDN",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ))),
            Container(
              width: 325,
              height: 37,
              padding: const EdgeInsets.only(left: 10),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(selectedDosen["NIDN"] == null
                      ? 'Kosong'
                      : selectedDosen["NIDN"])),
            ),
            const SizedBox(
              height: 18,
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    margin: const EdgeInsets.only(
                      left: 35,
                    ),
                    child: const Text(
                      "E-mail UNESA",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ))),
            Container(
              width: 325,
              height: 37,
              padding: const EdgeInsets.only(left: 10),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(selectedDosen["Email"]!)),
            ),
          ],
        ))));
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController,
      _phoneController,
      _genderController;
  final bool _isEditing = true;
  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  Future<String> uploadProfilePict(Uint8List image) async {
    User? user = FirebaseAuth.instance.currentUser;
    Reference ref =
        FirebaseStorage.instance.ref().child('userProfilePict/${user?.email}');
    UploadTask upload = ref.putData(image);
    TaskSnapshot snapshot = await upload;
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  void saveChanges() async {
    bool done;
    if (_image != null) {
      String img = await uploadProfilePict(_image!);
      done = await editCurrentUserProfile(_nameController.text,
          _phoneController.text, _genderController.text, "21051204033", img);
    } else {
      done = await editCurrentUserProfile(_nameController.text,
          _phoneController.text, _genderController.text, "21051204033");
    }
    ;

    if (done) {
      Navigator.pop(context);
    }
  }

  void cancelEdit() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: currentUser["Name"]!);
    _phoneController =
        TextEditingController(text: currentUser["Phone Number"]!);
    _genderController = TextEditingController(text: "Pria");
  }

  Future<bool> _onBackPressed() async {
    print('Tombol Back ditekan');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(left: 14, top: 11),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset('style/img/LogoInformateach.png'),
                )),
            Stack(
              children: [
                _image != null
                    ? Container(
                        margin: const EdgeInsets.only(top: 44),
                        child: ClipOval(
                          child: Image.memory(
                            _image!,
                            height: 180,
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                        ))
                    : Container(
                        margin: const EdgeInsets.only(top: 44),
                        child: ClipOval(
                            child: Image.asset(
                          'style/img/DefaultIcon.png',
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        )),
                      ),
                Positioned(
                  child: IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: selectImage,
                  ),
                  bottom: -10,
                  right: 4,
                )
              ],
            ),

            //Name User Container
            Container(
                margin: const EdgeInsets.only(left: 28, top: 45),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            //Phone Number Container
            const SizedBox(
              height: 15,
            ),
            Container(
                margin: const EdgeInsets.only(left: 28),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Phone Number",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: _phoneController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            //Gender User Container
            const SizedBox(
              height: 15,
            ),
            Container(
                margin: const EdgeInsets.only(left: 28),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Gender",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: DropdownButtonFormField(
                value: _genderController.text,
                items: ['Pria', 'Wanita'].map((String gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _genderController.text = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 68,
            ),

            //Save and Cancel Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    saveChanges();
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(115, 45),
                      backgroundColor: const Color.fromRGBO(82, 109, 130, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      )),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => cancelEdit(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(115, 45),
                    backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController,
      _phoneController,
      _genderController;
  final bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan nilai dari database atau sesuai kebutuhan
    _nameController = TextEditingController(text: currentUser['Name']);
    _phoneController = TextEditingController(text: currentUser['Phone Number']);
    _genderController = TextEditingController(
        text: currentUser['Gender'] == '' ? 'Kosong' : currentUser['Gender']);
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.only(left: 14, top: 11),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('style/img/LogoInformateach.png'),
              )),
          Stack(
            children: [
              currentUser['Image'] != null
                  ? Container(
                      margin: const EdgeInsets.only(top: 44),
                      child: ClipOval(
                        child: Image.network(
                          currentUser['Image']!,
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        ),
                      ))
                  : Container(
                      margin: const EdgeInsets.only(top: 44),
                      child: ClipOval(
                        child: Image.asset(
                          'style/img/DefaultIcon.png',
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ],
          ),

          //Name User Container
          Container(
              margin: const EdgeInsets.only(left: 28, top: 45),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Name",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                  ),
                ),
              )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            child: TextField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),

          //Phone Number Container
          const SizedBox(
            height: 15,
          ),
          Container(
              margin: const EdgeInsets.only(left: 28),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Phone Number",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                  ),
                ),
              )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            child: TextField(
              controller: _phoneController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),

          //Gender User Container
          const SizedBox(
            height: 15,
          ),
          Container(
              margin: const EdgeInsets.only(left: 28),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Gender",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                  ),
                ),
              )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            child: TextField(
              controller: _genderController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(
            height: 68,
          ),

          //Log Out Button and Edit Profile Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfilePage()));
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(115, 45),
                    backgroundColor: const Color.fromRGBO(82, 109, 130, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    )),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(115, 45),
                  backgroundColor: const Color.fromRGBO(39, 55, 77, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 150,
          )
        ],
      ),
    ));
  }
}

class TicketMahasiswaPage extends StatefulWidget {
  const TicketMahasiswaPage({super.key});

  @override
  State<TicketMahasiswaPage> createState() => _TicketMahasiswaPageState();
}

class _TicketMahasiswaPageState extends State<TicketMahasiswaPage> {
  late List<Map<String, dynamic>> listTicket = [];

  Future<List<Map<String, dynamic>>> getListTicket() async {
    final CollectionReference ticketCollection =
        FirebaseFirestore.instance.collection('tickets');
    QuerySnapshot<Object?> querySnapshot = await ticketCollection
        .where('studentEmail', isEqualTo: currentUser['Email'])
        .where('status', isEqualTo: 'Waiting for validation')
        .get();

    List<Map<String, dynamic>> ticketList = [];

    for (var ticketDoc in querySnapshot.docs) {
      var ticketData = ticketDoc.data() as Map<String, dynamic>;

      // Pastikan ada properti 'dosen' dalam data tiket sebelum melanjutkan
      if (ticketData.containsKey('dosen')) {
        var dosenQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('Email', isEqualTo: ticketData['dosen'])
            .get();

        // Pastikan ada dokumen pengguna (dosen) yang sesuai
        if (dosenQuery.docs.isNotEmpty) {
          var dosenData = dosenQuery.docs.first.data() as Map<String, dynamic>;

          // Tambahkan properti 'dosenNama' dan 'dosenGambar' ke tiket
          ticketData['dosenNama'] = dosenData['Name'];
          ticketData['dosenGambar'] = dosenData['Image'];
        }
      }

      // Tambahkan tiket ke daftar tiket
      ticketList.add(ticketData);
    }

    return ticketList;
  }

  Future<void> fetchTicketList() async {
    List<Map<String, dynamic>> tickets = await getListTicket();
    setState(() {
      listTicket = tickets;
    });
  }

  void initState() {
    super.initState();
    fetchTicketList();
  }

  @override
  Widget build(BuildContext context) {
    if (listTicket.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 30),
          Container(
            width: 458,
            height: 75,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                  blurRadius: 4,
                ),
              ],
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "AVAILABLE",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.asset("style/img/Line 2.png"),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryTicketPage())),
                  child: Text(
                    "HISTORY",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.2),
                      fontSize: 20,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Scaffold(
      body: ListView.builder(
        itemCount: listTicket.length,
        itemBuilder: ((context, index) {
          final data = listTicket[index];
          List<String> dayDetails = data['day'].toString().split(' ');
          String dayName = getDayName(data['day']);
          if (index == 0) {
            return Column(
              children: [
                Container(
                  width: 458,
                  height: 75,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                        blurRadius: 4,
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "AVAILABLE",
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset("style/img/Line 2.png"),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryTicketPage())),
                        child: Text(
                          "HISTORY",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.2),
                            fontSize: 20,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Tiket Container
                Container(
                  width: 338,
                  height: 123,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: Colors.white,
                    shadows: [
                      const BoxShadow(
                        color: Color(0x3F000000),
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(left: 11, right: 11, top: 14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data['dosenGambar'] ?? 'style/img/DefaultIcon.png',
                          height: 112,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Handle error loading image
                            return Image.asset(
                              'style/img/DefaultIcon.png',
                              width: 80,
                              height: 112,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 17,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 33),
                          Text(
                            data["dosenNama"]!,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$dayName, ${dayDetails[0]}, ${data['time']} WIB",
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            (data["purpose"] == '' || data["purpose"] == null)
                                ? "Tidak ada tujuan yang tertulis"
                                : data['purpose'],
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(width: 140),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(70, 15),
                                      padding: const EdgeInsets.all(0),
                                      backgroundColor:
                                          const Color.fromRGBO(39, 55, 77, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      )),
                                  onPressed: () {
                                    ticketMahasiswaCancel =
                                        "${data['dosen']}-${data['day']}-${data['time']}";
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CancelTicketDialog();
                                        });
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      color: Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              Container(
                width: 338,
                height: 123,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Colors.white,
                  shadows: [
                    const BoxShadow(
                      color: Color(0x3F000000),
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                      blurRadius: 4,
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(left: 11, right: 11, top: 14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['dosenGambar'] ?? 'style/img/DefaultIcon.png',
                        height: 112,
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'style/img/DefaultIcon.png',
                            width: 80,
                            height: 112,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 33),
                        Text(
                          data["dosenNama"]!,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$dayName, ${dayDetails[0]}, ${data['time']} WIB",
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          (data["purpose"] == '' || data["purpose"] == null)
                              ? "Tidak ada tujuan yang tertulis"
                              : data['purpose'],
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 10,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(width: 140),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(70, 15),
                                    padding: const EdgeInsets.all(0),
                                    backgroundColor:
                                        const Color.fromRGBO(39, 55, 77, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    )),
                                onPressed: () {
                                  ticketMahasiswaCancel =
                                      "${data['dosen']}-${data['day']}-${data['time']}";
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CancelTicketDialog();
                                      });
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class HistoryTicketPage extends StatefulWidget {
  const HistoryTicketPage({super.key});

  @override
  State<HistoryTicketPage> createState() => _HistoryTicketPageState();
}

class _HistoryTicketPageState extends State<HistoryTicketPage> {
  late List<Map<String, dynamic>> listTicket = [];

  //FUNCTIONS
  Future<List<Map<String, dynamic>>> getListTicket() async {
    final CollectionReference ticketCollection =
        FirebaseFirestore.instance.collection('tickets');
    QuerySnapshot<Object?> querySnapshot = await ticketCollection
        .where('studentEmail', isEqualTo: currentUser['Email'])
        .where('status', isNotEqualTo: 'Waiting for validation')
        .get();

    List<Map<String, dynamic>> ticketList = [];

    for (var ticketDoc in querySnapshot.docs) {
      var ticketData = ticketDoc.data() as Map<String, dynamic>;

      // Pastikan ada properti 'dosen' dalam data tiket sebelum melanjutkan
      if (ticketData.containsKey('dosen')) {
        var dosenQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('Email', isEqualTo: ticketData['dosen'])
            .get();

        // Pastikan ada dokumen pengguna (dosen) yang sesuai
        if (dosenQuery.docs.isNotEmpty) {
          var dosenData = dosenQuery.docs.first.data() as Map<String, dynamic>;

          // Tambahkan properti 'dosenNama' dan 'dosenGambar' ke tiket
          ticketData['dosen'] = dosenData['Name'];
          ticketData['dosenGambar'] = dosenData['Image'];
        }
      }

      // Tambahkan tiket ke daftar tiket
      ticketList.add(ticketData);
    }

    return ticketList;
  }

  Future<void> fetchTicketList() async {
    List<Map<String, dynamic>> tickets = await getListTicket();
    setState(() {
      listTicket = tickets;
    });
  }

  void initState() {
    super.initState();
    fetchTicketList();
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    if (listTicket.isEmpty) {
      return Scaffold(
        body: Column(children: [
          SizedBox(
            height: 40,
          ),
          Container(
            width: 458,
            height: 75,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                  blurRadius: 4,
                ),
              ],
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "AVAILABLE",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.2),
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.asset("style/img/Line 2.png"),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "HISTORY",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      );
    }
    return Scaffold(
      body: ListView.builder(
        itemCount: listTicket.length,
        itemBuilder: ((context, index) {
          final data = listTicket[index];
          List<String> dayDetails = data['day'].toString().split(' ');
          String dayName = getDayName(data['day']);

          if (index == 0) {
            return Column(
              children: [
                Container(
                  width: 458,
                  height: 75,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                        blurRadius: 4,
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "AVAILABLE",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.2),
                            fontFamily: 'Quicksand',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset("style/img/Line 2.png"),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "HISTORY",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Tiket Container
                Container(
                  width: 338,
                  height: 123,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: Colors.white,
                    shadows: [
                      const BoxShadow(
                        color: Color(0x3F000000),
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(left: 11, right: 11, top: 14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data["dosenGambar"] ?? 'style/img/DefaultIcon.png',
                          height: 112,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            //HANDLE ERROR IMAGE
                            return Image.asset(
                              'style/img/DefaultIcon.png',
                              width: 80,
                              height: 112,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 17,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 33),
                          Text(
                            data["dosen"]!,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$dayName, ${dayDetails[0]}, ${data['time']} WIB",
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            (data["purpose"] == '' || data["purpose"] == null)
                                ? "Tidak ada tujuan yang tertulis"
                                : data['purpose'],
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(
                            height: 19,
                          ),
                          Container(
                            width: 200,
                            alignment: Alignment.centerRight,
                            child: Text(
                              data["status"],
                              style: TextStyle(
                                  color: data["status"] == "Validated"
                                      ? const Color(0xFF0165FC)
                                      : const Color(0xFFFF0000),
                                  fontFamily: 'Quicksand',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              Container(
                width: 338,
                height: 123,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Colors.white,
                  shadows: [
                    const BoxShadow(
                      color: Color(0x3F000000),
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                      blurRadius: 4,
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(left: 11, right: 11, top: 14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data["dosenGambar"] ?? 'style/img/DefaultIcon.png',
                        height: 112,
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          //HANDLE ERROR IMAGE LOAD
                          return Image.asset(
                            'style/img/DefaultIcon.png',
                            width: 80,
                            height: 112,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 33),
                        Text(
                          data["dosen"]!,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$dayName, ${dayDetails[0]}, ${data['time']} WIB",
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          (data['purpose'] == '' || data['purpose'] == null)
                              ? "Tidak ada tujuan yang tertulis"
                              : data['purpose'],
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(
                          height: 19,
                        ),
                        Container(
                          width: 200,
                          alignment: Alignment.centerRight,
                          child: Text(
                            data["status"],
                            style: TextStyle(
                                color: data["status"] == "Validated"
                                    ? const Color(0xFF0165FC)
                                    : const Color(0xFFFF0000),
                                fontFamily: 'Quicksand',
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

////PAGE TEST/////
class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
