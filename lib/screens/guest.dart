import 'package:flutter/material.dart';

import '../utils/constant.dart';
import '../widgets/myAppBar.dart';
import 'login.dart';

class Guest extends StatefulWidget {
  const Guest({Key? key}) : super(key: key);

  @override
  _GuestState createState() => _GuestState();
}

class _GuestState extends State<Guest> {
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Padding(
          padding: EdgeInsets.only(top: kSize72, left: 40, right: 40),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'طلبك قيد المراجعة',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kSecondaryColor, fontSize: 20),
                ),
                const SizedBox(
                  width: 250,
                  child: Text('لمزيد من المعلومات، يرجى الاتصال بمسؤول النظام',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12)),
                ),
                SizedBox(
                  height: 34,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('تسجيل بحساب آخر:'),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                              (route) => false);
                        },
                        child: Text('تسجيل دخول'))
                  ],
                )
              ],
            ),
          ),
        ),
        MyAppBar(
          dynamicTitle: false,
          controller: _controller,
          title: 'زائر',
        ),
      ]),
    );
  }
}
