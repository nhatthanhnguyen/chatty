import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../constants/config_api.dart';
import '../models/conversation_chat.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'package:timer_builder/timer_builder.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool _isMenuOpen = false;
  UserInfo userInfo = UserInfo(username: "");
  List<UserInfo> listFriends = [];
  String userIDReal = "";

  Future<void> getListFriends() async {
    // /friend/get-all-friend-by-user-id
    const storage = FlutterSecureStorage();
    String? userId = await storage.read(key: "userId");
    String? token = await storage.read(key: "token");
    userIDReal = userId.toString();

    // call api
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'pchat=$token',
    };
    var requestBody = {
      "user_id": userId,
    };
    var request = http.Request(
      'POST',
      Uri.parse('$hostAPI/friend/get-all-friend-by-user-id'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonListFriends = jsonDecode(responseBody);
      if (jsonListFriends['sub_return_code'].toString() == "1000") {
        List<dynamic> userInfos = jsonListFriends['user_infos'];
        listFriends =
            userInfos.map((userInfo) => UserInfo.fromJson(userInfo)).toList();

        setState(() {});
      } else {
        print(response.reasonPhrase);
        // setState(() {
        //   // isLoginError = true; // Đánh dấu thông tin đăng nhập sai
        // });
      }
    }
  }

  List<ConversationMessage> listConversations = [];

  Future<void> getConversations() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");
    String? userId = await storage.read(key: "userId");

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'pchat=$token',
    };
    var requestBody = {
      "recipient_id": userId,
    };
    var request = http.Request(
      'POST',
      Uri.parse('$hostAPI/message/get-last-chat-history'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonListConversations =
          jsonDecode(responseBody);
      if (jsonListConversations['sub_return_code'].toString() == "1000") {
        List<dynamic> listConver = jsonListConversations['room'];
        listConversations = listConver
            .map((conver) => ConversationMessage.fromJson(conver))
            .toList();
        listConversations = listConversations.reversed.toList();
        setState(() {});
      } else {
        print(response.reasonPhrase);
        // setState(() {
        //   // isLoginError = true; // Đánh dấu thông tin đăng nhập sai
        // });
      }
    }
  }

  final List<Chat> chatList = List.generate(
    10,
    (index) => Chat(
      user: User1(
        name: 'User ${index + 1}',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/b/b6/Image_created_with_a_mobile_phone.png',
      ),
      lastMessage: 'Last message ${index + 1}',
      time: '10:${index.toString().padLeft(2, '0')}',
    ),
  );
  Future<void> getUserInfo() async {
    print("lay thong tin");
    const storage = FlutterSecureStorage();
    String? userText = await storage.read(key: "user");
    final Map<String, dynamic> jsonUser = jsonDecode(userText.toString());
    UserInfo user = UserInfo.fromJson(jsonUser);
    userInfo = user;
    print("info:  ${userInfo.username}");
    setState(() {});
  }

  String getString(ConversationMessage chat) {
    String temp = chat.chatMessage!.resourceType.toString() == 'text'
        ? chat.chatMessage!.message.toString()
        : (chat.chatMessage!.resourceType.toString() == 'image' &&
                chat.chatMessage!.senderId.toString() == userIDReal)
            ? 'Bạn đã gửi 1 ảnh'
            : (chat.chatMessage!.resourceType.toString() == 'image')
                ? 'Hình ảnh'
                : (chat.chatMessage!.senderId.toString() == userIDReal)
                    ? 'Bạn đã gửi 1 file'
                    : 'File';

    DateFormat inputFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime dateTime = inputFormatter.parse(chat.chatMessage!.time.toString());
    dateTime = dateTime.add(const Duration(hours: 7));

    String t;
    if (dateTime.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      // Nếu dateTime là ngày hôm qua hoặc những ngày trước đó
      t = DateFormat.E().format(dateTime); // Thứ trong lịch Tây
    } else {
      t = DateFormat.Hm().format(dateTime); // Giờ và phút (HH:mm)
    }

    String res = '$temp • $t';
    return res;
  }

  @override
  void initState() {
    super.initState();
    userInfo = UserInfo(username: "");
    getListFriends();
    getUserInfo();
    getConversations();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    startTimer();
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Timer? _timer;

  void startTimer() {
    // Tạo một timer chạy sau mỗi 5 giây
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Thực hiện các thay đổi mà bạn muốn khi tải lại màn hình
      setState(() {
        getListFriends();
        getUserInfo();
        getConversations();
        print("reloading");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 10),
        builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Đoạn chat'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _toggleMenu();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                context.push('/group/create');
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listFriends.length,
                      itemBuilder: (context, index) {
                        final user = listFriends[index];
                        return GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện khi nhấn vào phần tử
                            context.push("/chat/user/${user.userId}");
                            print("Clicked on user: ${user.username}");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(user.url.toString()),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.username.toString().length > 10
                                      ? '${user.username.toString().substring(0, 10)}...'
                                      : user.username.toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: listConversations.length,
                      itemBuilder: (context, index) {
                        final chat = listConversations[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(chat.roomAvt.toString()),
                          ),
                          title: Text(chat.roomName.toString()),
                          subtitle: Text(getString(chat)),
                          onTap: () {
                            if (chat.isGroup != null && chat.isGroup == true) {
                              context.push("/chat/group/${chat.roomId}");
                            } else {
                              context.push("/chat/user/${chat.roomId}");
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_isMenuOpen)
              Positioned(
                left: MediaQuery.of(context).size.width * (3 / 5),
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * (2 / 5),
                child: GestureDetector(
                  onTap: () {
                    if (_isMenuOpen) {
                      _toggleMenu();
                    }
                  },
                ),
              ),
            if (_isMenuOpen)
              Positioned(
                right: MediaQuery.of(context).size.width * (2 / 5),
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * (3 / 5),
                child: SlideTransition(
                  position: _animation,
                  child: GestureDetector(
                    // onTap: _toggleMenu,
                    child: Container(
                      width: MediaQuery.of(context).size.width * (3 / 5),
                      color: Colors.blue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 50),
                          const CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              'https://res.cloudinary.com/dbk0cmzcb/image/upload/v1687548264/kb6ege5y9jgmxxxfselw.png',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            userInfo.username!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.chat),
                                  title: const Text('Đoạn Chat'),
                                  onTap: () {
                                    _toggleMenu();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.contacts),
                                  title: const Text('Liên hệ'),
                                  onTap: () {
                                    context.push("/contact");
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.videocam),
                                  title: const Text('Cuộc gọi'),
                                  onTap: () {
                                    context.push("/call");
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.search),
                                  title: const Text('Tìm kiếm'),
                                  onTap: () {
                                    context.push("/search");
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.person),
                                  title: const Text('Thông tin cá nhân'),
                                  onTap: () {
                                    context.push("/profile");
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class User1 {
  final String name;
  final String imageUrl;

  User1({required this.name, required this.imageUrl});
}

class Chat {
  final User1 user;
  final String lastMessage;
  final String time;

  Chat({required this.user, required this.lastMessage, required this.time});
}
