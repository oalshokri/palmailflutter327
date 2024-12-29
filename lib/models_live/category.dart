import 'package:untitled/models_live/sender.dart';

class MailCategory {
  int? id;
  String? name;
  int? sendersCount;
  List<Sender>? senders;
  MailCategory({this.id, this.name, this.sendersCount, this.senders});

  MailCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sendersCount = json['senders_count'];
    if (json['senders'] != null) {
      senders = <Sender>[];
      json['senders'].forEach((v) {
        senders!.add(Sender.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['senders_count'] = sendersCount;
    if (senders != null) {
      data['senders'] = senders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
