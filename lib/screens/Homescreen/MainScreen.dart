import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Chat/generalChat.dart';
import 'package:customer/screens/FreelancerCategoryScreens/allWorkers.dart';
import 'package:customer/screens/Homescreen/Homescreen.dart';
// import 'package:customer/screens/Homescreen/components/ServiceCategories.dart';
import 'package:customer/screens/Homescreen/my_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class CustMainScreen extends StatefulWidget {
  const CustMainScreen({super.key});

  @override
  State<CustMainScreen> createState() => _CustMainScreenState();
}

class _CustMainScreenState extends State<CustMainScreen> {
  int index = 0;
  User? currentUser = FirebaseAuth.instance.currentUser;

  PersistentTabController persistentTabController =
      PersistentTabController(initialIndex: 0);

  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Leaving this page will log you out',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Log Out'),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                } catch (e) {
                  log(e.toString());
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _showBackDialog();
      },
      child: Scaffold(
        bottomNavigationBar: PersistentTabView(
          context,
          controller: persistentTabController,
          stateManagement: true,
          screens: screens(),
          items: navbarItems(),
          confineInSafeArea: true,
          hideNavigationBarWhenKeyboardShows: true,
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10),
            colorBehindNavBar: Colors.white,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation(
              animateTabTransition: true,
              curve: Curves.ease,
              duration: Duration(milliseconds: 100)),
          navBarStyle: NavBarStyle.style9,
        ),
      ),
    );
  }

  List<Widget> screens() {
    return [
      const CustHome(),
      const AllWorkers(),
      GeneralChatPage(
        username: 'username',
      ),
      const MyProfile(),
    ];
  }
}

List<PersistentBottomNavBarItem> navbarItems() {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home),
      title: 'Home',
      activeColorPrimary: kPrimaryColor,
      inactiveColorPrimary: kPrimaryLightColor,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.search),
      title: 'Search',
      activeColorPrimary: kPrimaryColor,
      inactiveColorPrimary: kPrimaryLightColor,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.chat),
      title: 'Chat',
      activeColorPrimary: kPrimaryColor,
      inactiveColorPrimary: kPrimaryLightColor,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.person),
      title: 'Profile',
      activeColorPrimary: kPrimaryColor,
      inactiveColorPrimary: kPrimaryLightColor,
    ),
  ];
}

class Customer {
  String contactNum;
  String fullName;
  String gender;
  String profilePicture;
  String username;

  Customer({
    required this.contactNum,
    required this.fullName,
    required this.gender,
    required this.profilePicture,
    required this.username,
  });
}
