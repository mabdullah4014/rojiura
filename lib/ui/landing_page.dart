import 'dart:convert';
import 'dart:ui';

import 'package:app/controller/user_controller.dart';
import 'package:app/generated/l10n.dart';
import 'package:app/model/user_request.dart';
import 'package:app/model/user_response.dart';
import 'package:app/route_generator.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/pref_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends StateMVC<LandingPage> {
  String selectedDate = "yyyy/MM/dd";
  final double headingSize = 30;
  final double dobTextSize = 35;
  int selectedGender = Constants.MALE;
  UserController _con = UserController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Constants.listenToNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            title: Text(Constants.APP_NAME,
                style: Theme.of(context).textTheme.headline6.merge(TextStyle(
                      color: Colors.white,
                    )))),
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: AppUtils.getColorFromHash(AppUtils.lightGreyColor),
                child: Column(
                    //alignment:new Alignment(x, y)
                    children: <Widget>[
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dobHeading(),
                          SizedBox(height: 5),
                          _dob(),
                          SizedBox(height: 10),
                          _genderHeading(),
                          SizedBox(height: 10),
                          _genderSelectionLayout(),
                          SizedBox(height: 20),
                          _dummyText()
                        ],
                      ))),
                      Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: _button())
                    ]))));
  }

  Widget _dobHeading() {
    return Text(S.of(context).birthday,
        style: TextStyle(fontSize: headingSize, color: Colors.white));
  }

  Widget _dob() {
    return InkWell(
        onTap: () async {
          final DateTime picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(), // Refer step 1
            firstDate: DateTime(1960),
            lastDate: DateTime.now(),
          );
          if (picked != null)
            setState(() {
              selectedDate =
                  '${picked.toLocal()}'.split(' ')[0].replaceAll("-", "/");
            });
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Text(selectedDate,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: dobTextSize))));
  }

  Widget _genderHeading() {
    return Text(S.of(context).gender,
        style: TextStyle(fontSize: headingSize, color: Colors.white));
  }

  Widget _dummyText() {
    return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(children: [
          Text(S.of(context).terms_of_service,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          Padding(
              padding: EdgeInsets.all(10),
              child: Text(S.of(context).dummy_text,
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15)))
        ]));
  }

  Widget _genderSelectionLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _genderLayout(Constants.MALE),
        _genderLayout(Constants.FEMALE)
      ],
    );
  }

  Widget _genderLayout(int gender) {
    return InkWell(
        onTap: () {
          setState(() {
            if (selectedGender == Constants.MALE) {
              selectedGender = Constants.FEMALE;
            } else {
              selectedGender = Constants.MALE;
            }
          });
        },
        child: Container(
            padding: EdgeInsets.all(10),
            decoration: new BoxDecoration(
              color: (selectedGender == gender
                  ? Colors.white
                  : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Icon(
                gender == Constants.MALE
                    ? FontAwesomeIcons.male
                    : FontAwesomeIcons.female,
                color: gender == Constants.MALE
                    ? AppUtils.getColorFromHash('#2EA7F2')
                    : AppUtils.getColorFromHash('#FF6CCA'),
                size: 70)));
  }

  Widget _button() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        ButtonTheme(
            minWidth: MediaQuery.of(context).size.width,
            child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 20),
                onPressed: () {
                  if (isValid()) {
                    String token = PreferenceUtils.getString("push_token", "");
                    AppUtils.onLoading(context);
                    _con.registerUser(
                        UserRequest(selectedDate, selectedGender, token),
                        apiResponse: (response) {
                      Navigator.pop(context);
                      if (response.status == 200) {
                        UserResponse userResponse =
                            UserResponse.fromJson(response.data);
                        PreferenceUtils.setString(
                            'user', json.encode(userResponse.user));
                        currentUser.value = userResponse.user;
                        Navigator.of(context)
                            .popAndPushNamed(RouteGenerator.HOME);
                      } else {
                        AppUtils.showMessage(
                            context, S.of(context).app_name, response.message);
                      }
                    });
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(
                        color: AppUtils.getColorFromHash('#6A6A6A'))),
                color: AppUtils.getColorFromHash(AppUtils.darkGreyColor),
                child: Text(
                  '${Constants.APP_NAME} ${S.of(context).enter}',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ))),
        SizedBox(height: 5),
        Text(S.of(context).terms_of_service_agreement,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.white)),
      ]),
    );
  }

  bool isValid() {
    if (selectedDate == "yyyy/MM/dd") {
      AppUtils.showMessage(
          context, S.of(context).app_name, S.of(context).select_dob);
      return false;
    }
    return true;
  }
}
