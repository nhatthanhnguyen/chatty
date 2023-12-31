import 'dart:convert';
import 'dart:ui';

import 'package:chatty/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class CallingUser extends StatefulWidget {
  const CallingUser({required this.userId, Key? key}) : super(key: key);

  final String userId;

  @override
  State<CallingUser> createState() => _CallingUserState();
}

class _CallingUserState extends State<CallingUser> {
  UserInfo? _userInfo;
  bool isConnected = false;
  String _token = '';
  final _storage = const FlutterSecureStorage();

  Future<void> _fetchUserInfo() async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': _token,
    };
    var request = http.Request(
        'POST', Uri.parse('http://103.142.26.18:8081/api/user/get'));
    request.body = json.encode({'user_id': widget.userId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final value = await response.stream.bytesToString();
      Map<String, dynamic> userInfoJson = jsonDecode(value);
      if (userInfoJson['info'] != null) {
        UserInfo userInfo = UserInfo.fromJson(userInfoJson['info']);
        setState(() {
          _userInfo = userInfo;
        });
      }
    }
  }

  Future<void> _fetchCurrentUser() async {
    String? token = await _storage.read(key: "token");
    setState(() {
      _token = token as String;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser().then((_) {
      _fetchUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(_userInfo?.url ?? ''),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(_userInfo?.url ?? ''),
                          radius: 60,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userInfo?.username ?? 'User',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isConnected ? 'Connected' : 'Connecting...',
                        style: TextStyle(
                          color: Colors.grey[350],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Xử lý bật/tắt loa ngoài
                          },
                          icon: const Icon(Icons.volume_up),
                          color: Colors.black,
                          iconSize: 32,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Xử lý bật/tắt micro
                          },
                          icon: const Icon(Icons.mic),
                          color: Colors.black,
                          iconSize: 32,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(
                            Icons.call_end,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
