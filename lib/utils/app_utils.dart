import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:app/generated/l10n.dart';
import 'package:app/model/api_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class AppUtils {
  static const String darkGreyColor = '#262626';
  static const String lightGreyColor = '#595959';
  static const String tabBgColor = '#8C8C8C';
  static const String postTextColor = '#0D0D0D';

  static ApiResponse<T> getResponseObject<T>(Response response) {
    print("Api Request Url : " + response.request.url.toString());
    print("Api Code : " + response.statusCode.toString());
    final int responseCode = response.statusCode;
    if (responseCode >= 200 && responseCode <= 299) {
      if (response.body.isNotEmpty) {
        print("Api Response : " + response.body);
        dynamic body = json.decode(response.body);
        return ApiResponse.success(body);
      } else {
        return ApiResponse.success(null);
      }
    } else if (responseCode == 401) {
      return ApiResponse.error(responseCode, "Unauthorized");
    } else if (responseCode >= 400 && responseCode <= 499) {
      return ApiResponse.error(responseCode, "Client error($responseCode)");
    } else if (responseCode >= 500 && responseCode <= 599) {
      return ApiResponse.error(responseCode, "Server error($responseCode)");
    } else {
      return ApiResponse.error(responseCode, "Unexpected error($responseCode)");
    }
  }

  static Color getColorFromHash(String color) {
    try {
      return Color(int.parse(color.replaceAll("#", "0xFF")));
    } catch (e) {
      return Color(0xFFCCCCCC) /*.withOpacity(opacity)*/;
    }
  }

  static Future<String> loadJsonFromAssets(BuildContext context) async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/data.json");
    return json.decode(data);
  }

  static var random = new Random();

  static Color getRandomColor() {
    return Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
  }

  static Widget submitButton(
      BuildContext context, String text, VoidCallback onPress) {
    return ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        child: RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 10),
            onPressed: onPress,
            color: Theme.of(context).primaryColor,
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.white),
            )));
  }

  static void showMessage(BuildContext context, String title, String message,
      {VoidCallback callback}) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Colors.black87)),
          content: Text(message, style: TextStyle(color: Colors.red)),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).ok),
              onPressed: () {
                if (callback != null)
                  callback();
                else
                  Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void yesNoDialog(BuildContext context, String title, String message,
      VoidCallback onYesClick) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Colors.black87)),
          content: Text(message, style: TextStyle(color: Colors.red)),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).yes),
              onPressed: () {
                onYesClick();
              },
            ),
            FlatButton(
              child: Text(S.of(context).no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static onLoading(BuildContext context, {String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor)),
                SizedBox(height: 10),
                Text(message != null ? message : S.of(context).loading,
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget getCircularProgress(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
  }
}
