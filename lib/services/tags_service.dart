import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/tag.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/utils/constant.dart';

// get all tags
Future<ApiResponse> getTags({List<int>? tagIds, getAll}) async {
  ApiResponse apiResponse = ApiResponse();
  String url = tagsURL;

  if (getAll != null && getAll) {
    url = '$tagsURL?tags=all';
  } else {
    if (tagIds != null) {
      if (tagIds.isNotEmpty) {
        url = '$tagsURL?tags=${jsonEncode(tagIds)}';
      }
    }
  }
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print(response.body);
    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['tags']
            .map((m) => Tag.fromJson(m))
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
    print('tag services: ${e.toString()}');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

//create tag
Future<ApiResponse> createTag(Map<String, dynamic> body) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(
      Uri.parse(tagsURL),
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
