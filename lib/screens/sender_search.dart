import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/services/sender_service.dart';
import 'package:untitled/widgets/myAppBarEmpty.dart';

import '../../utils/constant.dart';
import '../services/user_service.dart';
import '../state/state_manager.dart';
import '../utils/debouncer.dart';
import 'login.dart';

class SenderSearch extends StatefulWidget {
  const SenderSearch({
    Key? key,
  }) : super(key: key);

  @override
  State<SenderSearch> createState() => _SenderSearchState();
}

class _SenderSearchState extends State<SenderSearch> {
  late final TextEditingController _searchCnt = TextEditingController();
  late FocusNode _focus = FocusNode();
  final _controller = ScrollController();
  final appBarHeight = 96.0;
  final offsetToRun = 0.0;

  List<dynamic> senders = [];
  List<dynamic> filteredSenders = [];
  final _deBouncer = DeBouncer(milliseconds: 500);

  _retrieveSenders() async {
    ApiResponse response = await getSenders(false);
    if (response.error == null) {
      setState(() {
        senders = response.data as List<dynamic>;
        filteredSenders = senders;
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

  void initState() {
    _focus.addListener(_onFocusChange);
    _focus.requestFocus();
    _retrieveSenders();
    super.initState();
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
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(color: kBackground),
              child: Stack(children: [
                SingleChildScrollView(
                  controller: _controller,
                  child: Consumer(builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final futureCategories = ref.watch(categoriesStateFuture);
                    return futureCategories.when(
                      data: (categories) => Column(
                        children: [
                          SizedBox(
                            height: appBarHeight,
                          ),
                          const Divider(),
                          _searchCnt.text.isNotEmpty
                              ? Material(
                                  color: kBackground,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.of(context).pop({
                                        'founded': false,
                                        'sender': _searchCnt.text
                                      });
                                    },
                                    title: Text('"${_searchCnt.text}"'),
                                    shape: const Border(
                                        bottom: BorderSide(
                                            color: kGray70, width: 0.2)),
                                  ),
                                )
                              : const SizedBox(),
                          GroupedListView<dynamic, String>(
                            shrinkWrap: true,
                            elements: filteredSenders,
                            groupBy: (element) => element.category.name,
                            groupComparator: (value1, value2) =>
                                value2.compareTo(value1),
                            itemComparator: (item1, item2) =>
                                item1.name.compareTo(item2.name),
                            order: GroupedListOrder.DESC,
                            useStickyGroupSeparators: true,
                            groupSeparatorBuilder: (String value) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: kGray70),
                              ),
                            ),
                            itemBuilder: (c, element) {
                              return Material(
                                color: kBackground,
                                child: ListTile(
                                  // enabled: false,
                                  onTap: () {
                                    Navigator.of(context).pop(
                                        {'founded': true, 'sender': element});
                                  },
                                  leading:
                                      const Icon(Icons.person_outline_rounded),
                                  title: Text(
                                    element.name,
                                    style: TextStyle(color: kBlack),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 12,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        element.mobile ?? '',
                                        style: TextStyle(color: kGray70),
                                      ),
                                    ],
                                  ),
                                  // shape: Border(
                                  //     bottom: BorderSide(
                                  //         color: kGray70, width: 0.2)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      loading: () {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      error: (Object error, StackTrace? stackTrace) {
                        return Text(error.toString());
                      },
                    );
                  }),
                ),
                MyAppBarEmpty(
                  controller: _controller,
                  appBarHeight: appBarHeight,
                  runAfter: offsetToRun,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 32, bottom: 24, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 48,
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: TextField(
                          onChanged: (string) {
                            _deBouncer.run(() {
                              setState(() {
                                filteredSenders = senders
                                    .where((opt) => (opt.name
                                        .toLowerCase()
                                        .contains(string.toLowerCase())))
                                    .toList();
                              });
                            });
                          },
                          controller: _searchCnt,
                          focusNode: _focus,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            hintText: 'Search',
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
                              borderSide: BorderSide(color: kGray10, width: 0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: kGray10, width: 1),
                            ),
                            filled: true,
                            fillColor: !_focus.hasFocus ? kWhite : kGray10,
                            // focusColor: gray10,
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text(
                          'Cancel'.tr(),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pop({'founded': false, 'sender': ''});
                          FocusScope.of(context).unfocus();
                          _searchCnt.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ));
  }
}
