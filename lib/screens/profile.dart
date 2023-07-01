import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class UserProfile {
  String name;
  String email;
  String phoneNumber;
  String avatarUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
  });
}

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  const ProfileScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // void setUserInfo() {
  //   getUserInfo();

  // }

  Future<void> getUserInfo() async {
    const storage = FlutterSecureStorage();
    String? userText = await storage.read(key: "user");
    final Map<String, dynamic> jsonUser = jsonDecode(userText.toString());
    UserInfo user = UserInfo.fromJson(jsonUser);
    widget.userProfile.name = user.username.toString();
    widget.userProfile.avatarUrl = user.url.toString();
    widget.userProfile.email = user.email.toString();
    widget.userProfile.phoneNumber = user.phoneNumber.toString();
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 30,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 160, // Kích thước của hình tròn
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Màu nền của hình tròn
                    border: Border.all(
                      color: Colors.black, // Màu viền của hình tròn
                      width: 2.0, // Độ dày của viền
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 80, // Bán kính của Avatar
                    backgroundImage: NetworkImage(widget.userProfile.avatarUrl),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextFormField(
                  controller:
                      TextEditingController(text: widget.userProfile.name),
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Username',
                    hintText: 'Nhập username',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextFormField(
                  controller:
                      TextEditingController(text: widget.userProfile.email),
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Email',
                    hintText: 'Nhập email',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextFormField(
                  controller: TextEditingController(
                      text: widget.userProfile.phoneNumber),
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Số điện thoại',
                    hintText: 'Nhập số điện thoại',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.go('/');
                },
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
