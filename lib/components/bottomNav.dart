import 'package:customer/components/constants.dart';
import 'package:customer/screens/Homescreen/Homescreen.dart';
import 'package:customer/screens/Homescreen/my_profile.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  // final int currentIndex;
  // final ValueChanged<int> onTap;

  const BottomNavBar(
      {
      // {required this.currentIndex, required this.onTap,
      super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 0;
  final screens = [const CustHome(), const Center(child: Text('CHAT YWERDS')), const MyProfile()];
  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
          height: 80,
          indicatorColor: kPrimaryColor,
          labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
          //u can add text style shits din
          //u can add bg color din
          ),
      child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          backgroundColor: kPrimaryLightColor,
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
              ),
              label: 'Home',
              selectedIcon: Icon(
                Icons.home,
                color: kLoysPrimaryIconColor,
              ),
            ),
            NavigationDestination(
                icon: Icon(Icons.chat_outlined),
                label: 'Chat',
                selectedIcon: Icon(
                  Icons.chat,
                  color: kLoysPrimaryIconColor,
                )),
            NavigationDestination(
                icon: Icon(
                  Icons.person_2_outlined,
                ),
                label: 'My Profile',
                selectedIcon: Icon(
                  Icons.person_2,
                  color: kLoysPrimaryIconColor,
                )),
          ]),
    );
  }
}
