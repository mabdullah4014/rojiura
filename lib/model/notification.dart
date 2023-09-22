import 'package:app/model/post_object.dart';

class Notif {
  String created_at;
  int id;
  Post post;

  Notif({this.created_at, this.id, this.post});

  factory Notif.fromJson(Map<String, dynamic> json) {
    return Notif(
      created_at: json['created_at'],
      id: json['id'],
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.created_at;
    data['id'] = this.id;
    if (this.post != null) {
      data['post'] = this.post.toJson();
    }
    return data;
  }
}
