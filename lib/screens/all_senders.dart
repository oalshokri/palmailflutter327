import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/screens/sender_mails.dart';
import 'package:untitled/services/sender_service.dart';
import 'package:untitled/widgets/myAppBarEmpty.dart';

import '../../utils/constant.dart';
import '../services/user_service.dart';
import '../state/state_manager.dart';
import '../utils/debouncer.dart';
import 'login.dart';

class AllSenders extends StatefulWidget {
  const AllSenders({
    Key? key,
  }) : super(key: key);

  @override
  State<AllSenders> createState() => _AllSendersState();
}

class _AllSendersState extends State<AllSenders> {
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
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(children: [
        SingleChildScrollView(
          controller: _controller,
          child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final futureCategories = ref.watch(categoriesStateFuture);
            return futureCategories.when(
              data: (categories) => Column(
                children: [
                  SizedBox(
                    height: appBarHeight + 56,
                  ),
                  // ListView.builder(
                  //   reverse: true,
                  //   primary: false,
                  //   shrinkWrap: true,
                  //   itemCount: categories.length,
                  //   itemBuilder: (context, index) {
                  //     List<Widget> temp = [];
                  //     int count = 0;
                  //     for (var element in filteredSenders) {
                  //       Sender s = element as Sender;
                  //
                  //       if (element.categoryId ==
                  //           categories[index].id) {
                  //         s.category = categories[index];
                  //         temp.add(
                  //           Material(
                  //             color: kBackground,
                  //             child: ListTile(
                  //               enabled: false,
                  //               onTap: () {},
                  //               leading: const Icon(
                  //                   Icons.person_outline_rounded),
                  //               title: Text(
                  //                 s.name ?? '',
                  //                 style: TextStyle(color: kBlack),
                  //               ),
                  //               subtitle: Row(
                  //                 children: [
                  //                   const Icon(
                  //                     Icons.phone,
                  //                     size: 12,
                  //                   ),
                  //                   const SizedBox(
                  //                     width: 8,
                  //                   ),
                  //                   Text(
                  //                     s.mobile ?? '',
                  //                     style: TextStyle(color: kGray70),
                  //                   ),
                  //                 ],
                  //               ),
                  //               shape: Border(
                  //                   bottom: BorderSide(
                  //                       color: kGray70, width: 0.2)),
                  //             ),
                  //           ),
                  //         );
                  //
                  //         count++;
                  //       }
                  //     }
                  //     return MyExpansionTile(
                  //       textColor: kBlack,
                  //       title: Text(
                  //         categories[index].name ?? '',
                  //         style: TextStyle(
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w500,
                  //             color: kGray70),
                  //       ),
                  //       count: count == 0 ? null : Text('$count'),
                  //       initiallyExpanded: true,
                  //       // trailing: Text('22'),
                  //       children: temp,
                  //     );
                  //   },
                  // )
                  senders.isNotEmpty
                      ? GroupedListView<dynamic, String>(
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
                            child:
                                // Text(
                                //   value,
                                //   textAlign: TextAlign.center,
                                //   style: const TextStyle(
                                //       fontSize: 20, fontWeight: FontWeight.bold),
                                // ),
                                Text(
                              value.tr(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: kGray70),
                            ),
                          ),
                          itemBuilder: (c, element) {
                            // return Card(
                            //   elevation: 8.0,
                            //   margin: const EdgeInsets.symmetric(
                            //       horizontal: 10.0, vertical: 6.0),
                            //   child: SizedBox(
                            //     child: ListTile(
                            //       contentPadding: const EdgeInsets.symmetric(
                            //           horizontal: 20.0, vertical: 10.0),
                            //       leading: const Icon(Icons.account_circle),
                            //       title: Text(element.name),
                            //       trailing: const Icon(Icons.arrow_forward),
                            //     ),
                            //   ),
                            // );
                            return Material(
                              color: kBackground,
                              child: ListTile(
                                // enabled: false,
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => SenderMails(
                                            sender: element,
                                          )));
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
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 0.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                ],
              ),
              loading: () {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ],
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
          appBarHeight: appBarHeight + 48,
          runAfter: offsetToRun,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          FocusScope.of(context).unfocus();
                          _searchCnt.clear();
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_outlined,
                          color: kSecondaryColor,
                        )),
                  ),
                  Text(
                    'All Senders'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(
                    width: 48,
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 48,
                      width: MediaQuery.of(context).size.width - 32,
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
                          hintText: 'Search'.tr(),
                          prefixIcon: const Icon(
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
                                      filteredSenders = senders;
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
