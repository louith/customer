import 'package:customer/components/background.dart';
import 'package:customer/components/form_container_widget.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Homescreen/MainScreen.dart';
import 'package:customer/screens/SignupLogin/Signup.dart';
import 'package:customer/screens/SignupLogin/components/login_topimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:customer/user_auth/firebase_auth_implementation/firebase_auth_services.dart';

//loys' code
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.trim(), password: password.trim());
        print("User successfully LOGGED IN");
        // Navigator.pushNamed(context, "/home");
        Navigator.push(context,
            MaterialPageRoute(builder: ((context) => const CustMainScreen())));
      } catch (e) {
        print(e);
      }
    } else {
      print('LOG IN error!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoginScreenTopImage(),
                  const SizedBox(height: defaultPadding),
                  FormContainerWidget(
                    hintText: 'Email',
                    controller: _emailController,
                    isPasswordField: false,
                    validator: (value) =>
                        value!.isEmpty ? "Please enter your Email" : null,
                  ),
                  const SizedBox(height: defaultPadding),
                  FormContainerWidget(
                    hintText: 'Password',
                    controller: _passwordController,
                    isPasswordField: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Type your password' : null,
                  ),
                  const SizedBox(height: defaultPadding),
                  GestureDetector(
                    onTap: _signIn,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(90),
                      ),
                      child: const Center(
                          child: Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => const CustSignUp())));
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _signIn() async {
  //   String email = _emailController.text;
  //   String password = _passwordController.text;
  //   String error = '';

  //   User? user = await _auth.signInWithEmailAndPassword(email, password);

  //   if (_formKey.currentState!.validate()) {
  //     print("User successfully LOGGED IN");
  //     // Navigator.pushNamed(context, "/home");
  //     Navigator.push(context,
  //         MaterialPageRoute(builder: ((context) => const CustMainScreen())));
  //   } else {
  //     print("Some error happened");
  //   }
  // }
}
