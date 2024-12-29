import 'package:untitled/models_live/user.dart';

class Activity {
  int? id;
  String? body;
  int? userId;
  int? mailId;
  String? sendNumber;
  DateTime? sendDate;
  String? sendDestination;
  User? user;
  DateTime? createdAt;
  DateTime? updatedAt;

  Activity({
    this.id,
    this.body,
    this.userId,
    this.mailId,
    this.sendNumber,
    this.sendDate,
    this.sendDestination,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  Activity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        body = json['body'],
        userId = json['user_id'],
        mailId = json['mail_id'],
        sendNumber = json['send_number'],
        sendDate = json['send_date'] != null
            ? DateTime.tryParse(json['send_date'])
            : null,
        sendDestination = json['send_destination'],
        user = json['user'] != null ? User.fromJson(json) : null,
        createdAt = DateTime.tryParse(json['created_at']),
        updatedAt = DateTime.tryParse(json['updated_at']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'body': body,
        'user_id': userId,
        'mail_id': mailId,
        'send_number': sendNumber,
        'send_date': sendDate,
        'send_destination': sendDestination,
        'user': user != null ? user!.toJson() : null,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
