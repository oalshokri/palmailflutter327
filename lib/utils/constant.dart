// ----- STRINGS ------
import 'package:flutter/material.dart';

// const baseURL = 'http://127.0.0.1:8000/api';
const baseURL = 'http://palmail.gazawar.wiki/api';
// const storageUrl = 'http://127.0.0.1:8000/storage';
const storageUrl = 'http://palmail.gazawar.wiki/';
const loginURL = '$baseURL/login';
const registerURL = '$baseURL/register';
const logoutURL = '$baseURL/logout';
const userURL = '$baseURL/user';
const usersURL = '$baseURL/users';
const mailsURL = '$baseURL/mails';
const sendersURL = '$baseURL/senders';
const activitiesURL = '$baseURL/activities';
const rolesURL = '$baseURL/roles';
const categoriesURL = '$baseURL/categories';
const statusesURL = '$baseURL/statuses';
const tagsURL = '$baseURL/tags';
const attachmentUrl = '$baseURL/attachments';
const searchUrl = '$baseURL/search';

// ----- Errors -----
const serverError = 'Server error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';

//My Colors System
const kPrimaryColor = Color(0xff003afc);
const kSecondaryColor = Color(0xff6589ff);
const kWhite = Color(0xffffffff);
const kRed = Color(0xfffa3a57);
const kYellow = Color(0xffffe120);
const kGreen = Color(0xff77d16f);
const kBlack = Color(0xff272727);
const kBackground = Color(0xfff7f6ff);
const kGray70 = Color(0xff7c7c7c);
const kGray50 = Color(0xffb2b2b2);
const kGray10 = Color(0xffe6e6e6);
Color kShadow = const Color(0xffcdccf1).withOpacity(0.3);

//My Gradient System
const kPrimaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [kPrimaryColor, kSecondaryColor]);

//My 8 Sizing System
const kSize8 = 8.0;
const kSize16 = 16.0;
const kSize24 = 24.0;
const kSize32 = 32.0;
const kSize40 = 40.0;
const kSize48 = 48.0;
const kSize56 = 56.0;
const kSize64 = 64.0;
const kSize72 = 72.0;
const kSize80 = 80.0;

// --- input decoration
InputDecoration kInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: kGray50),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: kSecondaryColor, width: 2),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: kGray50),
    ),
  );
}

//snackbar
showMessage(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: kSecondaryColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      // behavior: SnackBarBehavior.floating,
      // margin: EdgeInsets.only(bottom: 16, right: 16, left: 16),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
    ),
  );
}
