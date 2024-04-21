import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/features/parse.dart';
import 'package:customer/screens/FreelancerCategoryScreens/Wax.dart';
import 'package:customer/screens/FreelancerCategoryScreens/Hair.dart';
import 'package:customer/screens/Homescreen/MainScreen.dart';
import 'package:customer/screens/Homescreen/finish_booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:toastification/toastification.dart';
import '../FreelancerCategoryScreens/Lashes.dart';
import '../FreelancerCategoryScreens/Makeup.dart';
import '../FreelancerCategoryScreens/Nails.dart';
import '../FreelancerCategoryScreens/Spa.dart';

class CustHome extends StatefulWidget {
  const CustHome({super.key});

  @override
  State<CustHome> createState() => _CustHomeState();
}

List<String> problems = ['Service provider did not show', 'Personal Emergency'];

class _CustHomeState extends State<CustHome> {
  String currentProblem = problems.first;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController searchController = TextEditingController();
  final db = FirebaseFirestore.instance;
  Parse parse = Parse();

  Widget currentScreen = const HairFreelancers();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAppointments();
  }

  final screenshome = [
    const HairFreelancers(),
    const MakeupFreelancers(),
    const SpaFreelancers(),
    const NailsFreelancers(),
    const LashesFreelancers(),
    const WaxWorkers(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      initialIndex: 0,
      child: Scaffold(
        floatingActionButton: FutureBuilder(
          future: getAppointments(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final appointments = snapshot.data!;
              List<Service> ongoing = [];
              appointments.forEach((doc) {
                if (DateTime.now()
                        //allowance for earlyless
                        .add(const Duration(minutes: 5))
                        .isAfter(doc.dateFrom) &&
                    DateTime.now().isBefore(doc.dateTo) &&
                    doc.status == 'confirmed') {
                  ongoing.add(doc);
                }
              });
              if (ongoing.isNotEmpty && ongoing[0].status == 'approved') {
                return FloatingActionButton.extended(
                  label: const Text('View Ongoing Service'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * .80,
                          padding: const EdgeInsets.fromLTRB(
                              defaultPadding, 10, defaultPadding, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(ongoing[0].clientUsername),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: ongoing[0].services!.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          ongoing[0].services!.length) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Service Fee'),
                                            Text(
                                                'PHP ${ongoing[0].serviceFee}'),
                                          ],
                                        );
                                      } else {
                                        double price = ongoing[0]
                                            .services![index]['price'];
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(ongoing[0].services![index]
                                                ['serviceName']),
                                            Text(
                                                'PHP ${price.toStringAsFixed(2)}')
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total'),
                                      Text('PHP ${ongoing[0].amount}')
                                    ],
                                  )
                                ],
                              ),
                              const Spacer(),
                              InkWell(
                                child: const Text(
                                  'Report Problem',
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      decoration: TextDecoration.underline),
                                ),
                                onTap: () {
                                  //problem method
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('Report Problem'),
                                            content: Column(
                                              children: [
                                                RadioListTile(
                                                  title: Text(problems[0]),
                                                  value: problems[0],
                                                  groupValue: currentProblem,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    currentProblem =
                                                        value.toString();
                                                  }),
                                                ),
                                                RadioListTile(
                                                  title: Text(problems[1]),
                                                  value: problems[1],
                                                  groupValue: currentProblem,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    currentProblem =
                                                        value.toString();
                                                  }),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    await db
                                                        .collection('users')
                                                        .doc(adminUid)
                                                        .collection('reports')
                                                        .add({
                                                      'customerID':
                                                          currentUser!.uid,
                                                      'referenceID':
                                                          ongoing[0].reference,
                                                      'problem': currentProblem,
                                                      'clientID':
                                                          ongoing[0].clientId,
                                                      'paymentMethod':
                                                          ongoing[0]
                                                              .paymentMethod
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('SUBMIT'))
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              Text(
                                'ref: ${ongoing[0].reference}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              SlideAction(
                                onSubmit: () async {
                                  // payService(ongoing[0].clientId,
                                  //     ongoing[0].reference);
                                  // await db
                                  //     .collection('users')
                                  //     .doc(currentUser!.uid)
                                  //     .collection('transaction')
                                  //     .doc(ongoing[0].reference)
                                  //     .update({'description': 'payment'});
                                  // Navigator.of(context).pop();
                                  // setState(() {});
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FinishBooking(
                                            transaction: ongoing[0]),
                                      ));
                                  // toastification.show(
                                  //   type: ToastificationType.success,
                                  //   context: context,
                                  //   title: const Text('Services Paid'),
                                  //   autoCloseDuration:
                                  //       const Duration(seconds: 5),
                                  // );
                                  // return null;
                                },
                                borderRadius: 8,
                                elevation: 0,
                                innerColor: kPrimaryLightColor,
                                outerColor: kPrimaryColor,
                                sliderButtonIconSize: 16,
                                height: 64,
                                text: 'Slide to Pay',
                                textStyle: const TextStyle(
                                    fontSize: 16, color: kPrimaryLightColor),
                              ),
                              const SizedBox(height: defaultPadding),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          },
        ),
        appBar: AppBar(
          // leading:
          //     IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          toolbarHeight: 120,
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
          title: const Text(
            'Current Address',
            style: TextStyle(color: kPrimaryLightColor),
          ),
          // title: StreamBuilder(stream: stream, builder: (build, context)),
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
      ),
    );
  }

  dynamicToMap(List<dynamic> list) {
    List<Map<String, dynamic>> serivcesMapList =
        list[0].services!.map((dynamic item) {
      if (item is Map<String, dynamic>) {
        return item;
      }
      return {};
    }).toList();
  }

  Future<void> payService(String clientId, String reference) async {
    try {
      //update status of customer and client db
      //customer
      await db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('bookings')
          .doc(reference)
          .update({'status': 'paid'});
      // await db.collection('users').doc(currentUser!.uid).collection('transaction')
      //client
      await db
          .collection('users')
          .doc(clientId)
          .collection('bookings')
          .doc(reference)
          .update({'status': 'paid'});
    } catch (e) {
      log('error submitting payment $e');
    }
  }

  Future<Customer?> getCustomerDetails() async {
    try {
      DocumentSnapshot query =
          await db.collection('users').doc(currentUser!.uid).get();
      return Customer(
          fullName:
              '${query['First Name']} ${query['Middle Name']} ${query['Last Name']}',
          contactNum: query['Contact Number'],
          gender: query['Gender'],
          profilePicture: query['Profile Picture'],
          username: query['Username']);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<List<Service>> getAppointments() async {
    try {
      List<Service> appointments = [];
      QuerySnapshot querySnapshot = await db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('bookings')
          .get();
      querySnapshot.docs.forEach((doc) {
        appointments.add(Service(
          clientId: doc['clientId'],
          clientUsername: doc['clientUsername'],
          dateFrom: doc['dateFrom'].toDate(),
          dateTo: doc['dateTo'].toDate(),
          amount: doc['totalAmount'],
          serviceFee: doc['serviceFee'],
          paymentMethod: doc['paymentMethod'],
          reference: doc['reference'],
          status: doc['status'],
          services: doc['services'],
        ));
      });
      return appointments;
    } catch (e) {
      log('error getting serivce $e');
      return [];
    }
  }
}

class Service {
  String clientId;
  String clientUsername;
  DateTime dateFrom;
  DateTime dateTo;
  String serviceFee;
  String paymentMethod;
  String reference;
  String amount;
  String status;
  List<dynamic>? services;

  Service({
    required this.clientId,
    required this.clientUsername,
    required this.dateFrom,
    required this.dateTo,
    required this.amount,
    required this.serviceFee,
    required this.paymentMethod,
    required this.reference,
    required this.status,
    this.services,
  });
}
