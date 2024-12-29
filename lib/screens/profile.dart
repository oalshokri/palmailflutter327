import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/user.dart';
import 'package:untitled/widgets/buttons.dart';

import '../services/user_service.dart';
import '../utils/constant.dart';
import '../widgets/myAppBar.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool loading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? _imageFile;
  final _picker = ImagePicker();
  TextEditingController txtNameController = TextEditingController();
  final _controller = ScrollController();
  String message = 'Loading...';
  Future getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // get user detail
  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = false;
        txtNameController.text = user!.name ?? '';
        print(user?.image);
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      if (!mounted) return;
      showMessage(context, '${response.error}');
    }
  }

  //update profile
  void updateProfile() async {
    ApiResponse response =
        await updateWithImage(txtNameController.text, _imageFile);
    setState(() {
      loading = false;
    });
    if (response.error == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showMessage(context, '${response.data}');
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      if (!mounted) return;
      showMessage(context, '${response.error}');
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(message)
                ],
              ),
            )
          : Stack(children: [
              Padding(
                padding: EdgeInsets.only(top: kSize72, left: 40, right: 40),
                child: ListView(
                  children: [
                    Center(
                        child: GestureDetector(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            image: _imageFile == null
                                ? user!.image != ''
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            '$storageUrl/${user!.image}'),
                                        fit: BoxFit.cover)
                                    : const DecorationImage(
                                        image: AssetImage(
                                            'assets/image/upload_image_icon.jpeg'),
                                        fit: BoxFit.contain)
                                : DecorationImage(
                                    image: FileImage(_imageFile ?? File('')),
                                    fit: BoxFit.cover),
                            color: Colors.amber),
                      ),
                      onTap: () {
                        getImage();
                      },
                    )),
                    SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        decoration: kInputDecoration('Name'),
                        controller: txtNameController,
                        validator: (val) =>
                            val!.isEmpty ? 'Invalid Name' : null,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextBtn(
                      label: 'Update',
                      function: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                            message = 'Updating User...';
                          });
                          updateProfile();
                        }
                      },
                    )
                  ],
                ),
              ),
              MyAppBar(
                dynamicTitle: false,
                controller: _controller,
                title: 'Profile',
                leading: IconButton(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  icon: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: kBlack,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ]),
    );
  }
}
