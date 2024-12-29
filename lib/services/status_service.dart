import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/status.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/utils/constant.dart';

// get all Statuses
Future<ApiResponse> getStatuses(bool withMail) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse('$statusesURL?mail=$withMail'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });
    print(response.body);
    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['statuses']
            .map((m) => Status.fromJson(m))
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
    print('statuses services: ${e.toString()}');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// get status
Future<ApiResponse> getStatus(bool withMail, int? id) async {
  ApiResponse apiResponse = ApiResponse();
  print('id:$id');
  try {
    String token = await getToken();
    final response = await http
        .get(Uri.parse('$statusesURL/$id?mail=$withMail'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print(response.body);
    switch (response.statusCode) {
      case 200:
        apiResponse.data = Status.fromJson(jsonDecode(response.body)['status']);
        // apiResponse.data as Status;
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('status services: ${e.toString()}');
    apiResponse.error = serverError;
  }
  return apiResponse;
}
