// import 'category.dart';
//
// class Sender {
//   int? id;
//   String? name;
//   int? categoryId;
//   int? mailsCount;
//   MailCategory? category;
//
//   Sender({this.id, this.name, this.categoryId, this.mailsCount, this.category});
//
//   Sender.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     categoryId = json['category_id'];
//     if (json['mails_count'] != null) {
//       mailsCount = json['mails_count'];
//     }
//
//     category = json['category'] != null
//         ? MailCategory.fromJson(json['category'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['category_id'] = categoryId;
//     if (mailsCount != null) {
//       data['mails_count'] = mailsCount;
//     }
//
//     if (category != null) {
//       data['category'] = category!.toJson();
//     }
//     return data;
//   }
// }

import 'package:untitled/models_live/category.dart';

import 'mail.dart';

class Sender {
  int? id;
  String? name;
  String? mobile;
  String? address;
  int? categoryId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? mailsCount;
  List<Mail>? mails;
  MailCategory? category;

  Sender(
      {this.id,
      this.name,
      this.mobile,
      this.address,
      this.categoryId,
      this.createdAt,
      this.updatedAt,
      this.mailsCount,
      this.mails,
      this.category});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    address = json['address'];
    categoryId = json['category_id'];
    createdAt = DateTime.tryParse(json['created_at']);
    updatedAt = DateTime.tryParse(json['updated_at']);
    mailsCount = json['mails_count'];
    if (json['mails'] != null) {
      mails = <Mail>[];
      json['mails'].forEach((v) {
        mails!.add(Mail.fromJson(v));
      });
    }
    category = json['category'] != null
        ? MailCategory.fromJson(json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['mobile'] = mobile;
    data['address'] = address;
    data['category_id'] = categoryId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['mails_count'] = mailsCount;
    if (mails != null) {
      data['mails'] = mails!.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}
