import 'package:app/model/api_response.dart';
import 'package:app/model/notification.dart';
import 'package:app/repo/notification_repo.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class NotificationController extends ControllerMVC {
  void getNotifications(
      {int page, Function(ApiResponse<List<Notif>>) apiResponse}) async {
    await apiGetNotifications(page).then((response) {
      apiResponse(response);
    });
  }
}
