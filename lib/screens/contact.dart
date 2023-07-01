import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../constants/config_api.dart';
import '../models/user.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with SingleTickerProviderStateMixin {
  List<UserInfo> searchUsers = [];
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool _isMenuOpen = false;

  Future<void> removeFriend(String userId) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");
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
      Uri.parse('$hostAPI/friend/remove-friend'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {}
  }

  void _removeFriend(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có muốn xóa bạn này?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  removeFriend(searchUsers[index].userId.toString());
                  searchUsers.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Có'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Không'),
            ),
          ],
        );
      },
    );
  }

  List<bool> addedFriendList =
      List.filled(100, false); // Initial state: not added as friend

  String searchText = ''; // Biến lưu trữ văn bản tìm kiếm
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    searchUsers = [];
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
    searchUsers = [];
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

  Future<void> searchFunc(String text) async {
    if (text.isEmpty) {
      setState(() {
        searchUsers = [];
      });
    } else {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: "token");
      // call api
      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'pchat=$token',
      };
      var requestBody = {
        "username": text,
      };
      var request = http.Request(
        'POST',
        Uri.parse('$hostAPI/user/search-friend'),
      );
      request.headers.addAll(headers);
      request.body = json.encode(requestBody);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonListUsers = jsonDecode(responseBody);
        if (jsonListUsers['sub_return_code'].toString() == "1000") {
          bool containsKey = jsonListUsers.containsKey("user_infos");
          if (containsKey) {
            List<dynamic> userInfos = jsonListUsers['user_infos'];
            searchUsers = userInfos
                .map((userInfo) => UserInfo.fromJson(userInfo))
                .toList();
            setState(() {});
          } else {
            setState(() {
              searchUsers = [];
            });
          }
        } else {
          setState(() {
            searchUsers = [];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liên hệ'),
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // Handle search action
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập từ khóa...',
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = searchController.text;
                              searchFunc(searchText);
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            searchText = '';
                            searchFunc(searchText);
                            print("?????");
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchUsers.length,
                    itemBuilder: (context, index) {
                      final result = searchUsers[index];
                      final isAdded = addedFriendList[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(result.url.toString()),
                        ),
                        title: Text(result.username.toString()),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _removeFriend(index);
                              });
                            },
                            child: Text(
                              isAdded ? 'Xóa bạn' : 'Xóa bạn',
                              style: TextStyle(
                                color: isAdded ? Colors.black54 : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          print("username: =>>> ${result.username}");
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
          // Positioned.fill(
          //   child: GestureDetector(
          //     onTap: () {
          //       if (_isMenuOpen) {
          //         _toggleMenu();
          //       }
          //     },
          //   ),
          // ),
          // Positioned.fill(
          //   child:
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
                                  context.push("/chat");
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.contacts),
                                title: const Text('Liên hệ'),
                                onTap: () {
                                  _toggleMenu();
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

          // ),
        ],
      ),
    );
  }
}
