import 'package:app/model/user.dart';
import 'package:app/model/user_response.dart';
import 'package:app/model/api_response.dart';
import 'package:app/model/user_request.dart';
import 'package:app/repo/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

ValueNotifier<User> currentUser = new ValueNotifier(User());

class UserController extends ControllerMVC {
  void registerUser(UserRequest userRequest,
      {Function(ApiResponse<UserResponse>) apiResponse}) async {
    await apiRegisterUser(userRequest).then((response) {
      apiResponse(response);
    });
  }
}
