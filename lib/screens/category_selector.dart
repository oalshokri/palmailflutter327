import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models_live/category.dart';
import 'package:untitled/widgets/myAppBar.dart';

import '../state/state_manager.dart';
import '../utils/constant.dart';

class CategorySelector extends StatefulWidget {
  final MailCategory? category;
  const CategorySelector({Key? key, this.category}) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  ScrollController scrollController = ScrollController();

  MailCategory? selectedCat;

  @override
  void initState() {
    selectedCat = widget.category;
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
                    child: Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final futureCategories =
                            ref.watch(categoriesStateFuture);
                        return futureCategories.when(
                          data: (categories) {
                            selectedCat ??= categories[0];

                            return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  return Column(children: [
                                    ListTile(
                                      onTap: () {
                                        setState(() {
                                          selectedCat = categories[index];
                                        });
                                      },
                                      title: Text(
                                        '${categories[index].name}'.tr(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      trailing: selectedCat?.id ==
                                              categories[index].id
                                          ? Icon(
                                              Icons.check,
                                              color: kSecondaryColor,
                                            )
                                          : null,
                                    ),
                                    index == 0
                                        ? Divider(
                                            indent: 0,
                                            height: 0,
                                            color: kGray70,
                                          )
                                        : index != categories.length - 1
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
                  ),
                ],
              ),
            ),
            MyAppBar(
              title: 'Category'.tr(),
              controller: scrollController,
              dynamicTitle: false,
              leading: TextButton(
                child:
                    Icon(Icons.arrow_back_ios_rounded, color: kSecondaryColor),
                onPressed: () {
                  Navigator.of(context).pop(selectedCat);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
