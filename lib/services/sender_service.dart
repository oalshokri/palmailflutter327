import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/sender.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/utils/constant.dart';

// get all Senders
Future<ApiResponse> getSenders(bool withMail) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse('$sendersURL?mail=$withMail'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });
    print(response.body);
    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['senders']
            .map((m) => Sender.fromJson(m))
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
    print('sender services: ${e.toString()}');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// get sender
Future<ApiResponse> getSender(bool withMail, int? id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse('$sendersURL/$id?mail=$withMail'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });
    print(response.body);
    switch (response.statusCode) {
      case 200:
        apiResponse.data = Sender.fromJson(jsonDecode(response.body)['sender']);
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
    print('sender services: ${e.toString()}');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

//createSender
Future<ApiResponse> createSender(Map<String, dynamic> body) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(
      Uri.parse(sendersURL),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: body,
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body);
        break;
      case 422:
        {
          final errors = jsonDecode(response.body)['errors'];
          apiResponse.error = errors[errors.keys.elementAt(0)][0];
        }
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      case 500:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}
