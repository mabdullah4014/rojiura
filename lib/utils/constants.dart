import 'dart:convert';
import 'dart:io';

import 'package:app/controller/user_controller.dart';
import 'package:app/model/push_notification_object.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../main.dart';
import '../route_generator.dart';

class Constants {
  static const String APP_NAME = 'Rojiura';

  static const int MALE = 0;
  static const int FEMALE = 1;
  static const int MAX_LENGTH = 300;

  static Future<String> loadFromAsset(String fileName) async {
    return await rootBundle.loadString("assets/cfg/$fileName");
  }

  static InputDecoration getInputDecoration(
      BuildContext context, String hintText, String labelText,
      {Icon icon}) {
    return new InputDecoration(
        hintText: hintText,
        labelText: labelText,
        icon: icon,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        hintStyle: Theme.of(context)
            .textTheme
            .bodyText2
            .merge(TextStyle(color: Theme.of(context).focusColor)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).hintColor.withOpacity(0.2))),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).hintColor)),
        labelStyle: Theme.of(context)
            .textTheme
            .bodyText2
            .merge(TextStyle(color: Theme.of(context).hintColor)));
  }

  static String getTimeAgo(String date) {
//    2020-10-26T16:34:05.000000Z
    DateTime postTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(date, true);
    timeago.setLocaleMessages('ja', timeago.JaMessages());
    return timeago.format(postTime.toLocal(), locale: 'ja');
  }

  static Map<String, String> getHeader() {
    Map<String, String> headerMap = Map();
    headerMap[HttpHeaders.contentTypeHeader] = 'application/json';
    if (currentUser.value != null && currentUser.value.uuid != null) {
      headerMap["x-api-user"] = '${currentUser.value.uuid}';
    }
    return headerMap;
  }

  static void listenToNotification(BuildContext context) {
    selectNotificationSubject.stream.listen((event) {
      if(Platform.isAndroid) {
        String data = json.decode(event)["data"]["notification"];
        Navigator.of(context).pushNamed(RouteGenerator.DETAIL,
            arguments: json.decode(data)["post_id"]);
      }else if(Platform.isIOS){
        String data = json.decode(event)["notification"];
        Navigator.of(context).pushNamed(RouteGenerator.DETAIL,
            arguments: json.decode(data)["post_id"]);
      }
    });
  }
}
