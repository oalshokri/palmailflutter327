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
import 'package:untitled/models_live/attachment.dart';
import 'package:untitled/models_live/category.dart';
import 'package:untitled/models_live/mail.dart';
import 'package:untitled/models_live/sender.dart';
import 'package:untitled/models_live/status.dart';
import 'package:untitled/screens/status_selector.dart';
import 'package:untitled/widgets/myAppBar.dart';

import '../services/mail_services.dart';
import '../services/user_service.dart';
import '../state/state_manager.dart';
import '../utils/constant.dart';
import '../widgets/myExpansionTile.dart';
import 'login.dart';
import 'tag_selector.dart';

class MailDetails extends StatefulWidget {
  final Function()? cancel;
  final Function()? done;
  final Mail mail;
  const MailDetails({Key? key, this.cancel, this.done, required this.mail})
      : super(key: key);

  @override
  State<MailDetails> createState() => _MailDetailsState();
}

class _MailDetailsState extends State<MailDetails> {
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
  List<int?>? tags = [];
  Status status = Status(id: 1, name: 'inbox', color: '0xfffa3a57');
  List<Activity?>? activities = [];
  List<Activity?>? newActivities = [];
  List<Attachment?>? attachments = [];
  List<int?>? idAttachmentsForDelete = [];
  List<String?>? pathAttachmentsForDelete = [];

  List<XFile>? _imageFileList;
  File? _imageFile;
  final _picker = ImagePicker();
  dynamic _pickImageError;

  String userRole = 'user';

  void readUserRole() async {
    userRole = await getUserRole();
    setState(() {});
  }

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

  void _updateMail() async {
    List<Map<String, dynamic>> tempActivities = [];
    for (var element in newActivities!) {
      tempActivities.add({'body': element?.body, 'user_id': element?.userId});
    }
    Map<String, dynamic> mailBody = {
      'decision': _decisionCnt.text,
      'status_id': status.id.toString(),
      'final_decision': _decisionCnt.text,
      'tags': tags!.isNotEmpty ? jsonEncode(tags) : '',
      'activities': newActivities!.isNotEmpty ? jsonEncode(tempActivities) : '',
      'idAttachmentsForDelete': idAttachmentsForDelete!.isNotEmpty
          ? jsonEncode(idAttachmentsForDelete)
          : '[]',
      'pathAttachmentsForDelete': pathAttachmentsForDelete!.isNotEmpty
          ? jsonEncode(pathAttachmentsForDelete)
          : '[]',
    };

    ApiResponse response =
        await editMail(widget.mail.id!, mailBody, _imageFileList);

    if (response.error == null) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      var data = response.data;
      showMessage(context, '$data');
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

    setState(() {
      _loading = !_loading;
    });
  }

  void _deleteMail() async {
    ApiResponse response = await deleteMail(widget.mail.id!);

    if (response.error == null) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true)
        ..pop()
        ..pop();
      var data = response.data;
      showMessage(context, '$data');
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

    setState(() {
      _loading = !_loading;
    });
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
      builder: (context) => TagSelector(
        tags: tags,
      ),
    ).then((value) => setState(() {
          tags = value;
        }));
    for (var element in tags!) {
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

  @override
  void initState() {
    readUserRole();
    _senderCnt.text = widget.mail.sender?.name ?? '';
    _mobileCnt.text = widget.mail.sender?.mobile ?? '';
    _titleCnt.text = widget.mail.subject!;
    _descriptionCnt.text = widget.mail.description ?? '';
    selectedDate = widget.mail.archiveDate!;
    _archiveCnt.text = widget.mail.archiveNumber!;
    tags = widget.mail.tags?.map((e) {
          print(e?.name);
          return e?.id;
        }).toList() ??
        [];
    status = widget.mail.status!;
    _decisionCnt.text = widget.mail.decision ?? '';
    activities = widget.mail.activities;
    attachments = widget.mail.attachments;
    sender = widget.mail.sender;
    category = widget.mail.sender?.category;

    super.initState();
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
                  child: CircularProgressIndicator(),
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

                            //fixed data
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16.0, right: 16, left: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: 18,
                                          color: kGray70,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${sender?.name}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              '${category?.name}'.tr(),
                                              style: TextStyle(
                                                  fontSize: 12, color: kGray70),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: SizedBox(),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat.yMMMd()
                                                  .format(selectedDate),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: kGray70),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              'A-No.'
                                                  .tr(args: [_archiveCnt.text]),
                                              style: TextStyle(
                                                  fontSize: 12, color: kGray70),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    indent: 16,
                                    height: 8,
                                  ),
                                  MyExpansionTile(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(30),
                                        bottomLeft: Radius.circular(30),
                                      ),
                                    ),
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    count: const Text(''),
                                    title: Text(
                                      _titleCnt.text,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: kBlack),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                _descriptionCnt.text.isEmpty
                                                    ? 'No description'.tr()
                                                    : _descriptionCnt.text,
                                                style: const TextStyle(
                                                  color: kGray70,
                                                ),
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            //tags
                            userRole != 'user'
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: kWhite,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Column(
                                      children: [
                                        Material(
                                          color: kWhite,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                          child: MyExpansionTile(
                                            onExpansionChanged: _onClickTag,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(30),
                                              ),
                                            ),
                                            tilePadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16),
                                            count: const SizedBox(),
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
                                              children: const [
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
                                  )
                                : const SizedBox(),

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
                                      isEnabled:
                                          userRole != 'user' ? true : false,
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
                                      leading: const Icon(
                                        Icons.label_important_outline_rounded,
                                        color: kGray70,
                                      ),
                                      trailing: userRole != 'user'
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: kGray70,
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
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
                                    readOnly: userRole != 'user' ? false : true,
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                      hintText: userRole != 'user'
                                          ? 'leave your opinion..'.tr()
                                          : 'no decision yet'.tr(),
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
                                  userRole != 'user'
                                      ? Row(
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
                                        )
                                      : const SizedBox(
                                          height: 8,
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
                                                        icon: const Icon(
                                                          Icons
                                                              .delete_outline_outlined,
                                                          color: kRed,
                                                        )),
                                                    Container(
                                                      width: 34,
                                                      height: 34,
                                                      decoration: BoxDecoration(
                                                          // color: kRed,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          image:
                                                              DecorationImage(
                                                                  // image: FileImage(
                                                                  //     _imageFile ?? File('')),
                                                                  image: FileImage(File(
                                                                      _imageFileList![
                                                                              index]
                                                                          .path)),
                                                                  fit: BoxFit
                                                                      .cover)),
                                                    ),
                                                  ],
                                                ),
                                                index !=
                                                        _imageFileList!.length -
                                                            1
                                                    ? const Divider(
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
                                  userRole != 'user'
                                      ? const Divider(
                                          height: 0,
                                        )
                                      : const SizedBox(),
                                  attachments != null
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
                                                    userRole != 'user'
                                                        ? IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                idAttachmentsForDelete?.add(
                                                                    attachments![
                                                                            index]
                                                                        ?.id);
                                                                pathAttachmentsForDelete?.add(
                                                                    attachments![
                                                                            index]
                                                                        ?.image);
                                                                attachments!
                                                                    .removeAt(
                                                                        index);
                                                              });
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .delete_outline_outlined,
                                                              color: kRed,
                                                            ))
                                                        : const SizedBox(
                                                            width: 16,
                                                            height: 48,
                                                          ),
                                                    // Container(
                                                    //   width: 34,
                                                    //   height: 34,
                                                    //   decoration: BoxDecoration(
                                                    //       // color: kRed,
                                                    //       borderRadius: BorderRadius.circular(10),
                                                    //       image: DecorationImage(
                                                    //           // image: FileImage(
                                                    //           //     _imageFile ?? File('')),
                                                    //           image: CachedNetworkImageProvider('$storageUrl/${attachments![index]?.image}'),
                                                    //           fit: BoxFit.cover)),
                                                    // ),
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: CachedNetworkImage(
                                                        width: 34, height: 34,
                                                        fit: BoxFit.cover,
                                                        imageUrl:
                                                            '$storageUrl/${attachments![index]?.image}',
                                                        // placeholder: (context, url) =>
                                                        //     const CircularProgressIndicator(),
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                    downloadProgress) =>
                                                                Container(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    SizedBox(
                                                      width: 240,
                                                      child: Text(
                                                        attachments![index]
                                                                ?.title ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                index != attachments!.length - 1
                                                    ? Divider(
                                                        indent:
                                                            userRole != 'user'
                                                                ? 48
                                                                : 16,
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
                                          itemCount: attachments!.length,
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
                                for (var activity in activities!) {
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
                                                  activity?.user?.image != ''
                                                      ? CircleAvatar(
                                                          radius: 10,
                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                                  '$storageUrl/${activity?.user?.image}'),
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
                                                      '${activity?.user?.name}',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              activity?.createdAt != null
                                                  ? Text(
                                                      DateFormat.yMMMd().format(
                                                          activity!.createdAt!),
                                                      style: const TextStyle(
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
                                                  activity?.body ?? '',
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

                            //new activities
                            ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount: newActivities?.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: kGray10.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              newActivities![index]
                                                          ?.user
                                                          ?.image !=
                                                      ''
                                                  ? CircleAvatar(
                                                      radius: 10,
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              '$storageUrl/${newActivities![index]?.user?.image}'),
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
                                                  '${newActivities![index]?.user?.name}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          newActivities![index]?.createdAt !=
                                                  null
                                              ? Text(
                                                  DateFormat.yMMMd().format(
                                                      newActivities![index]!
                                                          .createdAt!),
                                                  style: const TextStyle(
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
                                              newActivities![index]?.body ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            //add activity
                            userRole != 'user'
                                ? Consumer(
                                    builder: (BuildContext context,
                                        WidgetRef ref, Widget? child) {
                                      final futureUser =
                                          ref.watch(userStateFuture);
                                      return futureUser.when(
                                          data: (user) => Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: kGray10,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
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
                                                        const EdgeInsets
                                                                .symmetric(
                                                            vertical: 16),
                                                    hintText:
                                                        'Add new Activity'.tr(),
                                                    prefixIcon: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
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
                                                            newActivities?.add(
                                                              Activity(
                                                                body:
                                                                    _newActivityCnt
                                                                        .text,
                                                                user: user,
                                                                userId: user.id,
                                                                createdAt:
                                                                    DateTime
                                                                        .now(),
                                                              ),
                                                            );
                                                            // activities?.add(
                                                            //   Activity(
                                                            //     body: _newActivityCnt
                                                            //         .text,
                                                            //     user: user,
                                                            //     userId: user.id,
                                                            //     createdAt:
                                                            //         DateTime.now(),
                                                            //   ),
                                                            // );
                                                          });
                                                          _newActivityCnt
                                                              .clear();
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
                                                  child:
                                                      CircularProgressIndicator(
                                                strokeWidth: 2,
                                              )));
                                    },
                                  )
                                : const SizedBox(),

                            const SizedBox(
                              height: 24,
                            ),
                            userRole != 'user'
                                ? const Divider()
                                : const SizedBox(),

                            //delete
                            userRole != 'user'
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: kWhite,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          child: Text(
                                            'Delete Mail'.tr(),
                                            style: TextStyle(color: kRed),
                                          ),
                                          onPressed: () => showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                              title: const Text('تأكيد الحذف'),
                                              content: const Text(
                                                  'هل أنت متأكد أنك تريد حذف هذا البريد، في حال التأكيد لا يمكن استرجاعه نهائياً'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context,
                                                          'Cancel'.tr()),
                                                  child: const Text('إلغاء'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _deleteMail();
                                                    // Navigator.pop(context, 'OK');
                                                  },
                                                  child: Text(
                                                    'تأكيد الحذف',
                                                    style:
                                                        TextStyle(color: kRed),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            SizedBox(
                              height: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                    MyAppBar(
                      dynamicTitle: false,
                      title: 'Mail Details'.tr(),
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
                              // if (_formKey.currentState!.validate()) {
                              setState(() {
                                _loading = !_loading;
                              });
                              _updateMail();
                              // }
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
