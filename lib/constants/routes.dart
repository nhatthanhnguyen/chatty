import 'package:chatty/screens/sign_in.dart';
import 'package:chatty/screens/sign_up.dart';
import 'package:chatty/screens/start.dart';
import 'package:go_router/go_router.dart';

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
  ],
);
