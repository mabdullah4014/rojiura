import 'package:app/model/comment_object.dart';
import 'package:app/model/topic_object.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/extensions.dart';

class Post {
  List<Comment> comments;
  String created_at;
  String desc;
  int id;
  String image_url = "";
  User owner;
  bool liked = false;
  int owner_id;
  int reaction_like_count;
  Topic topic;
  int topic_id;
  String updated_at;
  int comments_count;

  Post(
      {this.comments,
      this.created_at,
      this.image_url,
      this.desc,
      this.id,
      this.owner,
      this.owner_id,
      this.reaction_like_count,
      this.topic,
      this.topic_id,
      this.updated_at,
      this.liked,
      this.comments_count});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        comments: json['comments'] != null
            ? (json['comments'] as List)
                .map((i) => Comment.fromJson(i))
                .toList()
            : null,
        created_at: json['created_at'],
        image_url: json['image_url'] != null ? json['image_url'] : "",
        desc: json['desc'],
        id: json['id'],
        owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
        owner_id: json['owner_id'],
        reaction_like_count: json['reaction_like_count'] != null
            ? json['reaction_like_count']
            : 0,
        topic: json['topic'] != null ? Topic.fromJson(json['topic']) : null,
        topic_id: json['topic_id'],
        updated_at: json['updated_at'],
        comments_count: json['comments_count'],
        liked: json['liked']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.created_at;
    data['image_url'] = this.image_url;
    data['desc'] = this.desc;
    data['id'] = this.id;
    data['owner_id'] = this.owner_id;
    data['reaction_like_count'] = this.reaction_like_count;
    data['topic_id'] = this.topic_id;
    data['updated_at'] = this.updated_at;
    data['liked'] = this.liked;
    data['comments_count'] = this.comments_count;
    if (this.comments != null) {
      data['comments'] = this.comments.map((v) => v.toJson()).toList();
    }
    if (this.owner != null) {
      data['owner'] = this.owner.toJson();
    }
    if (this.topic != null) {
      data['topic'] = this.topic.toJson();
    }
    return data;
  }

  int getCommentCountOnDetail() {
    if (comments.isNullOrEmpty()) {
      return 0;
    } else
      return comments.length;
  }
}
