class Group {
  String? groupId;
  String? groupName;
  String? avatarUrl;

  Group({this.groupId, this.groupName, this.avatarUrl});

  Group.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id'];
    groupName = json['group_name'];
    avatarUrl = json['avatar_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_id'] = groupId;
    data['group_name'] = groupName;
    data['avatar_url'] = avatarUrl;
    return data;
  }
}
