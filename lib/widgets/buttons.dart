import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utils/constant.dart';

const borderRadius = BorderRadius.all(Radius.circular(30));

class LoginBtn extends StatelessWidget {
  final String label;
  final double? padding;
  final bool colored;
  final Function()? function;

  final bool loading;
  const LoginBtn({
    Key? key,
    required this.label,
    this.padding,
    required this.colored,
    this.function,
    this.loading = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: !colored ? kPrimaryGradient : null,
          color: colored ? kPrimaryColor : null,
          borderRadius: borderRadius,
        ),
        child: TextButton(
          onPressed: function,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: padding ?? kSize16,
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kWhite,
                    ),
                  ),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  // style: TextStyle(
                  //     color: white, fontSize: 14, fontWeight: FontWeight.w600),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.apply(color: kWhite),
                ),
        ),
      ),
    );
  }
}

class TextBtn extends StatelessWidget {
  final String label;
  final double? padding;
  final Function()? function;
  const TextBtn({Key? key, required this.label, this.padding, this.function})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(borderRadius: borderRadius),
      child: TextButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
              vertical: padding ?? kSize8, horizontal: kSize8),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(
          label,
          textAlign: TextAlign.start, overflow: TextOverflow.visible,
          softWrap: false,
          // style: TextStyle(
          //     color: primaryColor,
          //     fontSize: 14,
          //     fontWeight: FontWeight.normal),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.apply(color: kPrimaryColor),
        ),
      ),
    );
  }
}

class LoginSignUp extends StatelessWidget {
  final bool login;
  final Function()? loginFnc;
  final Function()? signUpFnc;
  const LoginSignUp(
      {Key? key, required this.login, this.loginFnc, this.signUpFnc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: kGray10, width: 1),
      ),
      child: Row(
        children: [
          login
              ? LoginBtn(
                  label: 'Login',
                  padding: kSize16,
                  colored: true,
                )
              : TextBtn(
                  label: 'Login',
                  padding: kSize16,
                  function: loginFnc,
                ),
          !login
              ? LoginBtn(
                  label: 'SignUp',
                  padding: kSize16,
                  colored: true,
                )
              : TextBtn(
                  label: 'SignUp',
                  padding: kSize16,
                  function: signUpFnc,
                )
        ],
      ),
    );
  }
}

class LoginSignUpWithAnimation extends StatelessWidget {
  final bool isLogin;
  final Function()? isLoginFnc;
  const LoginSignUpWithAnimation({
    Key? key,
    required this.isLogin,
    this.isLoginFnc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          width: constraint.maxWidth,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: kGray10, width: 1),
          ),
          child: Stack(children: [
            AnimatedAlign(
              // alignment: selected ? Alignment.topRight : Alignment.bottomLeft,
              alignment: context.locale.languageCode == 'en'
                  ? isLogin
                      ? Alignment.centerLeft
                      : Alignment.centerRight
                  : isLogin
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              child: Container(
                width: constraint.maxWidth / 2,
                height: 32,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: borderRadius,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: constraint.maxWidth * 0.495,
                  height: 32,
                  child: TextButton(
                    onPressed: !isLogin ? isLoginFnc : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: kSize8,
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                          borderRadius: borderRadius),
                    ),
                    child: AnimatedDefaultTextStyle(
                      style: TextStyle(
                          color: isLogin ? kWhite : kPrimaryColor,
                          fontWeight:
                              isLogin ? FontWeight.w500 : FontWeight.normal),
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      child: Text(
                        'Login'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: constraint.maxWidth * 0.495,
                  height: 32,
                  child: TextButton(
                    onPressed: isLogin ? isLoginFnc : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: kSize8,
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                          borderRadius: borderRadius),
                    ),
                    child: AnimatedDefaultTextStyle(
                      style: TextStyle(
                          color: !isLogin ? kWhite : kPrimaryColor,
                          fontWeight:
                              !isLogin ? FontWeight.w500 : FontWeight.normal),
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      child: Text(
                        'SignUp'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        );
      },
    );
  }
}
