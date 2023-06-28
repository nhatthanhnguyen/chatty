import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final List<User> userList = List.generate(
    10,
    (index) => User(
      name: 'User ${index + 1}',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/b/b6/Image_created_with_a_mobile_phone.png',
    ),
  );

  final List<Chat> chatList = List.generate(
    10,
    (index) => Chat(
      user: User(
        name: 'User ${index + 1}',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/b/b6/Image_created_with_a_mobile_phone.png',
      ),
      lastMessage: 'Last message ${index + 1}',
      time: '10:${index.toString().padLeft(2, '0')}',
    ),
  );

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
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
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      final user = userList[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(user.imageUrl),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.name.length > 10
                                  ? '${user.name.substring(0, 10)}...'
                                  : user.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      final chat = chatList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(chat.user.imageUrl),
                        ),
                        title: Text(chat.user.name),
                        subtitle: Text(
                          '${chat.lastMessage} • ${chat.time}',
                        ),
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
                            'https://th.bing.com/th/id/R.6af6fd9c37f0de4abb34ea0fd20acce3?rik=55mqMmrTutVR0Q&pid=ImgRaw&r=0',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'User Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
  }
}

class User {
  final String name;
  final String imageUrl;

  User({required this.name, required this.imageUrl});
}

class Chat {
  final User user;
  final String lastMessage;
  final String time;

  Chat({required this.user, required this.lastMessage, required this.time});
}
