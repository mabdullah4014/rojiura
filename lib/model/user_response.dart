
import 'package:app/model/user.dart';

class UserResponse {
    User user;

    UserResponse({this.user});

    factory UserResponse.fromJson(Map<String, dynamic> json) {
        return UserResponse(
            user: json['user'] != null ? User.fromJson(json['user']) : null, 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.user != null) {
            data['user'] = this.user.toJson();
        }
        return data;
    }
}