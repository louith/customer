import 'dart:developer';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/FreelancerCategoryScreens/Wax.dart';
import 'package:customer/screens/FreelancerCategoryScreens/Hair.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../FreelancerCategoryScreens/Lashes.dart';
import '../FreelancerCategoryScreens/Makeup.dart';
import '../FreelancerCategoryScreens/Nails.dart';
import '../FreelancerCategoryScreens/Spa.dart';

class CustHome extends StatefulWidget {
  const CustHome({super.key});

  @override
  State<CustHome> createState() => _CustHomeState();
}

class _CustHomeState extends State<CustHome> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController searchController = TextEditingController();

  Widget currentScreen = const HairFreelancers();

  final screenshome = [
    const HairFreelancers(),
    const MakeupFreelancers(),
    const SpaFreelancers(),
    const NailsFreelancers(),
    const LashesFreelancers(),
    const WaxWorkers(),
  ];

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
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
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
      child: DefaultTabController(
          length: 6,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    log('putangina filter nih');
                    log(currentUser!.uid);
                  }),
              toolbarHeight: 90,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                    unselectedLabelColor: kPrimaryLightColor,
                    indicatorColor: kPrimaryLightColor,
                    indicatorWeight: 5,
                    labelColor: kPrimaryLightColor,
                    tabs: [
                      Tab(
                        text: 'Hair',
                        icon: SvgPicture.asset(
                          'assets/svg/hair.svg',
                          width: 24,
                          height: 24,
                          color: kPrimaryLightColor,
                        ),
                      ),
                      Tab(
                        text: 'Makeup',
                        icon: SvgPicture.asset(
                          'assets/svg/makeup.svg',
                          width: 24,
                          height: 24,
                          color: kPrimaryLightColor,
                        ),
                      ),
                      Tab(
                        text: 'Spa',
                        icon: SvgPicture.asset(
                          'assets/svg/spa.svg',
                          width: 24,
                          height: 24,
                          color: kPrimaryLightColor,
                        ),
                      ),
                      Tab(
                        text: 'Nails',
                        icon: SvgPicture.asset(
                          'assets/svg/nails.svg',
                          width: 24,
                          height: 24,
                          color: kPrimaryLightColor,
                        ),
                      ),
                      Tab(
                        text: 'Lashes',
                        icon: SvgPicture.asset(
                          'assets/svg/hair.svg',
                          width: 24,
                          height: 24,
                          color: kPrimaryLightColor,
                        ),
                      ),
                      Tab(
                        text: 'Wax',
                        icon: SvgPicture.asset(
                          'assets/svg/face & skin.svg',
                          width: 24,
                          height: 24,
                          color: kPrimaryLightColor,
                        ),
                      ),
                    ]),
              ),
              title: Text('Current Address'),
              backgroundColor: kPrimaryColor,
            ),
            body: TabBarView(children: [
              screenshome[0],
              screenshome[1],
              screenshome[2],
              screenshome[3],
              screenshome[4],
              screenshome[5],
            ]),
          )),
    );
  }
}
