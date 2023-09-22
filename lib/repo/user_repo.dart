import 'dart:convert';

import 'package:app/model/user_response.dart';
import 'package:app/model/api_response.dart';
import 'package:app/model/user_request.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

Future<ApiResponse<UserResponse>> apiRegisterUser(
    UserRequest userRequest) async {
  final String url = '${GlobalConfiguration().get('base_url')}register';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: Constants.getHeader(),
    body: json.encode(userRequest.toJson()),
  );
  return AppUtils.getResponseObject(response);
}
