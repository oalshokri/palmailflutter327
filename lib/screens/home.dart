import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:untitled/screens/all_senders.dart';
import 'package:untitled/screens/manage_users.dart';
import 'package:untitled/screens/new_inbox.dart';
import 'package:untitled/screens/profile.dart';
import 'package:untitled/screens/search_screen.dart';
import 'package:untitled/screens/search_with_tag.dart';
import 'package:untitled/widgets/myAppBar.dart';
import 'package:untitled/widgets/myGridView.dart';
import 'package:untitled/widgets/myGroupList.dart';

import '../state/state_manager.dart';
import '../utils/constant.dart';
import '../widgets/my_pop_menu.dart';

class Home extends ConsumerWidget {
  final _controller = ScrollController();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final _advancedDrawerController = AdvancedDrawerController();

  Home({Key? key}) : super(key: key);

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.

    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  void _onNewInboxClick(context, ref) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (context) => NewInbox(
        cancel: () {
          Navigator.of(context).pop('cancel');
        },
      ),
    ).then((value) async {
      ref.read(hoverStateFuture.state).state = false;
      if (value != 'cancel') {
        ref.refresh(mailsStateFuture);
        ref.refresh(statusesStateFuture);
        ref.refresh(categoriesStateFuture);
        ref.refresh(tagsStateFuture);
        print('refreshing ...');
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHover = ref.watch(hoverStateFuture);
    final userRoleFuture = ref.watch(userRoleStateFuture);
    return AdvancedDrawer(
      backdropColor: kPrimaryColor,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: context.locale.languageCode == 'ar' ? true : false,
      // openScale: 1.0,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        // NOTICE: Uncomment if you want to add shadow behind the page.
        // Keep in mind that it may cause animation jerks.
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 0.0,
        //   ),
        // ],
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      drawer: SafeArea(
        child: Container(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 128.0,
                  height: 128.0,
                  padding: EdgeInsets.all(16),
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    // color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/image/palestine_bird.png',
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            settings: const RouteSettings(name: "/Home"),
                            builder: (context) => Home()),
                        (route) => false);
                  },
                  leading: Icon(Icons.home),
                  title: Text('Home'.tr()),
                ),
                ListTile(
                  onTap: () {
                    _advancedDrawerController.toggleDrawer();
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            settings: const RouteSettings(name: "/Profile"),
                            builder: (context) => const Profile()))
                        .then((value) => ref.refresh(userStateFuture));
                  },
                  leading: Icon(Icons.account_circle_rounded),
                  title: Text('Profile'.tr()),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        settings: const RouteSettings(name: "/AllSenders"),
                        builder: (context) => const AllSenders()));
                  },
                  leading: Icon(Icons.contact_page),
                  title: Text('All Senders'.tr()),
                ),
                userRoleFuture.when(
                  data: (userRole) {
                    if (userRole == 'admin') {
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              settings:
                                  const RouteSettings(name: "/ManageUsers"),
                              builder: (context) => const ManageUsers()));
                        },
                        leading: Icon(Icons.settings),
                        title: Text('Manage Users'.tr()),
                      );
                    } else {
                      return SizedBox();
                    }
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
                ),
                Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: Text('Terms of Service | Privacy Policy'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Scaffold(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      ref.refresh(mailsStateFuture);
                      ref.refresh(statusesStateFuture);
                      ref.refresh(categoriesStateFuture);
                      ref.refresh(tagsStateFuture);
                      // showMessage(context, 'refreshing ...');
                    },
                    child: SingleChildScrollView(
                      controller: _controller,
                      child: const HomeScreenWidgets(),
                    ),
                  ),
                  MyAppBar(
                    controller: _controller,
                    title: 'Pal Mail',
                    leading: IconButton(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerLeft,
                      onPressed: _handleMenuButtonPressed,
                      icon: ValueListenableBuilder<AdvancedDrawerValue>(
                        valueListenable: _advancedDrawerController,
                        builder: (_, value, __) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              key: ValueKey<bool>(value.visible),
                              child: value.visible
                                  ? const Icon(
                                      Icons.clear,
                                      color: kBlack,
                                    )
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform:
                                          context.locale.languageCode == 'ar'
                                              ? Matrix4.rotationY(math.pi)
                                              : Matrix4.rotationY(0),
                                      child: SvgPicture.asset(
                                        'assets/image/burgerList.svg',
                                        color: kBlack,
                                        // key: ValueKey<bool>(value.visible),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      IconButton(
                        // padding: EdgeInsets.only(right: 16),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MySearch()));
                        },
                        icon: const Icon(
                          Icons.search,
                          color: kBlack,
                        ),
                      ),
                      const MyPopMenu(),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                  userRoleFuture.when(
                    data: (userRole) {
                      if (userRole != 'user') {
                        return Positioned(
                            bottom: 0,
                            child: Container(
                              height: 57,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  color: kWhite,
                                  border: Border(
                                      top: BorderSide(
                                          color: kGray70, width: 0.3))),
                              child: Row(
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        ref.read(hoverStateFuture.state).state =
                                            true;
                                        _onNewInboxClick(context, ref);
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Icon(Icons.add_circle),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            'New Inbox'.tr(),
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            ));
                      }
                      return const SizedBox();
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenWidgets extends StatelessWidget {
  const HomeScreenWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //this sizedBox needed to shit the widget away from under appBar
        const SizedBox(
          height: 80,
        ),
        Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final futureStatuses = ref.watch(statusesStateFuture);

          return futureStatuses.when(
            data: (statuses) => MyGridViw(statuses: statuses),
            loading: () {
              return const SizedBox(
                height: 230,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            error: (Object error, StackTrace? stackTrace) {
              return Text(error.toString());
            },
          );
        }),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final futureMails = ref.watch(mailsStateFuture);
            final futureCategories = ref.watch(categoriesStateFuture);
            return futureCategories.when(
              data: (categories) {
                return futureMails.when(
                  data: (mails) {
                    return MyGroupList(
                      mails: mails,
                      categories: categories,
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
        //tag section
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final futureTags = ref.watch(tagsStateFuture);

            return futureTags.when(
              data: (tags) {
                return tags.isNotEmpty
                    ? Container(
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
                            for (int i = 0; i < tags.length; i++) {
                              temp.add(
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => SearchWithTag(
                                                  allSelected: false,
                                                  tags: tags,
                                                  selectedTag: i,
                                                )));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    // margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: kGray10,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text('# ${tags[i].name}'),
                                  ),
                                ),
                              );
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => SearchWithTag(
                                                allSelected: true,
                                                tags: tags)));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    // margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: kGray10,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text('All Tags'.tr()),
                                  ),
                                ),
                                ...temp
                              ],
                            );
                          },
                        ),
                      )
                    : SizedBox();
              },
              loading: () {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              error: (Object error, StackTrace? stackTrace) {
                return Text(error.toString());
              },
            );
          },
        ),

        //this sizedBox needed to shit the widget away from bottom appBar
        const SizedBox(
          height: 57,
        ),
      ],
    );
  }
}
