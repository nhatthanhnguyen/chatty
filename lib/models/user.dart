class User {
  String? userId;
  String? username;
  String? phoneNumber;
  String? email;
  String? status;
  String? gender;
  String? url;

  User(
      {this.userId,
      this.username,
      this.phoneNumber,
      this.email,
      this.status,
      this.gender,
      this.url});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    status = json['status'];
    gender = json['gender'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['username'] = username;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['status'] = status;
    data['gender'] = gender;
    data['url'] = url;
    return data;
  }
}
