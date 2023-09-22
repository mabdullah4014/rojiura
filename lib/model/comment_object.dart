import 'package:app/controller/user_controller.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/extensions.dart';

class Comment {
  String body;
  String created_at;
  int id;
  int post_id;
  int reaction_like_count = 0;
  String updated_at;
  User user;
  int user_id;
  int user_index;
  int index;
  bool liked = false;
  int parent_comment_id;
  List<dynamic> reacters;

  Comment(
      {this.body,
      this.created_at,
      this.id,
      this.post_id,
      this.updated_at,
      this.user,
      this.user_id,
      this.user_index,
      this.index,
      this.liked,
      this.parent_comment_id,
      this.reacters});

  factory Comment.fromJson(Map<dynamic, dynamic> json) {
    return Comment(
        body: json['body'],
        created_at: json['created_at'],
        id: json['id'],
        post_id: json['post_id'],
        updated_at: json['updated_at'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        user_id: json['user_id'],
        user_index: json['user_index'] != null ? json['user_index'] : 0,
        index: json['index'] != null ? json['index'] : 0,
        liked: json['liked'] != null ? json['liked'] : false,
        parent_comment_id: json['parent_comment_id'] != null ? json['parent_comment_id'] : -1,
        reacters: json['reacters'] != null ? json['reacters'] : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['body'] = this.body;
    data['created_at'] = this.created_at;
    data['id'] = this.id;
    data['post_id'] = this.post_id;
    data['updated_at'] = this.updated_at;
    data['user_id'] = this.user_id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['user_index'] = this.user_index;
    data['index'] = this.index;
    data['liked'] = this.liked;
    data['parent_comment_id'] = this.parent_comment_id;
    data['reacters'] = this.reacters;
    return data;
  }

  int getLikeCount() {
    if (reacters.isNullOrEmpty()) {
      return 0;
    } else
      return reacters.length;
  }

  bool isLiked() {
    if (reacters.isNullOrEmpty()) {
      return false;
    } else
      return reacters.contains(currentUser.value.id);
  }
}
