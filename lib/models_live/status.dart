import 'mail.dart';

class Status {
  int? id;
  String? name;
  String? color;
  int? mailsCount;
  List<Mail?>? mails;

  Status({this.id, this.name, this.color, this.mailsCount, this.mails});

  Status.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    color = json['color'];
    mailsCount = json['mails_count'];
    if (json['mails'] != null) {
      mails = <Mail>[];
      json['mails'].forEach((v) {
        mails!.add(Mail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['color'] = color;
    data['mails_count'] = mailsCount;
    if (mails != null) {
      data['mails'] = mails!.map((v) => v?.toJson()).toList();
    }
    return data;
  }
}
