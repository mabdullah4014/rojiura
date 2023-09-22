class PushNotificationObject {
  int user_id;
  int post_id;
  int comment_id;
  int id;

//  "user_id":4,"post_id":6,"comment_id":40,"updated_at":"2020-12-10T12:49:19.000000Z","created_at":"2020-12-10T12:49:19.000000Z","id":54

  PushNotificationObject({this.user_id, this.post_id, this.comment_id,this.id});

  factory PushNotificationObject.fromJson(Map<String, dynamic> json) {
    return PushNotificationObject(
      user_id: json['user_id'],
      post_id: json['post_id'],
      comment_id: json['comment_id'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.user_id;
    data['post_id'] = this.post_id;
    data['comment_id'] = this.comment_id;
    data['id'] = this.id;
    return data;
  }
}