import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
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
  // Future<SubService?> getSubService(String id) async {
  // String subserviceID = '';
  // String desc = '';
  // String presyo = '';
  // String duracio = '';

  // final subServiceCol = await db
  // .collection('users')
  // .doc(widget.userID)
  // .collection('services')
  // .doc(widget.serviceCategory)
  // .collection('${widget.userID}services')
  // .get();
  // .then((snapshot) => snapshot.docs.forEach((element) {
  // subserviceID = element.id.toString();
  // desc = element.get('description');
  // presyo = element.get('price');
  // duracio = element.get('duration');
  // }));

  // return SubService(
  // subService: subserviceID,
  // price: presyo,
  // description: desc,
  // duration: duracio);
  // }

  // Future<List<SubService>> getAll() async {
  // List<Future<SubService?>> futures = [];
  // final QuerySnapshot subServCollection = await db
  // .collection('users')
  // .doc(widget.userID)
  // .collection('services')
  // .doc(widget.serviceCategory)
  // .collection('${widget.userID}services')
  // .get();

  // for (final doc in subServCollection.docs) {
  // futures.add(getSubService(doc.id));
  // }

  // List<SubService?> resultsWithNull = await Future.wait<SubService?>(futures);

  // return resultsWithNull.whereType<SubService>().toList();
  // }

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

    return await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceCategory)),
      body: StreamBuilder(
          stream: Stream.fromFuture(getServices()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(color: kPrimaryColor));
            } else {
              List<Service> serve = snapshot.data!;

              return ListView.builder(
                  itemCount: serve.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      shadowColor: Colors.black12,
                      child: Column(children: [
                        Text(
                          serve[index].subservices[index].subService,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(serve[index].subservices[index].duration),
                        Text('Php ${serve[index].subservices[index].price}'),
                      ]),
                    );
                  });
            }
          }),
    );
  }
}