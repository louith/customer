import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// List<String> plaindocIds = [];

// gets those docs that matches the query & conditionals
//returns list of plaindocIDs
Future<List<String>> getPlainDocIds() async {
  List<String> plaindocIds = [];
  await FirebaseFirestore.instance
      .collection('users')
      .where('role', whereIn: ['freelancer', 'salon'])
      // .where('role', isEqualTo: 'freelancer')
      .where("status", isEqualTo: "verified")
      .get()
      .then((snapshot) => snapshot.docs.forEach((element) {
            // print(element.reference);
            // print(element.reference.id);
            plaindocIds.add(element.reference.id.toString());
          }));
  return plaindocIds;
}
