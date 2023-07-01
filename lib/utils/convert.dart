import 'package:chatty/models/user.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

types.User convertToUserType(UserInfo userInfo) {
  return types.User(
    id: userInfo.userId.toString(),
    imageUrl: userInfo.url,
    firstName: userInfo.username,
  );
}
