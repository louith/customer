import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Booking/bookingScreen.dart';
import 'package:customer/screens/Chat/indivChat.dart';
import 'package:customer/screens/ServicesOffered/servicesList.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

class WorkerDetailsCard {
  final String id;
  final String name;
  final String role;
  final String address;
  final List<String> categories;
  final String? worksAt;

  WorkerDetailsCard({
    required this.id,
    required this.name,
    required this.role,
    required this.address,
    required this.categories,
    this.worksAt,
  });
}

class IndivWorkerProfile extends StatefulWidget {
  final String userID;
  final String userName;

  const IndivWorkerProfile({
    super.key,
    required this.userID,
    required this.userName,
  });

  @override
  State<IndivWorkerProfile> createState() => _IndivWorkerProfileState();
}

class _IndivWorkerProfileState extends State<IndivWorkerProfile> {
  ////////////////////////////////////////////////////////////////
  Future<WorkerDetailsCard> getWorkerDetailsCard(String id) async {
    id = widget.userID;
    final DocumentSnapshot user =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    Map<String, dynamic> userMap = user.data() as Map<String, dynamic>;

    //gets categories offered by worker
    List<String> cats = [];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('categories')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              cats.add(element.id.toString());
            }));

    return WorkerDetailsCard(
        id: id,
        name: userMap['name'],
        role: userMap['role'],
        address: userMap['address'],
        categories: cats);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ServicesList(
        userID: widget.userID,
      ),
      IndivChat(
        userName: widget.userName,
      ),
      BookingScreen(
        clientId: widget.userID,
        clientUsername: widget.userName,
      ),
    ];

    return Scaffold(
        appBar: AppBar(
            backgroundColor: kPrimaryColor,
            elevation: 0,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios))),
        body: Stack(children: [
          Container(
            color: kPrimaryColor,
            height: 100,
          ),
          FutureBuilder<WorkerDetailsCard>(
              future: getWorkerDetailsCard(widget.userID),
              builder: (context, AsyncSnapshot<WorkerDetailsCard> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('No data available');
                }

                final plainWorkerdata = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: defaultPadding,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/suzy.jpg',
                            width: 100,
                            height: 100,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  plainWorkerdata.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                CategoriesRow(
                                    itemList: plainWorkerdata.categories),
                                Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined),
                                      Text(plainWorkerdata.address)
                                    ]),
                                const Wrap(children: [
                                  Icon(Icons.work_outline),
                                  Text('Works at')
                                ]),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('More Information'))
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Text('Feedbacks section below')
                    ],
                  ),
                );
              }),
        ]),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
              height: 80,
              indicatorColor: kPrimaryColor,
              labelTextStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          child: NavigationBar(
              onDestinationSelected: (index) {
                Navigator.push(context,
                    MaterialPageRoute(builder: ((context) => screens[index])));
              },
              destinations: const [
                NavigationDestination(
                    icon: LineIcon.servicestack(),
                    label: 'Services',
                    selectedIcon:
                        LineIcon.servicestack(color: kLoysPrimaryIconColor)),
                NavigationDestination(
                    icon: Icon(Icons.chat_outlined),
                    label: 'Chat Now',
                    selectedIcon:
                        Icon(Icons.chat, color: kLoysPrimaryIconColor)),
                NavigationDestination(
                    icon: LineIcon.calendarPlus(),
                    label: 'Book Now',
                    selectedIcon:
                        LineIcon.calendarPlusAlt(color: kLoysPrimaryIconColor)),
              ]),
        ));
  }
}

class CategoriesRow extends StatelessWidget {
  const CategoriesRow({super.key, required this.itemList});

  final List<dynamic> itemList;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          itemList.length,
          (index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(100)),
            child: Text(itemList[index]),
          ),
        ),
      ),
    );
  }
}
