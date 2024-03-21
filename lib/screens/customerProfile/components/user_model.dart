import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String? id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String gender;
  final String phonenum;
  final String prov;
  final String city;
  final String brgy;
  final String extAddress;
  final String email;
  final String userName;

  const UserModel(
      {this.id,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.gender,
      required this.phonenum,
      required this.prov,
      required this.city,
      required this.brgy,
      required this.extAddress,
      required this.email,
      required this.userName});

  toJson() {
    return {
      "First Name": firstName,
      "Middle Name": middleName,
      "Last Name": lastName,
      "Gender": gender,
      "Phone Number": phonenum,
      'Province': prov,
      'City': city,
      'Barangay': brgy,
      'Extended Address': extAddress,
      'Email': email,
      'Username': userName,
      'role': 'customer'
    };
  }
}

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

Future<void> showAlertDialog(
    BuildContext context, String title, String message) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
