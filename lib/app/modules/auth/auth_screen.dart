import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanzi_writer_app/app/modules/auth/auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to Hanzi Writer',
                style: Get.textTheme.titleLarge,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: controller.signInWithGoogle,
                child: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement Email/Password Sign-In
                },
                child: const Text('Sign in with Email'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to registration screen
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
