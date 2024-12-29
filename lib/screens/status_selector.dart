import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models_live/status.dart';
import 'package:untitled/widgets/myAppBar.dart';

import '../state/state_manager.dart';
import '../utils/constant.dart';

class StatusSelector extends StatefulWidget {
  final Status? status;
  const StatusSelector({Key? key, this.status}) : super(key: key);

  @override
  State<StatusSelector> createState() => _StatusSelectorState();
}

class _StatusSelectorState extends State<StatusSelector> {
  ScrollController scrollController = ScrollController();

  // List<Status> statuses = [];
  Status? selectedStatus;

  void _retrieveStatuses() async {}

  @override
  void initState() {
    _retrieveStatuses();
    if (widget.status != null) {
      selectedStatus = widget.status!;
    }
    super.initState();
  }

  @override
  void dispose() {
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
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  SizedBox(
                    height: kSize64,
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: kWhite, borderRadius: BorderRadius.circular(30)),
                    child: Consumer(builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final futureStatuses = ref.watch(statusesStateFuture);
                      return futureStatuses.when(
                        data: (statuses) {
                          return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: statuses.length,
                              itemBuilder: (context, index) {
                                selectedStatus ??= statuses[0];
                                return Column(children: [
                                  ListTile(
                                    onTap: () {
                                      setState(() {
                                        selectedStatus = statuses[index];
                                      });
                                    },
                                    title: Text(
                                      '${statuses[index].name}'.tr(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    trailing: selectedStatus != null
                                        ? selectedStatus?.id ==
                                                statuses[index].id
                                            ? Icon(
                                                Icons.check,
                                                color: kSecondaryColor,
                                              )
                                            : null
                                        : statuses[index] == statuses[0]
                                            ? Icon(
                                                Icons.check,
                                                color: kSecondaryColor,
                                              )
                                            : null,
                                    leading: Icon(Icons.square_rounded,
                                        color: Color(
                                            int.parse(statuses[index].color!))),
                                    minLeadingWidth: 0,
                                  ),
                                  index == 0
                                      ? Divider(
                                          indent: 0,
                                          height: 0,
                                          color: kGray70,
                                        )
                                      : index != statuses.length - 1
                                          ? Divider(
                                              indent: 16,
                                              height: 0,
                                              color: kGray10,
                                            )
                                          : SizedBox(),
                                ]);
                              });
                        },
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
                ],
              ),
            ),
            MyAppBar(
              title: 'Statuses'.tr(),
              controller: scrollController,
              dynamicTitle: false,
              leading: TextButton(
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                ),
                onPressed: () {
                  Navigator.of(context).pop(selectedStatus);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
