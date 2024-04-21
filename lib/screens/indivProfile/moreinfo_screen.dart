import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/customerProfile/custprofile.dart';
import 'package:flutter/material.dart';

class MoreInfo extends StatelessWidget {
  String clientId;
  String role;
  MoreInfo({
    super.key,
    required this.clientId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Background(
        child: Container(
      padding: const EdgeInsets.fromLTRB(15, 50, 15, 0),
      child: Column(
        children: [
          const Text('More Information'),
          const SizedBox(height: defaultPadding),
          role == 'salon'
              ? FutureBuilder<DocumentSnapshot?>(
                  future: salonDetailsLink(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          const Text('Salon Photo - Outside'),
                          SizedBox(
                            height: 250,
                            child:
                                Image.network(snapshot.data!['outsideSalon']),
                          ),
                          const SizedBox(height: defaultPadding),
                          const Text('Salon Photo - Outside'),
                          SizedBox(
                            height: 250,
                            child: Image.network(snapshot.data!['insideSalon']),
                          ),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                )
              : FutureBuilder(
                  future: certificateLinks(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: Column(
                          children: [
                            const Text('Certificates'),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                    height: 250,
                                    child:
                                        Image.network(snapshot.data![index]));
                              },
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
        ],
      ),
    ));
  }

  Future<List<String>> certificateLinks() async {
    try {
      List<String> certs = [];
      DocumentSnapshot documentSnapshot = await db
          .collection('users')
          .doc(clientId)
          .collection('portfolio')
          .doc('requirements')
          .get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      List<String> links = data.keys
          .where((element) => element.startsWith('certificate'))
          .toList();
      links.forEach((element) {
        certs.add(data[element]);
      });
      return certs;
    } catch (e) {
      log('error getting certificate links $e');
      return [];
    }
  }

  Future<DocumentSnapshot?> salonDetailsLink() async {
    try {
      DocumentSnapshot documentSnapshot = await db
          .collection('users')
          .doc(clientId)
          .collection('portfolio')
          .doc('requirements')
          .get();
      return documentSnapshot;
    } catch (e) {
      log('error getting salon details link $e');
      return null;
    }
  }
}
