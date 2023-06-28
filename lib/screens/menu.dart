import 'package:flutter/material.dart';

class SideMenuScreen extends StatefulWidget {
  const SideMenuScreen({Key? key}) : super(key: key);

  @override
  _SideMenuScreenState createState() => _SideMenuScreenState();
}

class _SideMenuScreenState extends State<SideMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
        title: const Text('Main Screen'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleMenu,
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isMenuOpen) {
                _toggleMenu();
              }
            },
          ),
          SlideTransition(
            position: _animation,
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                width: MediaQuery.of(context).size.width * (3 / 5),
                color: Colors.green,
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
                              // Xử lý khi nhấn vào Đoạn Chat
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.contacts),
                            title: const Text('Liên hệ'),
                            onTap: () {
                              // Xử lý khi nhấn vào Liên hệ
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.search),
                            title: const Text('Tìm kiếm'),
                            onTap: () {
                              // Xử lý khi nhấn vào Tìm kiếm
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Thông tin cá nhân'),
                            onTap: () {
                              // Xử lý khi nhấn vào Thông tin cá nhân
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
        ],
      ),
    );
  }
}
