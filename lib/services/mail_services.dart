import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/mail.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/utils/constant.dart';

import 'attachment_services.dart';

// get all mails
Future<ApiResponse> getMails() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(mailsURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print('getmail: ${response.body} - token: $token');
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

// Create mail
Future<ApiResponse> createMail(
    Map<String, dynamic> body, List<XFile?>? images) async {
  ApiResponse apiResponse = ApiResponse();

  try {
    String token = await getToken();
    final response = await http.post(
      Uri.parse(mailsURL),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: body,
    );
    print(response.body);
    if (response.statusCode == 200) {
      Mail mail = Mail.fromJson(jsonDecode(response.body)['mail']);
      if (images != null) {
        for (var image in images) {
          if (image != null) {
            await uploadImage(File(image.path), mail.id);
            await Future.delayed(Duration(seconds: 1));
          }
        }
      }
    }

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body);
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      case 500:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Edit mail
Future<ApiResponse> editMail(
    int mailId, Map<String, dynamic> body, List<XFile?>? images) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(Uri.parse('$mailsURL/$mailId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: body);

    print(response.body);
    if (response.statusCode == 200) {
      if (images != null) {
        for (var image in images) {
          if (image != null) {
            await uploadImage(File(image.path), mailId);
            await Future.delayed(Duration(seconds: 1));
          }
        }
      }
    }

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// delete mail
Future<ApiResponse> deleteMail(int mailId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.delete(Uri.parse('$mailsURL/$mailId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    print(response.body);

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print(e.toString());
    apiResponse.error = serverError;
  }
  return apiResponse;
}
