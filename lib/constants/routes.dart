import 'package:chatty/screens/sign_in.dart';
import 'package:chatty/screens/sign_up.dart';
import 'package:chatty/screens/profile.dart';
import 'package:chatty/screens/search.dart';
import 'package:chatty/screens/menu.dart';
import 'package:chatty/screens/chat.dart';
import 'package:chatty/screens/call.dart';

import 'package:chatty/screens/contact.dart';

import 'package:chatty/screens/start.dart';
import 'package:go_router/go_router.dart';

final UserProfile user = UserProfile(
    name: "Nhơn Trần",
    email: "nhontran801@gmail.com",
    phoneNumber: "0354531587",
    avatarUrl:
        "https://th.bing.com/th/id/R.6af6fd9c37f0de4abb34ea0fd20acce3?rik=55mqMmrTutVR0Q&pid=ImgRaw&r=0");
final routes = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const StartScreen(),
    ),
    GoRoute(
      path: "/signIn",
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: "/signUp",
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: "/profile",
      builder: (context, state) => ProfileScreen(userProfile: user),
    ),
    GoRoute(
      path: "/search",
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: "/menu",
      builder: (context, state) => const SideMenuScreen(),
    ),
    GoRoute(
      path: "/contact",
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: "/chat",
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: "/call",
      builder: (context, state) => const CallScreen(),
    )
  ],
);
