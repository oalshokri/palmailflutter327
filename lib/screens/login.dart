import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/user.dart';
import 'package:untitled/screens/home.dart';
import 'package:untitled/widgets/buttons.dart';
import 'package:untitled/widgets/myAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_service.dart';
import '../utils/constant.dart';
import '../utils/email_validator.dart';
import 'guest.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _controller = ScrollController();
  bool isLoginSc = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool loading = false;

  void _registerUser() async {
    ApiResponse response = await register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
      return;
    } else {
      if (!mounted) return;
      setState(() {
        loading = !loading;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _loginUser() async {
    ApiResponse response = await login(
      _emailController.text,
      _passwordController.text,
    );
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
      return;
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
    showMessage(context, '${response.error}');
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    await pref.setString('userRole', user.role?.name ?? '');

    if (!mounted) return;
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
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -200,
            child: Container(
              height: 500,
              width: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: kPrimaryGradient,
              ),
            ),
          ),
          Positioned(
            top: 70,
            child: Image(
              width: 100,
              image: AssetImage('assets/image/logo_app3.png'),
            ),
          ),
          SingleChildScrollView(
            controller: _controller,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Container(
                  margin: const EdgeInsets.all(kSize16),
                  padding: const EdgeInsets.symmetric(
                      vertical: kSize64, horizontal: kSize56),
                  decoration: const BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.all(Radius.circular(60))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoginSignUpWithAnimation(
                        isLogin: isLoginSc,
                        isLoginFnc: () {
                          setState(() {
                            isLoginSc = !isLoginSc;
                          });
                        },
                      ),
                      SizedBox(
                        height: kSize56,
                      ),
                      LoginSignUpForm(
                        isLoginSc: isLoginSc,
                        loading: loading,
                        function: () {
                          if (isLoginSc) {
                            setState(() {
                              loading = true;
                              _loginUser();
                            });
                            return;
                          }
                          setState(() {
                            loading = true;
                            _registerUser();
                          });
                        },
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        passwordConfirmController: _passwordConfirmController,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          MyAppBar(controller: _controller, title: 'Login'.tr())
        ],
      ),
    );
  }
}

class LoginSignUpForm extends StatefulWidget {
  final Function()? function;
  final bool isLoginSc;
  final bool loading;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;

  const LoginSignUpForm(
      {Key? key,
      this.function,
      this.isLoginSc = true,
      required this.emailController,
      required this.nameController,
      required this.passwordController,
      required this.passwordConfirmController,
      required this.loading})
      : super(key: key);

  @override
  State<LoginSignUpForm> createState() => _LoginSignUpFormState();
}

class _LoginSignUpFormState extends State<LoginSignUpForm> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: Column(
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 750),
            firstChild: AnimatedOpacity(
              opacity: !widget.isLoginSc ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              child: TextFormField(
                controller: widget.nameController,
                decoration: kInputDecoration('Enter your name'.tr()),
                validator: (val) {
                  if (widget.isLoginSc) return null;
                  return val!.isEmpty ? 'your name is required'.tr() : null;
                  return null;
                },
              ),
            ),
            crossFadeState: !widget.isLoginSc
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: Container(),
            firstCurve: Curves.fastOutSlowIn,
            secondCurve: Curves.fastOutSlowIn,
          ),
          SizedBox(
            height: kSize24,
          ),
          TextFormField(
              controller: widget.emailController,
              decoration: kInputDecoration('Enter Email'.tr()),
              validator: (val) => validateEmail(val)),
          SizedBox(
            height: kSize24,
          ),
          TextFormField(
            controller: widget.passwordController,
            decoration: kInputDecoration('Password'.tr()),
            obscureText: true,
            validator: (val) =>
                val!.length < 6 ? 'Required at least 6 chars'.tr() : null,
          ),
          SizedBox(
            height: kSize24,
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 750),
            firstChild: AnimatedOpacity(
                opacity: !widget.isLoginSc ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastOutSlowIn,
                child: TextFormField(
                    controller: widget.passwordConfirmController,
                    decoration: kInputDecoration('Confirm Password'.tr()),
                    obscureText: true,
                    validator: (val) {
                      if (widget.isLoginSc) return null;
                      if (val != widget.passwordController.text) {
                        return 'Confirm password does not match'.tr();
                      }
                      return null;
                    })),
            crossFadeState: !widget.isLoginSc
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: Container(),
            firstCurve: Curves.fastOutSlowIn,
            secondCurve: Curves.fastOutSlowIn,
          ),
          SizedBox(
            height: kSize56,
          ),
          Row(
            children: [
              LoginBtn(
                loading: widget.loading,
                label: widget.isLoginSc ? 'Login'.tr() : 'SignUp'.tr(),
                colored: false,
                function: () {
                  if (formkey.currentState!.validate()) {
                    setState(() {
                      widget.function!();
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
