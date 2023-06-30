import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../constants/config_api.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;

  @override
  void initState() {
    isRegisterError = false; // Thêm biến kiểm tra lỗi đăng nhập
    super.initState();
  }

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isRegisterError = false;
  final _phoneRegex = RegExp(r'^0[0-9]*$');
  final _emailRegex = RegExp(
    r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$',
  );

  void _validateEmail(String value) {
    setState(() {
      if (!_emailRegex.hasMatch(value)) {
        _errorMessageMail = 'Email không chính xác';
      } else {
        _errorMessageMail = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value != _passwordController.text) {
        _eroErrorMessagePassword = 'Mật khẩu không khớp';
      } else {
        _eroErrorMessagePassword = null;
      }
    });
  }

  String? _errorMessage;
  String? _errorMessageMail;
  String? _eroErrorMessagePassword;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber(String value) {
    setState(() {
      if (!_phoneRegex.hasMatch(value)) {
        _errorMessage = 'Số điện thoại không hợp lệ';
      } else {
        _errorMessage = null;
      }
    });
  }

  Future<bool> _register(String name, String phone, String username,
      String email, String pass, String confirm) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    var requestBody = {
      "username": username,
      "email": email,
      "phone_number": phone,
      "password": pass,
      "gender": "male",
      "date_of_birth": "18/12/2001",
    };

    var request = http.Request(
      'POST',
      Uri.parse('$hostAPI/auth/register'),
    );
    request.headers.addAll(headers);
    request.body = json.encode(requestBody);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonLogin = jsonDecode(responseBody);
      if (jsonLogin['sub_return_code'].toString() == "1000") {
        const storage = FlutterSecureStorage();
        await storage.write(key: "email_register", value: email);
        isRegisterError = false; // Đánh dấu thông tin đăng nhập sai
        return true;
      } else {
        setState(() {
          isRegisterError = true; // Đánh dấu thông tin đăng nhập sai
        });
        return false;
      }
    } else {
      setState(() {
        isRegisterError = true; // Đánh dấu thông tin đăng nhập sai
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 50,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
          left: 30,
          right: 30,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Đăng ký",
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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Họ và tên',
                    hintText: 'Nhập họ và tên',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _phoneController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onChanged: _validatePhoneNumber,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Số điện thoại',
                    hintText: 'Nhập số điện thoại',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    errorText: _errorMessage != null &&
                            _phoneController.text.isNotEmpty
                        ? _errorMessage
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tên đăng nhập',
                    hintText: 'Nhập tên đăng nhập',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _emailController,
                  onChanged: _validateEmail, // Gọi hàm kiểm tra regex
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Nhập email',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    errorText: _errorMessageMail != null &&
                            _emailController.text.isNotEmpty
                        ? _errorMessageMail
                        : null,
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
                    border: const OutlineInputBorder(),
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
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  onChanged:
                      _validateConfirmPassword, // Gọi hàm kiểm tra xác nhận mật khẩu
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Xác nhận mật khẩu',
                    hintText: 'Nhập lại mật khẩu',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    errorText: _eroErrorMessagePassword != null &&
                            _confirmPasswordController.text.isNotEmpty
                        ? _eroErrorMessagePassword
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isRegisterError) // Hiển thị thông báo lỗi nếu thông tin đăng nhập sai
                const Text(
                  "Thông tin đăng kí chưa chính xác!",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true; // Bắt đầu hiệu ứng loading
                  });

                  bool? isSuccess = await _register(
                    _nameController.text,
                    _phoneController.text,
                    _usernameController.text,
                    _emailController.text,
                    _passwordController.text,
                    _confirmPasswordController.text,
                  );

                  setState(() {
                    isLoading = false; // Kết thúc hiệu ứng loading
                  });

                  if (isSuccess) {
                    context.push("/otp");
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
