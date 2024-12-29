import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:untitled/models_live/activity.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/category.dart';
import 'package:untitled/models_live/sender.dart';
import 'package:untitled/models_live/status.dart';
import 'package:untitled/screens/category_selector.dart';
import 'package:untitled/screens/status_selector.dart';
import 'package:untitled/services/sender_service.dart';
import 'package:untitled/widgets/myAppBar.dart';

import '../services/mail_services.dart';
import '../services/user_service.dart';
import '../state/state_manager.dart';
import '../utils/constant.dart';
import '../widgets/myExpansionTile.dart';
import 'login.dart';
import 'sender_search.dart';
import 'tag_selector.dart';

class NewInbox extends StatefulWidget {
  final Function()? cancel;
  final Function()? done;
  const NewInbox({Key? key, this.cancel, this.done}) : super(key: key);

  @override
  State<NewInbox> createState() => _NewInboxState();
}

class _NewInboxState extends State<NewInbox> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ScrollController scrollController = ScrollController();
  final TextEditingController _senderCnt = TextEditingController();
  final TextEditingController _mobileCnt = TextEditingController();
  final TextEditingController _titleCnt = TextEditingController();
  final TextEditingController _descriptionCnt = TextEditingController();
  final TextEditingController _archiveCnt = TextEditingController();
  final TextEditingController _decisionCnt = TextEditingController();
  final TextEditingController _newActivityCnt = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool _loading = false;

  MailCategory? category;
  Sender? sender;
  List<int> tags = [];
  Status status = Status(id: 1, name: 'Inbox', color: '0xfffa3a57');
  List<Activity> activities = [];

  List<XFile>? _imageFileList;
  File? _imageFile;
  final _picker = ImagePicker();
  dynamic _pickImageError;

  Future<void> getImage() async {
    try {
      // final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      final List<XFile>? pickedFileList = await _picker.pickMultiImage();

      // if (pickedFile != null) {
      //   setState(() {
      //     _imageFile = File(pickedFile.path);
      //   });
      //   print(_imageFile);
      // }
      if (pickedFileList != null) {
        setState(() {
          _imageFileList = pickedFileList;
        });
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  void _createMail() async {
    bool haveSender = false;
    if (sender == null) {
      print('category?.id : ${category?.id}');
      haveSender = await _createSender({
        'name': _senderCnt.text,
        'mobile': _mobileCnt.text,
        'category_id': '${category?.id ?? 1}',
        'address': 'address'
      });
      print('haveSender in create mail: $haveSender');
    }

    if (haveSender || sender != null) {
      List<Map<String, dynamic>> tempActivities = [];
      for (var element in activities) {
        tempActivities.add({'body': element.body, 'user_id': element.userId});
      }
      print('sendder id: ${sender?.id}');
      Map<String, dynamic> mailBody = {
        'sender_id': sender?.id.toString(),
        'subject': _titleCnt.text,
        'description': _descriptionCnt.text,
        'archive_number': _archiveCnt.text,
        'archive_date': selectedDate.toString().toString(),
        'decision': _decisionCnt.text,
        'status_id': status.id.toString(),
        'final_decision': _decisionCnt.text,
        'tags': tags.isNotEmpty ? jsonEncode(tags) : '',
        'activities': activities.isNotEmpty ? jsonEncode(tempActivities) : ''
      };

      ApiResponse response = await createMail(mailBody, _imageFileList);

      if (response.error == null) {
        Navigator.of(context).pop();
        var data = response.data as Map<String, dynamic>;
        showMessage(context, '${data['message']}');
      } else if (response.error == unauthorized) {
        logout().then((value) => {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false)
            });
      } else {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text('${response.error}')));
        showMessage(context, '${response.error}');
      }
    }
    setState(() {
      _loading = !_loading;
    });
  }

  Future<bool> _createSender(Map<String, dynamic> body) async {
    ApiResponse response = await createSender(body);
    if (response.error == null) {
      var data = response.data as Map<String, dynamic>;
      sender = Sender.fromJson(data['sender'][0]);
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('${data['message']}')));
      showMessage(context, '${data['message']}');
      return true;
    }
    if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    }
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text('${response.error}')));
    showMessage(context, '${response.error}');

    return false;
  }

  _onClickCategory(bool val) async {
    await showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (context) => CategorySelector(category: null),
    ).then((value) => setState(() {
          category = value;
          print(category?.toJson().toString());
        }));
  }

  _onClickTag(bool val) async {
    await showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (context) => TagSelector(tags: tags),
    ).then((value) => setState(() {
          tags = value;
        }));
    for (var element in tags) {
      print(element);
    }
  }

  _onClickStatus(bool val) async {
    await showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (context) => StatusSelector(
        status: status,
      ),
    ).then((value) => setState(() {
          status = value;
        }));
  }

  _onClickSenderInfo() async {
    await showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (context) => SenderSearch(),
    ).then((value) => setState(() {
          if (value['founded']) {
            sender = value['sender'];
            _senderCnt.text = sender?.name ?? '';
            _mobileCnt.text = sender?.mobile ?? '';
            category = value['sender'].category;
          } else {
            sender = null;
            category = null;
            _senderCnt.text = value['sender'];
            _mobileCnt.text = '';
          }
        }));
  }

  @override
  void dispose() {
    _senderCnt.dispose();
    _mobileCnt.dispose();
    _titleCnt.dispose();
    _descriptionCnt.dispose();
    _archiveCnt.dispose();
    _decisionCnt.dispose();
    _newActivityCnt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: kBackground, borderRadius: BorderRadius.circular(10)),
      height: MediaQuery.of(context).size.height - 34,
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10), topLeft: Radius.circular(10)),
        child: Scaffold(
          backgroundColor: kBackground,
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              height: kSize64,
                            ),

                            //sender,mobile and category
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  color: sender != null ? kBackground : kWhite,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                children: [
                                  TextFormField(
                                    readOnly: sender != null ? true : false,
                                    validator: (val) {
                                      return val!.isEmpty
                                          ? 'Enter Sender Name'.tr()
                                          : null;
                                    },
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    controller: _senderCnt,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 16),
                                      hintText: 'Sender'.tr(),
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        color: kGray50,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.info_outline_rounded,
                                          color: kSecondaryColor,
                                        ),
                                        onPressed: _onClickSenderInfo,
                                      ),
                                      border: InputBorder.none,

                                      // focusColor: gray10,
                                    ),
                                  ),
                                  const Divider(
                                    indent: 16,
                                    height: 0,
                                  ),
                                  TextFormField(
                                    readOnly: sender != null ? true : false,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return 'Enter Mobile Number'.tr();
                                      }
                                      return val.length < 10
                                          ? 'must be valid number: 10 digits'
                                              .tr()
                                          : null;
                                    },
                                    maxLines: null,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    controller: _mobileCnt,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 16),
                                      hintText: 'Mobile'.tr(),
                                      prefixIcon: Icon(
                                        Icons.phone_iphone_rounded,
                                        color: kGray50,
                                      ),
                                      // suffixIcon: IconButton(
                                      //   icon: Icon(
                                      //     Icons.info_outline_rounded,
                                      //     color: kSecondaryColor,
                                      //   ),
                                      //   onPressed: () {
                                      //     setState(() {
                                      //       // _searchCnt.clear();
                                      //     });
                                      //   },
                                      // ),
                                      border: InputBorder.none,

                                      // focusColor: gray10,
                                    ),
                                  ),
                                  const Divider(
                                    indent: 16,
                                    height: 0,
                                  ),
                                  Material(
                                    color:
                                        sender != null ? kBackground : kWhite,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30),
                                    ),
                                    child: MyExpansionTile(
                                      onExpansionChanged: _onClickCategory,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(30),
                                        ),
                                      ),
                                      tilePadding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      count: SizedBox(),
                                      isEnabled: sender != null ? false : true,
                                      title: Text(
                                        'Category'.tr(),
                                        style: TextStyle(color: kBlack),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            (category?.name ?? 'Other').tr(),
                                            style: TextStyle(
                                              color: kGray70,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: kGray70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //title and description
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                children: [
                                  TextFormField(
                                    validator: (val) {
                                      return val!.isEmpty
                                          ? 'Enter Title'.tr()
                                          : null;
                                    },
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    controller: _titleCnt,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 16),
                                      hintText: 'Title of Mail'.tr(),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  const Divider(
                                    indent: 16,
                                    height: 0,
                                  ),
                                  TextField(
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    controller: _descriptionCnt,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 16),
                                      hintText: 'Description'.tr(),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //date and archive number
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                children: [
                                  Material(
                                    color: kWhite,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                    child: MyExpansionTile(
                                      isEnabled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(30),
                                          topLeft: Radius.circular(30),
                                        ),
                                      ),
                                      divider: true,
                                      tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      count: const Text(''),
                                      leading: Icon(
                                        Icons.date_range_rounded,
                                        //size: 24,
                                        color: kRed,
                                      ),
                                      title: Text(
                                        'Date'.tr(),
                                        style: TextStyle(color: kBlack),
                                      ),
                                      subtitle: Text(
                                        DateFormat.yMMMd().format(selectedDate),
                                        style:
                                            TextStyle(color: kSecondaryColor),
                                      ),
                                      children: [
                                        CalendarDatePicker(
                                            initialDate: selectedDate,
                                            firstDate: DateTime(
                                                2000, 12, 30, 12, 0, 0, 0, 0),
                                            lastDate: DateTime(
                                                2050, 12, 30, 12, 0, 0, 0, 0),
                                            onDateChanged: (date) {
                                              setState(() {
                                                selectedDate = date;
                                              });
                                            }),
                                        Divider(
                                          // indent: 54,
                                          height: 0,
                                          color: kGray70,
                                          thickness: 0.2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  MyExpansionTile(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                      ),
                                    ),
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    trailing: const SizedBox(),
                                    leading: Icon(
                                      Icons.archive_outlined,
                                      //size: 24,
                                      color: kGray70,
                                    ),
                                    title: Text(
                                      'Archive Number'.tr(),
                                      style: TextStyle(color: kBlack),
                                    ),
                                    subtitle: SizedBox(
                                      // height: 56,
                                      child: TextFormField(
                                        validator: (val) {
                                          return val!.isEmpty
                                              ? 'Enter number of mail in archive'
                                                  .tr()
                                              : null;
                                        },
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        controller: _archiveCnt,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          hintText: 'like: 102/2022'.tr(),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //tags
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                children: [
                                  Material(
                                    color: kWhite,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    child: MyExpansionTile(
                                      isEnabled: true,
                                      onExpansionChanged: _onClickTag,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                      ),
                                      tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      count: SizedBox(),
                                      title: Text(
                                        'Tags'.tr(),
                                        style: TextStyle(color: kBlack),
                                      ),
                                      leading: Icon(
                                        Icons.tag_rounded,
                                        color: kGray70,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: kGray70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //status
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                children: [
                                  Material(
                                    color: kWhite,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    child: MyExpansionTile(
                                      onExpansionChanged: _onClickStatus,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                      ),
                                      tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      count: const SizedBox(),
                                      title: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: status.color != null
                                                  ? Color(
                                                      int.parse(status.color!))
                                                  : kRed,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              '${status.name}'.tr(),
                                              style: TextStyle(
                                                  color: Color(int.parse(
                                                              status.color!)) ==
                                                          kYellow
                                                      ? kBlack
                                                      : kWhite,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      leading: Icon(
                                        Icons.label_important_outline_rounded,
                                        color: kGray70,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: kGray70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //decision
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.only(
                                  top: 16, right: 16, left: 16),
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Decision'.tr(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: kSecondaryColor),
                                  ),
                                  TextField(
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    controller: _decisionCnt,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      hintText: 'Description'.tr(),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //image picker
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      TextButton(
                                        child: Text('Add Image'.tr()),
                                        onPressed: () {
                                          getImage();
                                        },
                                      ),
                                    ],
                                  ),
                                  _imageFileList != null
                                      ? ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          key: UniqueKey(),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _imageFileList!
                                                                .removeAt(
                                                                    index);
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons
                                                              .delete_outline_outlined,
                                                          color: kRed,
                                                        )),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 34,
                                                          height: 34,
                                                          decoration: BoxDecoration(
                                                              // color: kRed,
                                                              borderRadius: BorderRadius.circular(10),
                                                              image: DecorationImage(
                                                                  // image: FileImage(
                                                                  //     _imageFile ?? File('')),
                                                                  image: FileImage(File(_imageFileList![index].path)),
                                                                  fit: BoxFit.cover)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                index !=
                                                        _imageFileList!.length -
                                                            1
                                                    ? Divider(
                                                        indent: 48,
                                                        color: kGray70,
                                                        thickness: 0.2,
                                                        height: 0,
                                                      )
                                                    : const SizedBox(),
                                                const SizedBox(
                                                  height: 8,
                                                )
                                              ],
                                            );
                                          },
                                          itemCount: _imageFileList!.length,
                                        )
                                      : _pickImageError != null
                                          ? Text(
                                              'Pick image error: $_pickImageError',
                                              textAlign: TextAlign.center,
                                            )
                                          : const SizedBox(),
                                ],
                              ),
                            ),

                            //activities
                            ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                List<Widget> temp = [];
                                int count = 0;
                                for (var activity in activities) {
                                  // if (activity.title != null) {
                                  temp.add(
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 6),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: kWhite,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  activity.user?.image != ''
                                                      ? CircleAvatar(
                                                          radius: 10,
                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                                  '$storageUrl/${activity.user?.image}'),
                                                        )
                                                      : const CircleAvatar(
                                                          radius: 10,
                                                          // backgroundImage: AssetImage(),
                                                        ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text(
                                                      '${activity.user?.name}',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              activity.createdAt != null
                                                  ? Text(
                                                      DateFormat.yMMMd().format(
                                                          activity.createdAt!),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: kGray70),
                                                    )
                                                  : Text(
                                                      'Just Now'.tr(),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: kGray70),
                                                    ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 30,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  activity.body ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  // }
                                  count++;
                                }
                                return MyExpansionTile(
                                  textColor: kBlack,
                                  title: Text(
                                    'Activity'.tr(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  count: count == 0 ? null : Text('$count'),
                                  initiallyExpanded: true,
                                  // trailing: Text('22'),
                                  children: temp,
                                );
                              },
                            ),

                            //add activity
                            Consumer(
                              builder: (BuildContext context, WidgetRef ref,
                                  Widget? child) {
                                final futureUser = ref.watch(userStateFuture);
                                return futureUser.when(
                                    data: (user) => Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: kGray10,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: TextField(
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            controller: _newActivityCnt,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              hintText: 'Add new Activity'.tr(),
                                              prefixIcon: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 16),
                                                child: user.image != ''
                                                    ? CircleAvatar(
                                                        radius: 10,
                                                        backgroundImage:
                                                            CachedNetworkImageProvider(
                                                                '$storageUrl/${user.image}'),
                                                      )
                                                    : const CircleAvatar(
                                                        radius: 10,
                                                        // backgroundImage: AssetImage(),
                                                      ),
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Transform.rotate(
                                                  angle: 0,
                                                  child: Icon(
                                                    Icons.send_rounded,
                                                    color: _newActivityCnt
                                                            .text.isEmpty
                                                        ? kGray50
                                                        : kSecondaryColor,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (_newActivityCnt
                                                      .text.isNotEmpty) {
                                                    setState(() {
                                                      activities.add(
                                                        Activity(
                                                          body: _newActivityCnt
                                                              .text,
                                                          user: user,
                                                          userId: user.id,
                                                          createdAt:
                                                              DateTime.now(),
                                                        ),
                                                      );
                                                    });
                                                    _newActivityCnt.clear();
                                                  }
                                                },
                                              ),
                                              border: InputBorder.none,

                                              // focusColor: gray10,
                                            ),
                                          ),
                                        ),
                                    error: (e, stack) {
                                      return Center(
                                        child: Text(
                                          e.toString(),
                                        ),
                                      );
                                    },
                                    loading: () => const Center(
                                            child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        )));
                              },
                            ),

                            SizedBox(
                              height: 32,
                            )
                          ],
                        ),
                      ),
                    ),
                    MyAppBar(
                      dynamicTitle: false,
                      title: 'New Inbox'.tr(),
                      controller: scrollController,
                      leading: IconButton(
                        onPressed: widget.cancel,
                        icon: Icon(
                          Icons.arrow_back_ios_outlined,
                          color: kSecondaryColor,
                        ),
                      ),
                      actions: [
                        TextButton(
                            child: Text(
                              'Done'.tr(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _loading = !_loading;
                                });
                                _createMail();
                              }
                            })
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
