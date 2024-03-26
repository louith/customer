import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/ServicesOffered/IndivService.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class Service {
  final String name;
  final List<SubService> subservices;

  Service({required this.name, required this.subservices});
}

class SubService {
  final String subService;
  final String price;
  final String description;
  final String duration;

  SubService({
    required this.subService,
    required this.price,
    required this.description,
    required this.duration,
  });
}

class SpecificServices extends StatefulWidget {
  final String userID;
  final String serviceCategory;
  const SpecificServices(
      {super.key, required this.userID, required this.serviceCategory});

  @override
  State<SpecificServices> createState() => _SpecificServicesState();
}

class _SpecificServicesState extends State<SpecificServices> {
  Future<Service> getService(String id) async {
    final QuerySnapshot catDocSnap = await db
        .collection('users')
        .doc(widget.userID)
        .collection('services')
        .doc(widget.serviceCategory)
        .collection('${widget.userID}services')
        .get();

    List<SubService> subServices = [];

    for (final doc in catDocSnap.docs) {
      subServices.add(SubService(
          subService: doc.id,
          price: doc.get('price'),
          description: doc.get('description'),
          duration: doc.get('duration')));
    }

    return Service(name: widget.serviceCategory, subservices: subServices);
  }

  Future<List<Service>> getServiceType() async {
    final QuerySnapshot servicesQuery = await db
        .collection('users')
        .doc(widget.userID)
        .collection('services')
        .get();

    List<Future<Service>> futures = [];
    for (final doc in servicesQuery.docs) {
      futures.add(getService(doc.id));
    }

    return await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceCategory)),
      body: StreamBuilder(
          stream: Stream.fromFuture(getServiceType()),
          builder: (context, servicetype) {
            if (!servicetype.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: kPrimaryColor));
            } else {
              List<Service> type = servicetype.data!;
              log(type[0].subservices.length.toString());
              // return Container();
              return ListView.builder(
                  itemCount: type.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IndivServicePage(
                                    subserviceID: type[index]
                                        .subservices[index]
                                        .subService)));
                      },
                      title: Column(children: [
                        Text(
                          type[index].subservices[index].subService,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(type[index].subservices[index].duration),
                        Text('Php ${type[index].subservices[index].price}'),
                      ]),
                    );
                  });
            }
          }),
    );
  }
}
