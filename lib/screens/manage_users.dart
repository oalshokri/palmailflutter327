import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/user.dart';
import 'package:untitled/widgets/myAppBarEmpty.dart';

import '../../utils/constant.dart';
import '../services/user_service.dart';
import '../utils/debouncer.dart';
import '../widgets/update_user.dart';
import 'login.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({
    Key? key,
  }) : super(key: key);

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  late final TextEditingController _searchCnt = TextEditingController();
  late FocusNode _focus = FocusNode();
  final _controller = ScrollController();
  final appBarHeight = 96.0;
  final offsetToRun = 0.0;

  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  final _deBouncer = DeBouncer(milliseconds: 500);

  _retrieveUsers() async {
    ApiResponse response = await getUsers();
    if (response.error == null) {
      setState(() {
        users = response.data as List<dynamic>;
        filteredUsers = users;
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

  _onClickUser(User user) async {
    await showModalBottomSheet(
      backgroundColor: kBackground,
      // isDismissible: false,
      // enableDrag: false,
      // isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (context) => UpdateUser(user: user),
    ).then((value) => setState(() {
          if (value == 'updated') {
            _retrieveUsers();
          }
        }));
  }

  @override
  void initState() {
    _focus.addListener(_onFocusChange);
    _focus.requestFocus();
    _retrieveUsers();
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
          child: Column(
            children: [
              SizedBox(
                height: appBarHeight + 56,
              ),
              GroupedListView<dynamic, String>(
                shrinkWrap: true,
                elements: filteredUsers,
                groupBy: (element) => element.role.name,
                groupComparator: (value1, value2) => value2.compareTo(value1),
                itemComparator: (item1, item2) =>
                    item1.name.compareTo(item2.name),
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kGray70),
                  ),
                ),
                itemBuilder: (c, element) {
                  return Material(
                    color: kBackground,
                    child: ListTile(
                      enabled: true,
                      onTap: () {
                        _onClickUser(element);
                      },
                      leading: const Icon(Icons.person_outline_rounded),
                      title: Text(
                        element.name,
                        style: TextStyle(color: kBlack),
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
                    'Manage Users',
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
                      // width: MediaQuery.of(context).size.width * 0.75,
                      width: MediaQuery.of(context).size.width - 32,
                      child: TextField(
                        onChanged: (string) {
                          _deBouncer.run(() {
                            setState(() {
                              filteredUsers = users
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
                                      filteredUsers = users;
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
                    // TextBtn(
                    //   label: 'Cancel',
                    //   function: () {
                    //     Navigator.of(context)
                    //         .pop({'founded': false, 'sender': ''});
                    //     FocusScope.of(context).unfocus();
                    //     _searchCnt.clear();
                    //   },
                    // ),
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

// class SearchResult extends StatelessWidget {
//   final double heightFirstW;
//   final List<Sender> senders;
//   final List<dynamic> categories;
//   const SearchResult(
//       {Key? key,
//       required this.heightFirstW,
//       required this.senders,
//       required this.categories})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(
//           height: heightFirstW,
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     '21 Completed',
//                     style:
//                         TextStyle(color: kGray70, fontWeight: FontWeight.w500),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: Icon(
//                       Icons.circle,
//                       size: 5,
//                       color: kGray50,
//                     ),
//                   ),
//                   TextBtn(
//                     label: 'Show',
//                     function: () {
//                       print('show');
//                     },
//                   )
//                 ],
//               ),
//               IconButton(
//                 onPressed: () {
//                   print('ii');
//                 },
//                 icon: Icon(
//                   Icons.filter_alt_outlined,
//                   color: kSecondaryColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const Divider(),
//         ListView.builder(
//           reverse: true,
//           primary: false,
//           shrinkWrap: true,
//           itemCount: senders.length,
//           itemBuilder: (context, index) {
//             List<Widget> temp = [];
//             int count = 0;
//             for (var element in senders) {
//               if (element.categoryId == categories[index].id) {
//                 if (element.id! == 4) continue;
//                 // temp.add(
//                 //   // MailWidget(mail: element),
//                 // );
//
//                 temp.add(Text('test'));
//
//                 count++;
//               }
//             }
//             return MyExpansionTile(
//               textColor: kBlack,
//               title: Text(
//                 categories[index].name ?? '',
//                 style:
//                     const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
//               ),
//               count: count == 0 ? null : Text('$count'),
//               initiallyExpanded: true,
//               // trailing: Text('22'),
//               children: temp,
//             );
//           },
//         )
//       ],
//     );
//   }
// }
