import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class ClientService {
  String serviceName;
  String price;
  String duration;
  String description;

  ClientService({
    required this.serviceName,
    required this.price,
    required this.duration,
    required this.description,
  });
}

Future<List<ClientService>> getServices(
    String serviceType, String clientID) async {
  List<ClientService> services = [];
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(clientID)
        .collection('services')
        .doc(serviceType)
        .collection('${clientID}services')
        .get();
    for (var service in querySnapshot.docs) {
      if (service.exists) {
        services.add(ClientService(
            serviceName: service.id,
            price: service['price'],
            duration: service['duration'],
            description: service['description']));
      }
    }
    // log('$serviceType has ${services.length.toString()} services');
    return services;
  } catch (e) {
    log('error getting service tpyes $e');
    return [];
  }
}
