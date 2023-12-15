import 'package:flutter/material.dart';

void dialogErrorHandling(BuildContext context, String e) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 17),
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
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Error",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      e,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Quicksand'),
                    )),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(70, 15),
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
                    ))
              ],
            )),
      );
    },
  );
}
