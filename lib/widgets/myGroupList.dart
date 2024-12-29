import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utils/constant.dart';
import 'mailWidget.dart';
import 'myExpansionTile.dart';

class MyGroupList extends StatefulWidget {
  final List<dynamic> mails;
  final List<dynamic> categories;
  final bool showCompleted;
  const MyGroupList(
      {Key? key,
      required this.mails,
      required this.categories,
      this.showCompleted = false})
      : super(key: key);

  @override
  State<MyGroupList> createState() => _MyGroupListState();
}

class _MyGroupListState extends State<MyGroupList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.mails.isNotEmpty
        ? ListView.builder(
            reverse: true,
            primary: false,
            shrinkWrap: true,
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              List<Widget> temp = [];
              int count = 0;
              for (var element in widget.mails) {
                if (element.sender?.categoryId == widget.categories[index].id) {
                  if (!widget.showCompleted) {
                    if (element.status?.id! == 4) {
                      continue;
                    }
                  }
                  print(element.subject);
                  temp.add(
                    MailWidget(mail: element),
                  );

                  count++;
                }
              }

              return count != 0
                  ? MyExpansionTile(
                      textColor: kBlack,
                      title: Text(
                        '${widget.categories[index].name}'.tr(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      count: count == 0 ? null : Text('$count'),
                      initiallyExpanded: true,
                      // trailing: Text('22'),
                      children: temp,
                    )
                  : const SizedBox();
            },
          )
        : const Center(child: Text('There is no mails'));
  }
}
