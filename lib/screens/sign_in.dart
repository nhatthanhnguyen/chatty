import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../constants/config_api.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    isLoginError = false; // Thêm biến kiểm tra lỗi đăng nhập
    super.initState();
  }

  bool _showPassword = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoginError = false; // Thêm biến kiểm tra lỗi đăng nhập

  void writeToken(String value) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "token", value: value);
  }

  Future<bool> login(String userName, String password) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    var requestBody = {
      "phone_number": userName,
      "password": password,
    };

    var request = http.Request(
      'POST',
      Uri.parse('$hostAPI/auth/login'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonLogin = jsonDecode(responseBody);
      if (jsonLogin['sub_return_code'].toString() == "1000") {
        String setCookie = response.headers["set-cookie"].toString();
        int startIndex = setCookie.indexOf('pchat=') + 'pchat='.length;
        int endIndex = setCookie.indexOf(';', startIndex);
        String token = setCookie.substring(startIndex, endIndex);
        // write token
        writeToken(token);

        isLoginError = false;
        return true;
      } else {
        setState(() {
          isLoginError = true; // Đánh dấu thông tin đăng nhập sai
        });
        return false;
      }
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoginError = true; // Đánh dấu thông tin đăng nhập sai
      });
      return false;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Đăng nhập",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  labelText: 'Tên đăng nhập',
                  hintText: 'Nhập tên đăng nhập',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoginError) // Hiển thị thông báo lỗi nếu thông tin đăng nhập sai
              const Text(
                "Số điện thoại hoặc mật khẩu không đúng",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                bool isLoginSuccess = await login(
                    _usernameController.text, _passwordController.text);
                if (isLoginSuccess) {
                  context.push("/chat");
                }
              },
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
