import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/models/service.dart';
import 'package:customer/screens/Booking/bookingScreen.dart';
import 'package:customer/screens/Chat/indivChat.dart';
import 'package:customer/screens/ServicesOffered/servicesList.dart';
import 'package:customer/screens/indivProfile/moreinfo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class WorkerDetailsCard {
  final String id;
  final String name;
  final String role;
  final String address;
  final List<String> categories;
  final String? profileimage;
  final String? worksAt;
  final String? rating;

  WorkerDetailsCard({
    required this.id,
    required this.name,
    required this.role,
    required this.address,
    required this.categories,
    this.rating,
    this.profileimage,
    this.worksAt,
  });
}

class IndivWorkerProfile extends StatelessWidget {
  final String userID;
  final String userName;

  const IndivWorkerProfile({
    super.key,
    required this.userID,
    required this.userName,
  });

  Future<WorkerDetailsCard> getWorkerDetailsCard(String id) async {
    //gets user document first layer
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
        profileimage: userMap['profilePicture'],
        rating: userMap['rating'],
        categories: cats);
  }

  Future<List<String>> getServiceCategories() async {
    try {
      List<String> mainCategories = [];
      final QuerySnapshot querySnapshot =
          await db.collection('users').doc(userID).collection('services').get();
      querySnapshot.docs.forEach((element) {
        mainCategories.add(element.id);
      });
      return mainCategories;
    } catch (e) {
      log('error getting service types $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,##0.00');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
      ),
      body: Stack(children: [
        Container(
          color: kPrimaryColor,
          height: 100,
        ),
        FutureBuilder<WorkerDetailsCard>(
            future: getWorkerDetailsCard(userID),
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

              final clientData = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: defaultPadding),
                    Row(
                      children: [
                        clientData.profileimage!.isEmpty
                            ? const CircleAvatar(
                                radius: 50,
                                child: Text(
                                  'Profile Picture',
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    NetworkImage(clientData.profileimage!),
                              ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                clientData.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              CategoriesRow(itemList: clientData.categories),
                              Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on_outlined),
                                    Text(
                                      clientData.address,
                                    )
                                  ]),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 135,
                                    child: ElevatedButton(
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  kPrimaryLightColor),
                                          foregroundColor:
                                              MaterialStatePropertyAll(
                                                  kPrimaryColor),
                                        ),
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              return IndivChat(
                                                  userName: userName);
                                            },
                                          ));
                                        },
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(
                                              Icons.chat,
                                              size: 16,
                                            ),
                                            Text('Chat Now')
                                          ],
                                        )),
                                  ),
                                  SizedBox(
                                    width: 135,
                                    child: ElevatedButton(
                                        style: const ButtonStyle(
                                            foregroundColor:
                                                MaterialStatePropertyAll(
                                                    kPrimaryLightColor)),
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              return BookingScreen(
                                                userID: userID,
                                                username: userName,
                                                role: clientData.role,
                                                address: clientData.address,
                                              );
                                            },
                                          ));
                                        },
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(
                                              Icons.post_add,
                                              size: 16,
                                            ),
                                            Text('Book Now')
                                          ],
                                        )),
                                  )
                                ],
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MoreInfo(
                                            clientId: snapshot.data!.id,
                                            role: snapshot.data!.role,
                                          ),
                                        ));
                                  },
                                  child: const Text(
                                    'More Info',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                    //
                    RatingBar.builder(
                      allowHalfRating: true,
                      ignoreGestures: true,
                      initialRating: double.parse(clientData.rating!),
                      maxRating: 5,
                      minRating: 0,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) => {},
                    ),
                    const SizedBox(height: defaultPadding),

                    Expanded(
                      child: FutureBuilder<List<String>>(
                          future: getServiceCategories(),
                          builder: (context, serviceType) {
                            if (serviceType.hasData) {
                              return ListView.separated(
                                itemCount: serviceType.data!.length,
                                shrinkWrap: true,
                                itemBuilder: (context, serviceTypeIndex) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        serviceType.data![serviceTypeIndex],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      FutureBuilder(
                                        future: getServices(
                                            serviceType.data![serviceTypeIndex],
                                            clientData.id),
                                        builder: (context, service) {
                                          if (service.hasData) {
                                            return ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: service.data!.length,
                                              itemBuilder:
                                                  (context, serviceIndex) {
                                                var serviceData = service.data!;
                                                return Container(
                                                  width: double.infinity,
                                                  height: 75,
                                                  padding: const EdgeInsets.all(
                                                      defaultPadding),
                                                  decoration: const BoxDecoration(
                                                      color:
                                                          kPrimaryLightColor),
                                                  margin: const EdgeInsets.only(
                                                      bottom: defaultPadding),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                serviceData[
                                                                        serviceIndex]
                                                                    .serviceName,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                  ' - ${serviceData[serviceIndex].duration}')
                                                            ],
                                                          ),
                                                          Text(serviceData[
                                                                  serviceIndex]
                                                              .description),
                                                        ],
                                                      ),
                                                      Text(
                                                          "PHP ${format.format(double.parse(serviceData[serviceIndex].price))}"),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            return const Text('LOADING...');
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                              );
                            } else {
                              return const Text('LOADING...');
                            }
                          }),
                    ),
                  ],
                ),
              );
            }),
      ]),
    );
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
            margin: const EdgeInsets.only(left: 4),
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
