import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/already_have_an_account_check.dart';
import 'package:customer/components/assets_strings.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/SignupLogin/Login.dart';
import 'package:customer/screens/SignupLogin/components/signup_topimg.dart';
import 'package:customer/screens/customerProfile/custprofile.dart';
import 'package:customer/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

//Loys' code
import 'package:customer/components/form_container_widget.dart';

//loys' code
class CustSignUp extends StatefulWidget {
  const CustSignUp({super.key});

  @override
  State<CustSignUp> createState() => _CustSignUpState();
}

class _CustSignUpState extends State<CustSignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    SignUpScreenTopImage(),
                    SizedBox(height: 30),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            FormContainerWidget(
                              controller: _usernameController,
                              hintText: "Username",
                              isPasswordField: false,
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter a username' : null,
                            ),
                            SizedBox(height: 10),
                            FormContainerWidget(
                                controller: _emailController,
                                hintText: "Email",
                                icon: Icons.email_outlined,
                                isPasswordField: false,
                                validator: (val) {
                                  if (val!.isEmpty ||
                                      !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(val)) {
                                    return 'Enter a valid email!';
                                  }
                                  return null;
                                }),
                            SizedBox(height: 10),
                            FormContainerWidget(
                              controller: _passwordController,
                              hintText: "Password",
                              isPasswordField: true,
                              icon: Icons.password,
                              validator: (val) => val!.length < 6
                                  ? 'Create a password with at least 6 characters'
                                  : null,
                            ),
                          ],
                        )),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _signUp,
                      // () {
                      //   Navigator.push(context,
                      //       MaterialPageRoute(builder: ((context) => CustHome())));
                      // },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(90),
                        ),
                        child: Center(
                            child: Text(
                          "SIGN UP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('OR'),
                    SizedBox(height: 5),
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: kPrimaryColor)),
                            onPressed: () {},
                            icon: Image(
                              image: AssetImage(GoogleLogoImg),
                              width: 20.0,
                            ),
                            label: Text('Sign-in with Google'))),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => LoginScreen())));
                          },
                          child: Text(
                            "Log in",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String error = "";

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (_formKey.currentState!.validate()) {
      print("User successfully created");
      toastification.show(
          type: ToastificationType.info,
          context: context,
          icon: Icon(Icons.edit_document),
          title: Text('Complete personal info'),
          autoCloseDuration: const Duration(seconds: 3),
          showProgressBar: false,
          alignment: Alignment.topCenter,
          style: ToastificationStyle.fillColored);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => AfterSignup(
                    email: email,
                    username: username,
                    password: password,
                  ))));
    } else {
      print("Some error happened");
    }
  }

  postEmailToFireStore() {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    try {
      var user = FirebaseAuth.instance.currentUser;
      CollectionReference ref = FirebaseFirestore.instance.collection('users');
      ref
          .doc(user!.uid)
          .set({'email': email, 'username': username, 'password': password});
    } catch (e) {
      log(e.toString());
    }
  }
}
