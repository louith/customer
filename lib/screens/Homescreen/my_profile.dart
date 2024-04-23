import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/screens/Homescreen/Homescreen.dart';
import 'package:customer/screens/Homescreen/booking_transcations.dart';
import 'package:customer/screens/Homescreen/wallet_details.dart';
import 'package:customer/screens/WelcomeScreen/CustWelcomeScreen.dart';
import 'package:customer/screens/customerProfile/editProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class Profile {
  String username;
  String email;
  String profilePicture;
  String uid;
  dynamic wallet;

  Profile({
    required this.username,
    required this.email,
    required this.profilePicture,
    required this.uid,
    required this.wallet,
  });
}

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  Future<Profile?> getUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      return Profile(
        uid: userDoc.id,
        username: userDoc['Username'],
        email: userDoc['Email'],
        profilePicture: userDoc['Profile Picture'],
        wallet: userDoc['Wallet'],
      );
    } catch (e) {
      log("error getting profile data $e");
      return null;
    }
  }

  Future<void> signUserOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const CustWelcome()));
    } catch (e) {
      log('error signing out $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: const EdgeInsets.only(top: 45),
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: kPrimaryColor,
            title: const Text(
              'My Profile',
              style: TextStyle(color: kPrimaryLightColor),
            ),
          ),
          body: SingleChildScrollView(
              child: Container(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                FutureBuilder(
                  future: getUserProfile(),
                  builder: (context, profile) {
                    if (profile.hasData) {
                      var profileData = profile.data!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          profileData.profilePicture.isNotEmpty
                              ? CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      NetworkImage(profileData.profilePicture))
                              : const CircleAvatar(
                                  radius: 60,
                                  child: Text('Profile Picture'),
                                ),
                          const SizedBox(height: defaultPadding),
                          Text(
                            profileData.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(profileData.email),
                        ],
                      );
                    } else {
                      // return Text('data');
                      return const CircularProgressIndicator(
                          color: kPrimaryColor);
                    }
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: 200,
                    height: 45,
                    child: elevButton(
                        title: 'Edit Profile',
                        onClicked: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => EditProfile())));
                          //separate page na dapat na naga fetch ug data from db
                        })),
                const SizedBox(height: defaultPadding),
                const Divider(),
                const SizedBox(height: defaultPadding),
                //Menu
                ProfileMenuWidget(
                  title: 'My Addresses',
                  icon: LineIcons.locationArrow,
                  onPress: () {},
                ),
                // ProfileMenuWidget(
                // title: 'Settings',
                // icon: LineIcons.cog,
                // onPress: () {},
                // ),
                ProfileMenuWidget(
                  title: 'Billing Details',
                  icon: LineIcons.wallet,
                  onPress: () {},
                ),
                ProfileMenuWidget(
                  title: 'Booking Transactions',
                  icon: LineIcons.calendar,
                  onPress: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return BookingTransactions(
                          uid: currentUser!.uid,
                        );
                      },
                    ));
                  },
                ),
                const Divider(),
                const SizedBox(height: defaultPadding),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: ProfileMenuWidget(
                    title: 'Logout',
                    icon: LineIcons.alternateSignOut,
                    endIcon: false,
                    onPress: signUserOut,
                  ),
                ),
              ],
            ),
          ))),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: kPrimaryColor.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: kPrimaryColor,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.apply(color: textColor),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: kPrimaryColor.withOpacity(0.1)),
              child: const Icon(LineIcons.angleRight,
                  size: 18, color: kPrimaryColor),
            )
          : null,
    );
  }
}
