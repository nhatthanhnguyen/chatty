import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool _isMenuOpen = false;
  final List<SearchResult> searchResults = [
    SearchResult(
      name: 'Nhơn trần',
      imageUrl:
          'https://scontent.fsgn5-11.fna.fbcdn.net/v/t39.30808-6/305189399_3238978553019350_4101751137687577235_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=gVEGNgUqORQAX80kbMi&_nc_ht=scontent.fsgn5-11.fna&oh=00_AfAyWkJRULvqSMA0bcNiaUlqLvsoLMxZi1wgqw_pWcffyA&oe=649D870F',
    ),
    SearchResult(
      name: 'Linh Diệu',
      imageUrl:
          'https://th.bing.com/th/id/OIP.Jii5phSpvOOP6nxfaDLJIQHaEK?pid=ImgDet&w=474&h=266&rs=1',
    ),
    SearchResult(
      name: 'Tuyền Trần (chưa có bồ và rất là xinh đẹp tuyệt vời ông mặt trời)',
      imageUrl:
          'https://scontent.fsgn5-9.fna.fbcdn.net/v/t39.30808-6/347654967_260992839630422_8040730751667589792_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=jZKbKinPgMQAX9BgBXW&_nc_ht=scontent.fsgn5-9.fna&oh=00_AfAJMm8ZiBW_9mlSSQcLMfCeXJFl0iqMniaeFhxd9qF8kA&oe=649DCA09',
    ),
    // Add more search results here
  ];

  List<bool> addedFriendList =
      List.filled(3, false); // Initial state: not added as friend

  String searchText = ''; // Biến lưu trữ văn bản tìm kiếm
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
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
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      final isAdded = addedFriendList[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(result.imageUrl),
                        ),
                        title: Text(result.name),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                addedFriendList[index] =
                                    !addedFriendList[index];
                              });
                            },
                            child: Text(
                              isAdded ? 'Đã gửi lời mời' : 'Thêm bạn',
                              style: TextStyle(
                                color: isAdded ? Colors.black54 : Colors.black,
                              ),
                            ),
                          ),
                        ),
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
                                  context.push("/contact");
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
                                  _toggleMenu();
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

class SearchResult {
  final String name;
  final String imageUrl;

  SearchResult({required this.name, required this.imageUrl});
}
