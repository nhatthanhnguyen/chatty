import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/config_api.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

class OTPConfirmationScreen extends StatefulWidget {
  const OTPConfirmationScreen({super.key});

  @override
  _OTPConfirmationScreenState createState() => _OTPConfirmationScreenState();
}

class _OTPConfirmationScreenState extends State<OTPConfirmationScreen> {
  String _otp = '';
  bool _hasError = false;
  bool _success = false;
  String showOTP = "OTP không đúng";

  void _updateOTP(String value) {
    setState(() {
      _otp = value;
      _hasError = false;
    });
  }

  Future<bool> cOTP(String otp) async {
    const storage = FlutterSecureStorage();
    String? email = await storage.read(key: "email_register");

    var headers = {
      'Content-Type': 'application/json',
    };

    var requestBody = {
      "email": email,
      "otp": otp,
    };

    var request = http.Request(
      'POST',
      Uri.parse('$hostAPI/auth/verify-otp'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonLogin = jsonDecode(responseBody);
      if (jsonLogin['sub_return_code'].toString() == "1000") {
        _hasError = false; // Đánh dấu thông tin đăng nhập sai
        return true;
      } else {
        setState(() {
          _hasError = true; // Đánh dấu thông tin đăng nhập sai
        });
        return false;
      }
    } else {
      setState(() {
        _hasError = true; // Đánh dấu thông tin đăng nhập sai
      });
      return false;
    }
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: const Text('Đăng kí thành công'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmOTP(BuildContext context) async {
    if (_otp.length == 6) {
      bool? isSuccess = await cOTP(_otp);
      if (isSuccess) {
        setState(() {
          _hasError = true;
          showOTP = "Đăng kí thành công";
        });
        await Future.delayed(const Duration(seconds: 2)); // Đợi 2 giây
        context.push("/");
        _success = true;
      }
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _otp.length == 6;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận OTP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Xác nhận OTP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                maxLength: 6,
                keyboardType: TextInputType.number,
                onChanged: _updateOTP,
                decoration: InputDecoration(
                  hintText: 'Nhập OTP',
                  errorText: _hasError ? showOTP : null,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                isButtonEnabled ? _confirmOTP(context) : null;
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }
}
