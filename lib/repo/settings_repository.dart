
import 'package:app/model/api_response.dart';
import 'package:app/model/setting_object.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/pref_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());

/*Future<Setting> initSettings() async {
  final String url =
      '${GlobalConfiguration().get('base_url')}configs';
  final response = await http.get(url);
  ApiResponse<Setting> setting = AppUtils.getResponseObject(response);
  return setting.data;
}*/

void setBrightness(Brightness brightness) async {
  brightness == Brightness.dark
      ? PreferenceUtils.setBool("isDark", true)
      : PreferenceUtils.setBool("isDark", false);
}

Future<void> setDefaultLanguage(String language) async {
  if (language != null) {
    PreferenceUtils.setString('language', language);
  }
}

Future<String> getDefaultLanguage(String defaultLanguage) async {
  return PreferenceUtils.getString('language', defaultLanguage);
}