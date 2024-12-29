import 'dart:core';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/widgets/myAppBarEmpty.dart';

import '../../utils/constant.dart';
import '../models_live/api_response.dart';
import '../models_live/status.dart';
import '../services/search_services.dart';
import '../services/user_service.dart';
import '../state/state_manager.dart';
import '../widgets/mailWidget.dart';
import 'filters_selector.dart';
import 'login.dart';

class MySearch extends StatefulWidget {
  const MySearch({
    Key? key,
  }) : super(key: key);

  @override
  State<MySearch> createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  late final TextEditingController _searchCnt = TextEditingController();
  late final FocusNode _focus = FocusNode();
  final _controller = ScrollController();
  final appBarHeight = 96.0;
  final offsetToRun = 0.0;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  List<dynamic> mails = [];
  String? text = '';
  Status? status;
  DateTime? start;
  DateTime? end;
  bool loading = false;

  _search() async {
    ApiResponse response = await searchMails(text, status?.id, start, end);
    if (response.error == null) {
      setState(() {
        mails = response.data as List<dynamic>;
        loading = false;
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
    if (!mounted) return;
    showMessage(context, '${response.error}');
  }

  _onClickFilter(ref) async {
    await showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (context) =>
          FiltersSelector(status: status, startDate: start, endDate: end),
    ).then((value) => setState(() {
          ref.read(hoverStateFuture.state).state = false;
          status = value['status'];
          start = value['start'];
          end = value['end'];
          if (status != null || start != null || end != null) {
            loading = true;
            _search();
          }
        }));
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    _focus.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
  }

  void _onFocusChange() {
    setState(() {});
    debugPrint("Focus1: ${_focus.hasFocus.toString()}");
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
                _searchCnt.text.isEmpty
                    ? Container()
                    : SingleChildScrollView(
                        controller: _controller,
                        child: !loading
                            ? SearchResult(
                                heightFirstW: appBarHeight + 34,
                                mails: mails,
                              )
                            : const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 180.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
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
                                Navigator.of(context).pop();
                                FocusScope.of(context).unfocus();
                                _searchCnt.clear();
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_outlined,
                                color: kSecondaryColor,
                              )),
                          Text('Search'.tr(),
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(
                            width: 48,
                            height: 48,
                          )
                        ],
                      ),
                      AnimatedPadding(
                        padding: isHover
                            ? const EdgeInsets.symmetric(horizontal: 0.0)
                            : const EdgeInsets.symmetric(horizontal: 16.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 48,
                              width: MediaQuery.of(context).size.width - 80,
                              child: TextField(
                                onSubmitted: (value) {
                                  text = value;
                                  loading = true;
                                  _search();
                                },
                                controller: _searchCnt,
                                focusNode: _focus,
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  hintText: 'Search'.tr(),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: kGray50,
                                  ),
                                  suffixIcon: _focus.hasFocus
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.cancel,
                                            color: _searchCnt.text.isEmpty
                                                ? kGray50
                                                : kSecondaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _searchCnt.clear();
                                            });
                                          },
                                        )
                                      : null,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide:
                                        BorderSide(color: kGray10, width: 0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide:
                                        BorderSide(color: kGray10, width: 1),
                                  ),
                                  filled: true,
                                  fillColor:
                                      !_focus.hasFocus ? kWhite : kGray10,
                                  // focusColor: gray10,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ref.read(hoverStateFuture.state).state = true;
                                _onClickFilter(ref);
                              },
                              icon: Icon(
                                Icons.filter_alt_outlined,
                                color: kSecondaryColor,
                              ),
                            ),
                          ],
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
  final List<dynamic> mails;
  const SearchResult(
      {Key? key, required this.heightFirstW, required this.mails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: heightFirstW,
        ),
        const Divider(),
        mails.isNotEmpty
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
