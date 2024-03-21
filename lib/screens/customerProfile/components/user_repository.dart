// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Future addUserDetails() async {
//   await FirebaseFirestore.instance.collection('users').add({});
// }

//user model and backend shi
Future addUserDetails(
  String? id,
  String firstName,
  String middleName,
  String lastName,
  String gender,
  String age,
  String phonenum,
  String prov,
  String city,
  String brgy,
  String extAddress,
  String email,
  String userName,
) async {
  await FirebaseFirestore.instance.collection('users').add({
    "First Name": firstName,
    "Middle Name": middleName,
    "Last Name": lastName,
    "Gender": gender,
    "Age": age,
    "Phone Number": phonenum,
    'Province': prov,
    'City': city,
    'Barangay': brgy,
    'Extended Address': extAddress,
    'Email': email,
    'Username': userName,
    'role': 'customer'
  });
}
