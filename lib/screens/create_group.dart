import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/config_api.dart';
import '../models/user.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  List<UserInfo> searchUsers = [];
  List<String> selectedUsers = [];

  List<bool> addedFriendList =
      List.filled(100, false); // Initial state: not added as friend

  String searchText = ''; // Biến lưu trữ văn bản tìm kiếm
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    searchUsers = [];
  }

  Future<void> searchFunc(String text) async {
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
      Uri.parse('$hostAPI/user/search'),
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
          searchUsers =
              userInfos.map((userInfo) => UserInfo.fromJson(userInfo)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo nhóm'),
        centerTitle: true,
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
                          onChanged: (value) async {
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
                      final isSelected =
                          selectedUsers.contains(result.userId.toString());

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
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  selectedUsers.add(result.userId.toString());
                                } else {
                                  selectedUsers
                                      .remove(result.userId.toString());
                                }
                                print("pickeds: $selectedUsers");
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện tạo nhóm chat
                    // Ví dụ: Tạo nhóm chat với các người dùng đã được đánh dấu
                    print(
                        'Đã tạo nhóm chat với các người dùng: $selectedUsers');
                  },
                  child: const Text('Tạo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchResult {
  final String name;
  final String imageUrl;

  SearchResult({required this.name, required this.imageUrl});
}
