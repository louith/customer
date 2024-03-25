import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/FreelancerCategoryScreens/components/getVerified.dart';
import 'package:customer/screens/ServicesOffered/specificServices.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class ServicesList extends StatefulWidget {
  final String userID;
  const ServicesList({super.key, required this.userID});

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {
  Future getServiceCategories() async {
    List<String> mainCategories = [];
    final categories = await db
        .collection('users')
        .doc(widget.userID)
        .collection('services')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              mainCategories.add(element.id.toString());
            }));
    return mainCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios)),
          title: Text(
            'Services Offered',
            style: TextStyle(color: kPrimaryLightColor),
          ),
        ),
        body: StreamBuilder(
            stream: Stream.fromFuture(getServiceCategories()),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Text('No data found'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ));
              }

              var serviceCategories = snapshot.data!;
              return Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ListView.builder(
                    itemCount: serviceCategories.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 150,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ]
                            //boxshadow code/styling
                            ),
                        child: ListTile(
                          hoverColor: kPrimaryLightColor,
                          shape: RoundedRectangleBorder(),
                          title: Column(
                            children: [
                              if (serviceCategories[index] == 'Hair' ||
                                  serviceCategories[index] == 'hair')
                                Image.asset(
                                  'assets/ServiceCategories/hair.jpg',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              if (serviceCategories[index] == 'Makeup' ||
                                  serviceCategories[index] == 'makeup')
                                Image.asset(
                                  'assets/ServiceCategories/makeup.jpg',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              if (serviceCategories[index] == 'Spa' ||
                                  serviceCategories[index] == 'spa')
                                Image.asset(
                                  'assets/ServiceCategories/spa.jpg',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              if (serviceCategories[index] == 'Nails' ||
                                  serviceCategories[index] == 'nails')
                                Image.asset(
                                  'assets/ServiceCategories/nails.jpg',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              if (serviceCategories[index] == 'Lashes' ||
                                  serviceCategories[index] == 'lashes')
                                Image.asset(
                                    'assets/ServiceCategories/lashes.jpg',
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover),
                              if (serviceCategories[index] == 'Wax' ||
                                  serviceCategories[index] == 'wax')
                                Image.asset(
                                  'assets/ServiceCategories/wax.jpg',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              Text(serviceCategories[index])
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SpecificServices(
                                        userID: widget.userID,
                                        serviceCategory:
                                            serviceCategories[index])));
                          },
                        ),
                      );
                    }),
              );
            })
        // body: StreamBuilder(
        // stream: Stream.fromFuture(getServices()),
        // builder: (context, snapshot) {
        // if (!snapshot.hasData) {
        // return Center(child: Text('walay unod yawa'));
        // } else {
        // List<Service> serve = snapshot.data!;

        // return ListView.builder(itemBuilder: ((context, index) {
        // return Container(
        // margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
        // decoration: const BoxDecoration(
        // color: Colors.white,
        // boxshadow code/styling
        // ),
        // child: Column(
        // children: [
        // Text(serve[index].name),
        // ListTile(),
        // ],
        // ));
        // }));
        // }
        // }),

        );
  }
}
