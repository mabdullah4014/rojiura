import 'package:flutter/cupertino.dart';

class Setting {
  String appName = "";
  String defaultCurrency;
  String mainColor;
  String mainDarkColor;
  String secondColor;
  String secondDarkColor;
  String accentColor;
  String accentDarkColor;
  String scaffoldDarkColor;
  String scaffoldColor;
  String googleMapsKey;
  ValueNotifier<Locale> mobileLanguage = new ValueNotifier(Locale('en', ''));
  String appVersion;
  int sliderDuration = 4;
  String how_it_works;
  String about;
  String terms_and_conditions;
  String contact_us;
  String fb;
  String insta;
  String twitter;

  Setting();

  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    appName = jsonMap['app_name'] ?? null;
    mainColor = jsonMap['main_color'] ?? null;
    mainDarkColor = jsonMap['main_dark_color'] ?? '';
    secondColor = jsonMap['second_color'] ?? '';
    secondDarkColor = jsonMap['second_dark_color'] ?? '';
    accentColor = jsonMap['accent_color'] ?? '';
    accentDarkColor = jsonMap['accent_dark_color'] ?? '';
    scaffoldDarkColor = jsonMap['scaffold_dark_color'] ?? '';
    scaffoldColor = jsonMap['scaffold_color'] ?? '';
    googleMapsKey = jsonMap['google_maps_key'] ?? null;
    mobileLanguage.value = Locale(jsonMap['mobile_language'] ?? "en", '');
    appVersion = jsonMap['app_version'] ?? '';
    defaultCurrency = jsonMap['default_currency'] ?? '';
    sliderDuration = int.parse(jsonMap['slider_duration']) ?? 4;
    how_it_works = jsonMap['how_it_works'] ?? '';
    about = jsonMap['about'] ?? '';
    terms_and_conditions = jsonMap['terms_and_conditions'] ?? '';
    contact_us = jsonMap['contact_us'] ?? '';
    fb = jsonMap['fb'] ?? '';
    insta = jsonMap['insta'] ?? '';
    twitter = jsonMap['twitter'] ?? '';
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["app_name"] = appName;
    map["default_currency"] = defaultCurrency;
    map["mobile_language"] = mobileLanguage.value.languageCode;
    return map;
  }
}
