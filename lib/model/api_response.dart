class ApiResponse<T> {
  int status;
  String message;
  dynamic data;

  ApiResponse.success(dynamic response) {
    status = 200;
    data = response;
    message = "Success";
  }

  ApiResponse.error(int status, String message) {
    this.status = status;
    this.message = message;
    this.data = null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["status"] = status;
    map["message"] = message;
    map["data"] = data;
    return map;
  }
}
