import 'package:untitled/models_live/mail.dart';

class Tag {
  int? id;
  String? name;
  bool? isSelected;
  List<Mail>? mails;

  Tag({this.id, this.name, this.isSelected, this.mails});

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isSelected = json['is_selected'];
    if (json['mails'] != null) {
      mails = <Mail>[];
      json['mails'].forEach((v) {
        mails!.add(Mail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_selected': isSelected,
        'mails': mails != null ? mails!.map((v) => v.toJson()).toList() : null
      };
}
