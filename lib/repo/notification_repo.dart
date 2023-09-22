
import 'package:app/model/api_response.dart';
import 'package:app/model/notification.dart';
import 'package:app/utils/app_utils.dart';
import 'package:app/utils/constants.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

Future<ApiResponse<List<Notif>>> apiGetNotifications(int page) async {
  final String url =
      '${GlobalConfiguration().get('base_url')}notifications?page=$page';
  final client = new http.Client();
  final response = await client.get(url, headers: Constants.getHeader());
  return AppUtils.getResponseObject(response);
}
