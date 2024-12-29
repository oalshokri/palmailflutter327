import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled/models_live/api_response.dart';
import 'package:untitled/models_live/role.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/utils/constant.dart';

// get all roles
Future<ApiResponse> getRoles() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(rolesURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    // print(response.body);
    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['roles']
            .map((m) => Role.fromJson(m))
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
    print('roles services: ${e.toString()}');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// update user role
Future<ApiResponse> updateUserRole(int roleId, int? id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse('$usersURL/$id/role'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {
        'role_id': roleId.toString(),
      },
    );

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
