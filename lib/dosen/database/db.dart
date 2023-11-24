import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:informateach/createTicket.dart';

late Map<String, dynamic> currentDosen;
late Map<String, dynamic> currentUser;

Future getCurrentDosen() async {
  User? user = FirebaseAuth.instance.currentUser;
  try {
    var dosenQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: user?.email)
        .get();
    if (dosenQuery.docs.isNotEmpty) {
      var dosenData = dosenQuery.docs.first.data();
      currentDosen = dosenData;
    } else {
      print('Data kosong');
    }
  } catch (e) {
    print(e);
  }
}

Future getCurrentUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  try {
    var dosenQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: user?.email)
        .get();
    if (dosenQuery.docs.isNotEmpty) {
      var userData = dosenQuery.docs.first.data();
      currentUser = userData;
    } else {
      print('Data kosong');
    }
  } catch (e) {
    print(e);
  }
}
