import 'package:flutter/material.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/user.dart';
import 'package:untitled/screens/login.dart';
import 'package:untitled/services/user_service.dart';

import '../utils/constant.dart';
import 'guest.dart';
import 'home.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void _loadingUserInfo() async {
    String token = await getToken();
    if (token == '') {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
      return;
    }
    ApiResponse response = await getUserDetail();

    if (response.error == null) {
      if (!mounted) return;
      User user = response.data as User;
      if (user.role?.name == 'guest') {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                settings: const RouteSettings(name: "/Guest"),
                builder: (context) => const Guest()),
            (route) => false);
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              settings: const RouteSettings(name: "/Home"),
              builder: (context) => Home()),
          (route) => false);
      return;
    }
    if (response.error == unauthorized) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${response.error}'),
      backgroundColor: kSecondaryColor,
      action: SnackBarAction(
        label: 'login',
        textColor: kWhite,
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => false);
        },
      ),
    ));
  }

  @override
  void initState() {
    _loadingUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: kBackground,
        child: Center(
            child: CircularProgressIndicator(
          color: kPrimaryColor,
        )),
      ),
    );
  }
}
