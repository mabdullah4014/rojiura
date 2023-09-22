import 'package:flutter/material.dart';

class User {
  String created_at;
  String dob;
  int gender;
  int id;
  String updated_at;
  String uuid;
  int age = 0;
  String colour;
  String push_token;

  User(
      {this.created_at,
      this.dob,
      this.gender,
      this.id,
      this.updated_at,
      this.uuid,
      this.age,
      this.colour,this.push_token});

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      created_at: json['created_at'],
      dob: json['dob'],
      gender: json['gender'],
      id: json['id'],
      updated_at: json['updated_at'],
      uuid: json['uuid'],
      age: json['age'] != null ? json['age'] : 0,
      push_token: json['push_token'] != null ? json['push_token'] : "",
      colour: json['colour'] != null ? json['colour'] : '#FF4081',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.created_at;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['id'] = this.id;
    data['updated_at'] = this.updated_at;
    data['uuid'] = this.uuid;
    data['age'] = this.age;
    data['colour'] = this.colour;
    data['push_token'] = this.push_token;
    return data;
  }
}
