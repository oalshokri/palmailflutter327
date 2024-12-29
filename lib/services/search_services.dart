import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/mail.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/utils/constant.dart';

//search mails
Future<ApiResponse> searchMails(
  String? text,
  int? statusId,
  // int? categoryId,
  DateTime? start,
  DateTime? end,
) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();

    String url = '$searchUrl?text=$text';

    if (statusId != null) {
      url = '$url&status_id=$statusId';
    }
    if (start != null) {
      url = '$url&start=$start&end=$end';
    }

    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print(response.body);
    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['mails']
            .map((m) => Mail.fromJson(m))
            .toList();

        apiResponse.data as List<dynamic>;

        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('mail services: ${e.toString()}');
    apiResponse.error = serverError;
  }
  return apiResponse;
}
