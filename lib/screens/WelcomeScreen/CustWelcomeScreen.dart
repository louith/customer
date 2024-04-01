import 'package:customer/components/background.dart';
import 'package:customer/screens/WelcomeScreen/components/loginsignupbtn.dart';
import 'package:customer/screens/WelcomeScreen/components/welcomeimg.dart';
import 'package:flutter/material.dart';

class CustWelcome extends StatelessWidget {
  const CustWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Background(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WelcomeImage(),
          Row(
            children: [
              Spacer(),
              Expanded(flex: 8, child: LoginAndSignupBtn()),
              Spacer()
            ],
          )
        ],
      ),
    ));
  }
}
