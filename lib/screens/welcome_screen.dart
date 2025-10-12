import 'package:auric/common/heading_text.dart';
import 'package:auric/screens/login_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text("Welcome")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              HeadingText(text: "Auric"),
              Text(
                "Track, understand, and secure your finances all in one elegant space. Every transaction you record is end-to-end encrypted, ensuring only you can see your data. Private. Minimal. Effortless.",
              ),
              ShadButton(
                onPressed: () {
                  Get.to(() => const LoginRegisterScreen());
                },
                child: Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
