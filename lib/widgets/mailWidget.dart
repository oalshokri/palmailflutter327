import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled/models_live/mail.dart';
import 'package:untitled/screens/mail_details.dart';

import '../../utils/constant.dart';
import '../state/state_manager.dart';

class MailWidget extends ConsumerWidget {
  final Mail mail;
  const MailWidget({Key? key, required this.mail}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 12, right: 16, left: 16),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: kWhite,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            ref.read(hoverStateFuture.state).state = true;

            showModalBottomSheet(
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              context: context,
              builder: (context) => MailDetails(
                cancel: () {
                  Navigator.of(context, rootNavigator: true).pop('cancel');
                },
                mail: mail,
              ),
            ).then((value) async {
              ref.read(hoverStateFuture.state).state = false;
              if (value != 'cancel') {
                ref.refresh(mailsStateFuture);
                ref.refresh(statusesStateFuture);
                ref.refresh(categoriesStateFuture);
                ref.refresh(tagsStateFuture);
                Navigator.of(context, rootNavigator: true)
                    .popUntil(ModalRoute.withName("/Home"));
                print('refreshing ...');
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Icon(
                    Icons.circle,
                    color: Color(int.parse(mail.status?.color ?? '0xffffffff')),
                    size: 12,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${mail.sender?.name}',
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                color: kBlack,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                DateFormat.yMMMd().format(mail.archiveDate!),
                                style: TextStyle(
                                  color: kGray70,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: kGray70,
                                size: 14,
                              )
                            ],
                          )
                        ],
                      ),
                      Text(
                        mail.subject!,
                        style: TextStyle(
                          color: kBlack,
                        ),
                      ),
                      mail.description != null
                          ? Text(
                              mail.description!,
                              style: TextStyle(
                                color: kGray70,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox(),
                      Row(
                        children: [
                          mail.tags!.isNotEmpty
                              ? Builder(builder: (context) {
                                  List<Widget> tagsWidget = [];
                                  for (var tag in mail.tags!) {
                                    tagsWidget.add(
                                      SizedBox(
                                        // height: 34,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                              minimumSize: Size(40, 30),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              alignment: Alignment.centerLeft),
                                          onPressed: () {},
                                          child: Text('#${tag?.name}'),
                                        ),
                                      ),
                                    );
                                  }
                                  return Wrap(
                                    children: tagsWidget,
                                  );
                                })
                              : SizedBox()
                        ],
                      ),
                      Row(
                        children: [
                          mail.attachments!.isNotEmpty
                              ? SizedBox(
                                  height: 36,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: mail.attachments!.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (_) => ImageDialog(
                                                  image:
                                                      '$storageUrl/${mail.attachments![index]?.image}'),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              // child: Image.network(
                                              //   '$storageUrl/${mail.attachments![index]?.image}',
                                              //   width: 36,
                                              //   height: 36,
                                              //   fit: BoxFit.cover,
                                              // ),
                                              child: CachedNetworkImage(
                                                width: 36, height: 36,
                                                fit: BoxFit.cover,
                                                imageUrl:
                                                    '$storageUrl/${mail.attachments![index]?.image}',
                                                // placeholder: (context, url) =>
                                                //     const CircularProgressIndicator(),
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        Container(
                                                  padding: EdgeInsets.all(4),
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                )
                              : SizedBox()
                        ],
                      )
                    ],
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

class ImageDialog extends StatelessWidget {
  final String image;
  const ImageDialog({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        // width: MediaQuery.of(context).size.width,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
              image: CachedNetworkImageProvider(image), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
