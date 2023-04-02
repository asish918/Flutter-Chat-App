import 'package:chat_app/colors.dart';
import 'package:chat_app/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          const Text(
            "Welcome to Chat App",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 33, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: size.height / 9),
          Image.asset(
            "assets/bg.png",
            color: tabColor,
            height: 340,
            width: 340,
          ),
          SizedBox(height: size.height / 9),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "Read our Privacy Policy. Tap 'Agree and Continue' to accept the Terms of Service.",
              style: TextStyle(color: greyColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: size.width*0.75,
            child: CustomButton(text: "AGREE AND CONTINUE", onPressed: () {}),
          ),
        ],
      )),
    );
  }
}
