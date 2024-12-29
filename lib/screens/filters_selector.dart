import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled/models_live/status.dart';
import 'package:untitled/widgets/myAppBar.dart';

import '../state/state_manager.dart';
import '../utils/constant.dart';
import '../widgets/myExpansionTile.dart';

class FiltersSelector extends StatefulWidget {
  final Status? status;
  final DateTime? startDate;
  final DateTime? endDate;
  const FiltersSelector({Key? key, this.status, this.startDate, this.endDate})
      : super(key: key);

  @override
  State<FiltersSelector> createState() => _FiltersSelectorState();
}

class _FiltersSelectorState extends State<FiltersSelector> {
  ScrollController scrollController = ScrollController();

  Status? selectedStatus;
  DateTime? startDate;
  DateTime? endDate;

  void _retrieveStatuses() async {}

  @override
  void initState() {
    _retrieveStatuses();
    if (widget.status != null) {
      selectedStatus = widget.status!;
    }
    if (widget.startDate != null) {
      startDate = widget.startDate!;
    }
    if (widget.endDate != null) {
      endDate = widget.endDate!;
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          'Clear Filters'.tr(),
                          style: TextStyle(color: kGray70),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedStatus = null;
                            startDate = null;
                            endDate = null;
                          });
                        },
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                  //status
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
                  //date picker
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: kWhite, borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      children: [
                        Material(
                          color: kWhite,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: MyExpansionTile(
                            isEnabled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            // divider: true,
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            count: const Text(''),
                            leading: Icon(
                              Icons.date_range_rounded,
                              //size: 24,
                              color: kRed,
                            ),
                            title: Text(
                              'Start Date'.tr(),
                              style: TextStyle(color: kBlack),
                            ),
                            subtitle: Text(
                              startDate != null
                                  ? DateFormat.yMMMd()
                                      .format(startDate ?? DateTime.now())
                                  : 'pick a start date..'.tr(),
                              style: TextStyle(color: kSecondaryColor),
                            ),
                            children: [
                              CalendarDatePicker(
                                initialDate: startDate ?? DateTime.now(),
                                firstDate:
                                    DateTime(2000, 12, 30, 12, 0, 0, 0, 0),
                                lastDate:
                                    DateTime(2050, 12, 30, 12, 0, 0, 0, 0),
                                onDateChanged: (date) {
                                  setState(() {
                                    startDate = date;
                                  });
                                },
                                // currentDate: DateTime.now(),
                              ),

                              // Divider(
                              //   // indent: 54,
                              //   height: 0,
                              //   color: kGray70,
                              //   thickness: 0.2,
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: kWhite, borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      children: [
                        Material(
                          color: kWhite,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: MyExpansionTile(
                            isEnabled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            // divider: true,
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            count: const Text(''),
                            leading: const Icon(
                              Icons.date_range_rounded,
                              //size: 24,
                              color: kRed,
                            ),
                            title: Text(
                              'End Date'.tr(),
                              style: TextStyle(color: kBlack),
                            ),
                            subtitle: Text(
                              endDate != null
                                  ? DateFormat.yMMMd()
                                      .format(endDate ?? DateTime.now())
                                  : 'pick an end date..'.tr(),
                              style: TextStyle(color: kSecondaryColor),
                            ),
                            children: [
                              CalendarDatePicker(
                                initialDate: endDate ?? DateTime.now(),
                                firstDate:
                                    DateTime(2000, 12, 30, 12, 0, 0, 0, 0),
                                lastDate:
                                    DateTime(2050, 12, 30, 12, 0, 0, 0, 0),
                                onDateChanged: (date) {
                                  setState(() {
                                    endDate = date;
                                  });
                                },
                                // currentDate: DateTime.now(),
                              ),

                              // Divider(
                              //   // indent: 54,
                              //   height: 0,
                              //   color: kGray70,
                              //   thickness: 0.2,
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            MyAppBar(
              title: 'Filters'.tr(),
              controller: scrollController,
              dynamicTitle: false,
              leading: TextButton(
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                ),
                onPressed: () {
                  Navigator.of(context).pop({
                    'status': selectedStatus,
                    'start': startDate,
                    'end': endDate
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
