import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class UserProfile {
  String name;
  final String email;
  final String phoneNumber;
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
  bool _isEditingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditingName() {
    setState(() {
      _isEditingName = !_isEditingName;
    });
  }

  void _saveName() {
    // Perform save name action
    // You can update the UserProfile object or make an API call to save the name
    String newName = _nameController.text;
    // Update the name in the UserProfile object
    widget.userProfile.name = newName;
    _toggleEditingName();
  }

  void _openImageLibrary() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Update the avatarUrl in the UserProfile object
      widget.userProfile.avatarUrl = pickedImage.path;
      setState(() {});
    }
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
                onTap: _openImageLibrary,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          NetworkImage(widget.userProfile.avatarUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: _openImageLibrary,
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _isEditingName
                          ? TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Họ và tên',
                                hintText: 'Nhập họ và tên',
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                              ),
                            )
                          : TextFormField(
                              controller: TextEditingController(
                                  text: widget.userProfile.name),
                              enabled: false,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Họ và tên',
                                hintText: 'Nhập họ và tên',
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_isEditingName) {
                          _saveName();
                        } else {
                          _toggleEditingName();
                        }
                      },
                      icon: _isEditingName
                          ? const Icon(Icons.save)
                          : const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: TextEditingController(
                            text: widget.userProfile.email),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
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
                  ],
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
