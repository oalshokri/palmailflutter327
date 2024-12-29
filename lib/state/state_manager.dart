import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/user.dart';
import 'package:untitled/services/category_service.dart';
import 'package:untitled/services/sender_service.dart';
import 'package:untitled/services/tags_service.dart';
import 'package:untitled/services/user_service.dart';

import '../models_live/sender.dart';
import '../models_live/status.dart';
import '../services/mail_services.dart';
import '../services/role_service.dart';
import '../services/status_service.dart';

final userStateFuture = FutureProvider.autoDispose<User>((ref) async {
  ApiResponse response = await getUserDetail();
  return response.data as User;
});

final mailsStateFuture = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  ApiResponse response = await getMails();
  return response.data as List<dynamic>;
});

final categoriesStateFuture =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  ApiResponse response = await getCategories();
  return response.data as List<dynamic>;
});

final tagsStateFuture = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  ApiResponse response = await getTags();
  return response.data as List<dynamic>;
});

final statusesStateFuture =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  ApiResponse response = await getStatuses(false);
  return response.data as List<dynamic>;
});
final statusStateFuture =
    FutureProvider.family.autoDispose<Status, int?>((ref, id) async {
  ApiResponse response = await getStatus(true, id);
  return response.data as Status;
});
final senderStateFuture =
    FutureProvider.family.autoDispose<Sender, int?>((ref, id) async {
  ApiResponse response = await getSender(true, id);
  return response.data as Sender;
});
final rolesStateFuture = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  ApiResponse response = await getRoles();
  return response.data as List<dynamic>;
});

final hoverStateFuture = StateProvider((ref) => false);

final userRoleStateFuture = FutureProvider.autoDispose<String>((ref) async {
  String role = await getUserRole();
  print('role:$role');
  return role;
});
