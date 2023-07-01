import 'package:chatty/screens/calling_user.dart';
import 'package:chatty/screens/chat_group.dart';
import 'package:chatty/screens/chat_user.dart';
import 'package:chatty/screens/incomming_call_user.dart';
import 'package:chatty/screens/sign_in.dart';
import 'package:chatty/screens/sign_up.dart';
import 'package:chatty/screens/start.dart';
import 'package:go_router/go_router.dart';

const userId = '962e2e9c-13fe-11ee-94f7-2af8bc66f883';
const groupId = '0564e89c-141c-11ee-9abd-2af8bc66f883';
const chatUser = '/chat/user/$userId';
const chatGroup = '/chat/group/$groupId';

final routes = GoRouter(
  initialLocation: chatGroup,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const StartScreen(),
    ),
    GoRoute(
      path: '/signIn',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/signUp',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/calling/user/:userId',
      builder: (context, state) => CallingUser(
        userId: state.pathParameters['userId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/incomming/user/:userId',
      builder: (context, state) => IncommingCallUser(
        userId: state.pathParameters['userId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/chat/user/:userId',
      builder: (context, state) => ChatPrivateScreen(
        userId: state.pathParameters['userId'] ?? '1',
      ),
    ),
    GoRoute(
      path: '/chat/group/:groupId',
      builder: (context, state) => ChatGroupScreen(
        groupId: state.pathParameters['groupId'] ?? '1',
      ),
    ),
  ],
);
