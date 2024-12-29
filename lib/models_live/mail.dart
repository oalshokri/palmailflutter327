import 'package:untitled/models_live/activity.dart';
import 'package:untitled/models_live/sender.dart';
import 'package:untitled/models_live/status.dart';
import 'package:untitled/models_live/tag.dart';

import 'attachment.dart';

class Mail {
  int? id;
  String? subject;
  String? description;
  int? senderId;
  String? archiveNumber;
  DateTime? archiveDate;
  String? decision;
  int? statusId;
  String? finalDecision;
  DateTime? createdAt;
  DateTime? updatedAt;
  Sender? sender;
  Status? status;
  List<Tag?>? tags;
  List<Attachment?>? attachments;
  List<Activity?>? activities;

  Mail(
      {this.id,
      this.subject,
      this.description,
      this.senderId,
      this.archiveNumber,
      this.archiveDate,
      this.decision,
      this.statusId,
      this.finalDecision,
      this.createdAt,
      this.updatedAt,
      this.sender,
      this.status,
      this.tags,
      this.attachments,
      this.activities});

  Mail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subject = json['subject'];
    description = json['description'];
    senderId = json['sender_id'];
    archiveNumber = json['archive_number'];
    archiveDate = DateTime.tryParse(json['archive_date']);
    decision = json['decision'];
    statusId = json['status_id'];
    finalDecision = json['final_decision'];
    createdAt = DateTime.tryParse(json['created_at']);
    updatedAt = DateTime.tryParse(json['updated_at']);
    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
    if (json['tags'] != null) {
      tags = <Tag>[];
      json['tags'].forEach((v) {
        tags!.add(Tag.fromJson(v));
      });
    }
    if (json['attachments'] != null) {
      attachments = <Attachment>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachment.fromJson(v));
      });
    }
    if (json['activities'] != null) {
      activities = <Activity>[];
      json['activities'].forEach((v) {
        activities!.add(Activity.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['subject'] = subject;
    data['description'] = description;
    data['sender_id'] = senderId;
    data['archive_number'] = archiveNumber;
    data['archive_date'] = archiveDate;
    data['decision'] = decision;
    data['status_id'] = statusId;
    data['final_decision'] = finalDecision;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (tags != null) {
      data['tags'] = tags!.map((v) => v?.toJson()).toList();
    }
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v?.toJson()).toList();
    }
    if (activities != null) {
      data['activities'] = activities!.map((v) => v?.toJson()).toList();
    }
    return data;
  }
}
