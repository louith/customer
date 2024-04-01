// ignore_for_file: unused_import

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore db = FirebaseFirestore.instance;
}

//coding with t code (uploading profile pic)
Future<String> uploadImage(String path, XFile image) async {
  try {
    final ref = FirebaseStorage.instance.ref(path).child(image.name);
    await ref.putFile(File(image.path));
    final url = await ref.getDownloadURL();
    return url;
  } on FirebaseException catch (e) {
    throw FirebaseException(code: e.code, message: e.message, plugin: e.plugin);
  } on PlatformException catch (e) {
    throw PlatformException(code: e.code, message: e.message);
  } catch (e) {
    throw 'Something went wrong. Please try again.';
  }
}











 
// Future addUserDetails() async {
//   await FirebaseFirestore.instance.collection('users').add({});
// }

//user model and backend shi
// Future addUserDetails(
  // String? id,
  // String firstName,
  // String middleName,
  // String lastName,
  // String gender,
  // String age,
  // String phonenum,
  // String prov,
  // String city,
  // String brgy,
  // String extAddress,
  // String email,
  // String userName,
// ) async {
  // await FirebaseFirestore.instance.collection('users').add({
    // "First Name": firstName,
    // "Middle Name": middleName,
    // "Last Name": lastName,
    // "Gender": gender,
    // "Age": age,
    // "Phone Number": phonenum,
    // 'Province': prov,
    // 'City': city,
    // 'Barangay': brgy,
    // 'Extended Address': extAddress,
    // 'Email': email,
    // 'Username': userName,
    // 'role': 'customer'
  // });
// }


