

class Topic {
  int id;
  String name;
  String created_at;

  Topic({this.id, this.name, this.created_at});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
        id: json['id'] != null ? json['id'] : -1,
        name: json['name'] != null ? json['name'] : "",
        created_at: json['created_at'] != null ? json['created_at'] : "");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['created_at'] = this.created_at;
    return data;
  }
}
