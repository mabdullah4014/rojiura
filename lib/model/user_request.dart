class UserRequest {
  String dob;
  int gender;
  String push_token;

  UserRequest(this.dob, this.gender,this.push_token);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['push_token'] = this.push_token;
    return data;
  }
}
