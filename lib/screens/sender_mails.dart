import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models_live/mail.dart';
import 'package:untitled/widgets/myAppBar.dart';
import 'package:untitled/widgets/myGroupList.dart';

import '../models_live/sender.dart';
import '../state/state_manager.dart';
import '../utils/constant.dart';

class SenderMails extends ConsumerWidget {
  final _controller = ScrollController();
  final Sender sender;

  SenderMails({Key? key, required this.sender}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHover = ref.watch(hoverStateFuture);
    final sendersFuture = ref.watch(senderStateFuture(sender.id!));
    return Scaffold(
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
                    // showMessage(context, 'refreshing ...');
                  },
                  child: SingleChildScrollView(
                    controller: _controller,
                    child: sendersFuture.when(
                      data: (data) {
                        return HomeScreenWidgets(
                          mails: data.mails,
                        );
                      },
                      loading: () {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 80.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      error: (Object error, StackTrace? stackTrace) {
                        return Center(child: Text(error.toString()));
                      },
                    ),
                  ),
                ),
                MyAppBar(
                  dynamicTitle: false,
                  controller: _controller,
                  title: '${sender.name}',
                  leading: IconButton(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    icon: const Icon(
                      Icons.arrow_back_ios_outlined,
                      color: kBlack,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreenWidgets extends StatelessWidget {
  final List<Mail?>? mails;
  const HomeScreenWidgets({Key? key, required this.mails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //this sizedBox needed to shit the widget away from under appBar
        const SizedBox(
          height: 80,
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final futureCategories = ref.watch(categoriesStateFuture);
            return futureCategories.when(
              data: (categories) => MyGroupList(
                mails: mails!,
                categories: categories,
                showCompleted: true,
              ),
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
        //this sizedBox needed to shit the widget away from bottom appBar
        const SizedBox(
          height: 57,
        ),
      ],
    );
  }
}
