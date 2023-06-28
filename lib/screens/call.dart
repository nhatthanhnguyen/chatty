import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool _isMenuOpen = false;
  List<Map<String, dynamic>> recentCalls = [];

  void fakeRecentCalls() {
    for (int i = 0; i < 10; i++) {
      bool isVideoCall = i % 2 == 0;
      String type;
      IconData icon;
      Color color;

      if (i % 3 == 0) {
        type = 'Cuộc gọi đến';
        icon = Icons.call_received;
        color = Colors.green;
      } else if (i % 3 == 1) {
        type = 'Cuộc gọi đi';
        icon = Icons.call_made;
        color = Colors.blue;
      } else {
        type = 'Cuộc gọi nhỡ';
        icon = Icons.call_missed;
        color = Colors.red;
      }

      DateTime dateTime = DateTime.now().subtract(Duration(days: i));

      recentCalls.add({
        'avatar':
            'https://johnstillk8.scusd.edu/sites/main/files/main-images/camera_lense_0.jpeg',
        'name': 'User $i',
        'type': type,
        'isVideoCall': isVideoCall,
        'icon': icon,
        'color': color,
        'date': dateTime,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fakeRecentCalls();
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

  void _handleVideoCall() {
    // Xử lý sự kiện khi bấm vào icon video call
    print('Bấm vào video call');
  }

  void _handleVoiceCall() {
    // Xử lý sự kiện khi bấm vào icon voice call
    print('Bấm vào voice call');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cuộc gọi'),
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
              child: ListView.builder(
                itemCount: recentCalls.length,
                itemBuilder: (context, index) {
                  final call = recentCalls[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(call['avatar']),
                    ),
                    title: Text(call['name']),
                    subtitle: Row(
                      children: [
                        Icon(
                          call['icon'],
                          color: call['color'],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          call['type'],
                          style: TextStyle(color: call['color']),
                        ),
                        const Text(' • '),
                        Text(
                          '${call['date'].day}/${call['date'].month}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: IconButton(
                        icon: Icon(
                          call['isVideoCall'] ? Icons.videocam : Icons.phone,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          if (call['isVideoCall']) {
                            _handleVideoCall();
                          } else {
                            _handleVoiceCall();
                          }
                        },
                      ),
                    ),
                  );
                },
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
                                    context.push("/chat");
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
                                    _toggleMenu();
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
        ));
  }
}
