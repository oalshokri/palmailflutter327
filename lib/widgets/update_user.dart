import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/user.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/state/state_manager.dart';

import '../screens/login.dart';
import '../services/role_service.dart';
import '../utils/constant.dart';

class UpdateUser extends StatefulWidget {
  final User user;
  const UpdateUser({Key? key, required this.user}) : super(key: key);

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  late int dropdownValue;
  bool loading = false;
  String message = 'Loading...';

  void _updateUserRole() async {
    ApiResponse response = await updateUserRole(dropdownValue, widget.user.id);
    if (response.error == null) {
      if (!mounted) return;
      Navigator.of(context).pop('updated');
      var data = response.data;
      showMessage(context, '$data');
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      if (!mounted) return;
      showMessage(context, '${response.error}');
    }

    setState(() {
      loading = !loading;
    });
  }

  @override
  void initState() {
    if (widget.user.role != null) {
      dropdownValue = widget.user.role?.id! ?? 4;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
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
        : Padding(
            padding:
                const EdgeInsets.symmetric(vertical: kSize16, horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              loading = true;
                              message = 'Updating User role...';
                            });
                            _updateUserRole();
                          },
                          child: const Text('done'))
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  widget.user.image != ''
                      ? CircleAvatar(
                          radius: kSize48,
                          backgroundImage:
                              NetworkImage('$storageUrl/${widget.user.image!}'))
                      : const CircleAvatar(
                          radius: kSize48,
                          backgroundImage:
                              AssetImage('assets/image/avatar@3x.png'),
                        ),
                  const SizedBox(
                    height: kSize8,
                  ),
                  SizedBox(
                    width: 250,
                    child: Text(
                      widget.user.name ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: kSize8,
                  // ),
                  // Text(
                  //   '- ${widget.user.role?.name ?? ''} -',
                  //   style: TextStyle(color: kGray70),
                  // ),
                  Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final rolesFuture = ref.watch(rolesStateFuture);
                      return rolesFuture.when(
                        data: (roles) {
                          return DropdownButton<int>(
                            value: dropdownValue,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: kGray50,
                            ),
                            elevation: 16,
                            style: const TextStyle(color: kSecondaryColor),
                            // underline: Container(
                            //   height: 2,
                            //   color: Colors.deepPurpleAccent,
                            // ),
                            onChanged: (int? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: roles
                                .map<DropdownMenuItem<int>>((dynamic value) {
                              return DropdownMenuItem<int>(
                                value: value.id,
                                child: Text(value.name ?? ''),
                              );
                            }).toList(),
                          );
                        },
                        loading: () {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          );
                        },
                        error: (Object error, StackTrace? stackTrace) {
                          return Text(error.toString());
                        },
                      );
                    },
                  ),

                  // SizedBox(
                  //   height: kSize24,
                  // )
                ],
              ),
            ),
          );
  }
}
