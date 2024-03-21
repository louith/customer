import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/FreelancerCategoryScreens/components/getVerified.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

// class ServiceCard {
// final String id;
// final String service;
// final String category;
// final double price;
// final String? desc;
// final String? duration;
// bool isBooked;
//
// ServiceCard({
// required this.id,
// required this.service,
// required this.category,
// required this.price,
// this.desc,
// this.duration,
// });
// }
class Service {
  final String name;
  final List<SubService> subservices;

  Service({required this.name, required this.subservices});
}

class SubService {
  final String name;
  final double? price;
  final String? desc;
  final String? duration;

  SubService({
    required this.name,
    this.price,
    this.desc,
    this.duration,
  });
}

class ServicesList extends StatefulWidget {
  final String userID;
  const ServicesList({super.key, required this.userID});

  @override
  State<ServicesList> createState() => _ServicesListState();
}

class _ServicesListState extends State<ServicesList> {
  Future<Service> getService(String serviceName) async {
    final QuerySnapshot catDocSnap = await db
        .collection('users')
        .doc(widget.userID)
        .collection('services')
        .doc(serviceName)
        .collection('${widget.userID}services')
        .get();

    List<SubService> subServices = [];
    for (final doc in catDocSnap.docs) {
      subServices.add(SubService(
          name: doc.id,
          price: doc.get('price'),
          desc: doc.get('description'),
          duration: doc.get('duration')));
    }
    return Service(name: serviceName, subservices: subServices);
  }

  Future<List<Service>> getServices() async {
    final QuerySnapshot servicesQuery = await db
        .collection('users')
        .doc(widget.userID)
        .collection('services')
        .get();

    List<Future<Service>> futures = [];
    for (final doc in servicesQuery.docs) {
      futures.add(getService(doc.id));
    }
    // Wait until all the futures are done
    return await Future.wait(futures);
  }

  // Future<ServiceCard?> getServiceCard(String plainID) async {
  // plainID = widget.userID;
  // List<String> servIDs = [];
  // await db
  // .collection('users')
  // .doc(plainID)
  // .collection('services')
  // .get()
  // .then((snapshot) => snapshot.docs.forEach((element) {
  // servIDs.add(element.id.toString());
  // }));

  // for (var servID in servIDs) {
  // List<String> subServIDList = [];
  // await db
  // .collection('users')
  // .doc(plainID)
  // .collection('services')
  // .doc(servID)
  // .collection('${plainID}services')
  // .get()
  // .then((snapshot) => snapshot.docs.forEach((element) {
  // subServIDList.add(element.id.toString());
  // }));
  // for (var subservID in subServIDList) {
  // final DocumentSnapshot subservDOC = await db
  // .collection('users')
  // .doc(plainID)
  // .collection('services')
  // .doc(servID)
  // .collection('${plainID}services')
  // .doc(subservID)
  // .get();
  // return ServiceCard(
  // id: subservID,
  // service: subservID,
  // category: servID,
  // price: subservDOC['price'],
  // desc: subservDOC['description'],
  // duration: subservDOC['duration']);
  // }
  // }
  // } //getServiceCard() func ends

  // Future<List<ServiceCard>> getServices() async {
  // List<Future<ServiceCard?>> futures = [];
  // for (var plainID in (await getPlainDocIds())) {
  // futures.add(getServiceCard(plainID));
  // }
  // List<ServiceCard?> servicesWithNull = await Future.wait<ServiceCard>(
  // futures as Iterable<Future<ServiceCard>>);

  // return servicesWithNull.whereType<ServiceCard>().toList();
  // }

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
        title: Text('Services Offered'),
      ),
      body: StreamBuilder(
          stream: Stream.fromFuture(getServices()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              );
            } else {
              List<Service> serve = snapshot.data!;

              return ListView.builder(itemBuilder: ((context, index) {
                return Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      //boxshadow code/styling
                    ),
                    child: Column(
                      children: [
                        Text(serve[index].name),
                        ListTile(),
                      ],
                    ));
              }));
            }
          }),
      // body: Column(children: [Text(data)]),
    );
  }
}
