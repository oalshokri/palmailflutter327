import 'dart:core';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/widgets/myAppBarEmpty.dart';

import '../../utils/constant.dart';
import '../models_live/api_response.dart';
import '../models_live/mail.dart';
import '../services/tags_service.dart';
import '../services/user_service.dart';
import '../state/state_manager.dart';
import '../widgets/mailWidget.dart';
import 'login.dart';

class SearchWithTag extends StatefulWidget {
  final List<dynamic>? tags;
  final bool allSelected;
  final int? selectedTag;
  const SearchWithTag(
      {Key? key, this.tags, required this.allSelected, this.selectedTag})
      : super(key: key);

  @override
  State<SearchWithTag> createState() => _SearchWithTagState();
}

class _SearchWithTagState extends State<SearchWithTag> {
  final _controller = ScrollController();
  final appBarHeight = 96.0;
  final offsetToRun = 0.0;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  List<dynamic> homeTags = [];
  List<dynamic> tags = [];
  List<int> selectedTags = [];
  late bool allTagsSelected;

  _searchWithTags(getAll) async {
    ApiResponse response = await getTags(tagIds: selectedTags, getAll: getAll);
    if (response.error == null) {
      tags = response.data as List<dynamic>;

      setState(() {});
      return;
    }
    if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    }
    if (!mounted) return;
    showMessage(context, '${response.error}');
  }

  @override
  void initState() {
    allTagsSelected = widget.allSelected;
    homeTags = widget.tags!;
    _searchWithTags(true);
    if (widget.selectedTag != null) {
      homeTags[widget.selectedTag!].isSelected = true;
      selectedTags.add(homeTags[widget.selectedTag!].id);
      _searchWithTags(false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final isHover = ref.watch(hoverStateFuture);
        return Scaffold(
          key: _key,
          backgroundColor: kBlack,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              // statusBarColor: Colors.white,
              statusBarBrightness: isHover ? Brightness.dark : Brightness.light,
            ),
            child: AnimatedContainer(
              margin: !isHover
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.only(top: 24, left: 16, right: 16),
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: !isHover
                      ? BorderRadius.circular(0)
                      : BorderRadius.circular(10)),
              child: Stack(children: [
                SingleChildScrollView(
                  controller: _controller,
                  child: SearchResult(
                    heightFirstW: appBarHeight + 34,
                    tags: tags,
                  ),
                ),
                MyAppBarEmpty(
                  controller: _controller,
                  appBarHeight: appBarHeight,
                  runAfter: offsetToRun,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                for (var element in homeTags) {
                                  element.isSelected = false;
                                }
                                if (widget.tags != null) {
                                  for (var element in widget.tags!) {
                                    element.isSelected = false;
                                  }
                                }
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_outlined,
                                color: kSecondaryColor,
                              )),
                          Text('Tags'.tr(),
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(
                            width: 48,
                            height: 48,
                          )
                        ],
                      ),
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
                            for (int i = 0; i < homeTags.length; i++) {
                              temp.add(
                                GestureDetector(
                                  onTap: () {
                                    allTagsSelected = false;
                                    if (homeTags[i].isSelected == false ||
                                        homeTags[i].isSelected == null) {
                                      setState(() {
                                        homeTags[i].isSelected = true;
                                        selectedTags.add(homeTags[i].id);
                                      });
                                    } else {
                                      setState(() {
                                        homeTags[i].isSelected = false;
                                        selectedTags.remove(homeTags[i].id);
                                      });
                                    }
                                    _searchWithTags(false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    // margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: homeTags[i].isSelected == true
                                          ? kSecondaryColor
                                          : kGray10,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text('# ${homeTags[i].name}'),
                                  ),
                                ),
                              );
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: homeTags.isNotEmpty
                                  ? [
                                      GestureDetector(
                                        onTap: () {
                                          for (var e in homeTags) {
                                            e.isSelected = false;
                                          }
                                          setState(() {
                                            allTagsSelected = !allTagsSelected;
                                          });
                                          selectedTags = [];
                                          _searchWithTags(true);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          // margin: const EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            color: allTagsSelected
                                                ? kSecondaryColor
                                                : kGray10,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Text('All Tags'.tr()),
                                        ),
                                      ),
                                      ...temp
                                    ]
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
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class SearchResult extends StatelessWidget {
  final double heightFirstW;
  final List<dynamic> tags;
  const SearchResult({Key? key, required this.heightFirstW, required this.tags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mails = <Mail>[];
    var idSet = <int>{};
    for (var element in tags) {
      if (element.mails != null) {
        for (var mail in element.mails) {
          if (idSet.add(mail.id)) {
            mails.add(mail);
          }
        }
      }
    }

    return Column(
      children: [
        SizedBox(
          height: heightFirstW + 24,
        ),
        const Divider(),
        tags.isNotEmpty
            ? ListView.builder(
                reverse: true,
                primary: false,
                shrinkWrap: true,
                itemCount: mails.length,
                itemBuilder: (context, index) {
                  return MailWidget(mail: mails[index]);
                },
              )
            : Center(child: Text('There is no mails'.tr()))
      ],
    );
  }
}
