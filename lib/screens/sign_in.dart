import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign In",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
