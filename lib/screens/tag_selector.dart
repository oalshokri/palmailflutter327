import 'package:flutter/material.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/widgets/myAppBar.dart';

import '../screens/login.dart';
import '../services/tags_service.dart';
import '../services/user_service.dart';
import '../utils/constant.dart';

class TagSelector extends StatefulWidget {
  final List<int?>? tags;
  const TagSelector({Key? key, this.tags}) : super(key: key);

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  ScrollController scrollController = ScrollController();
  List<dynamic> allTags = [];
  String? message;
  bool? selected;
  final TextEditingController _tagCnt = TextEditingController();

  Future<void> _retrieveTags() async {
    message = null;
    ApiResponse response = await getTags();
    if (response.error == null) {
      setState(() {
        allTags = response.data as List<dynamic>;
        if (allTags.isEmpty) {
          message = 'There is no tag';
        }
        _compareTags();
      });
      return;
    }
    if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    }

    showMessage(context, '${response.error}');
  }

  Future<bool> _createTag(Map<String, dynamic> body) async {
    ApiResponse response = await createTag(body);
    if (response.error == null) {
      var data = response.data as Map<String, dynamic>;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${data['message']}')));
      return true;
    }
    if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${response.error}')));
    return false;
  }

  void _compareTags() {
    if (widget.tags != null) {
      print('tag selector');
      for (var tag in allTags) {
        for (var myTag in widget.tags!) {
          if (myTag == tag.id) {
            tag.isSelected = true;
          }
        }
      }
    }
  }

  @override
  void initState() {
    _retrieveTags();

    super.initState();
  }

  @override
  void dispose() {
    _tagCnt.dispose();
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
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    SizedBox(
                      height: kSize64,
                    ),
                    // show all tags
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(30)),
                      child: Builder(
                        builder: (context) {
                          List<Widget> temp = [];
                          for (int i = 0; i < allTags.length; i++) {
                            temp.add(
                              GestureDetector(
                                onTap: () {
                                  print('clicked');
                                  // if (mailTag[i].isSelected == null) {
                                  //   mailTag[i].isSelected = true;
                                  // } else {
                                  print(allTags[i].isSelected);
                                  if (allTags[i].isSelected == false ||
                                      allTags[i].isSelected == null) {
                                    setState(() {
                                      allTags[i].isSelected = true;
                                    });
                                  } else {
                                    setState(() {
                                      allTags[i].isSelected = false;
                                    });

                                    print(allTags[i].isSelected);
                                  }
                                  // }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  // margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: allTags[i].isSelected == true
                                        ? kSecondaryColor
                                        : kGray10,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text('# ${allTags[i].name}'),
                                ),
                              ),
                            );
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: message != null
                                ? [Text(message!)]
                                : allTags.isNotEmpty
                                    ? temp
                                    : [
                                        const Center(
                                          child: SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      ],
                          );
                        },
                      ),
                    ),

                    // add new tag
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(30)),
                      child: Form(
                        child: TextFormField(
                          onFieldSubmitted: (value) async {
                            bool isCreated =
                                await _createTag({'name': _tagCnt.text});
                            if (isCreated) {
                              await _retrieveTags();
                              allTags.last.isSelected = true;
                              setState(() {
                                _tagCnt.clear();
                              });
                            }
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                          controller: _tagCnt,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            hintText: 'Add New Tag',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MyAppBar(
                title: 'Tags',
                controller: scrollController,
                dynamicTitle: false,
                leading: TextButton(
                  child: Icon(Icons.arrow_back_ios_rounded,
                      color: kSecondaryColor),
                  onPressed: () {
                    List<int> temp = [];
                    for (var element in allTags) {
                      if (element.isSelected == true) {
                        temp.add(element.id);
                      }
                    }
                    Navigator.of(context).pop(temp);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
