import 'dart:developer';

import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/screens/Booking/editEvent.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:badges/badges.dart' as badges;

class AddAddress extends StatefulWidget {
  const AddAddress({super.key});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: const EdgeInsets.only(top: 45),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: kPrimaryLightColor,
          backgroundColor: kPrimaryColor,
          title: const Text(
            'Addresses',
            style: TextStyle(color: kPrimaryLightColor),
          ),
        ),
        body: Background(
            child: Container(
          margin: const EdgeInsets.fromLTRB(15, 30, 15, 0),
          child: FutureBuilder(
            future: getMyAddresses(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length + 1,
                      itemBuilder: (context, index) {
                        if (index == snapshot.data!.length) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddMyAddress(),
                              ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(defaultPadding),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: kPrimaryLightColor,
                              ),
                              height: 80,
                              width: double.infinity,
                              child: const Center(
                                child: Text(
                                  'Add Address +',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return badges.Badge(
                            position:
                                badges.BadgePosition.topEnd(top: -8, end: -8),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Delete Address ${index + 1}?',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Back")),
                                    TextButton(
                                        onPressed: () async {
                                          await db
                                              .collection('users')
                                              .doc(currentUser!.uid)
                                              .collection('addresses')
                                              .doc(snapshot.data![index].id)
                                              .delete();
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        child: const Text("Delete")),
                                  ],
                                ),
                              );
                            },
                            badgeStyle:
                                const badges.BadgeStyle(badgeColor: Colors.red),
                            showBadge: true,
                            badgeContent: const Icon(
                              Icons.close,
                              color: kPrimaryLightColor,
                              size: 12,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(defaultPadding),
                              margin:
                                  const EdgeInsets.only(bottom: defaultPadding),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: kPrimaryLightColor,
                              ),
                              height: 80,
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Address ${index + 1}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                      "${snapshot.data![index].addressname} - ${snapshot.data![index].barangay}, ${snapshot.data![index].city}, ${snapshot.data![index].province}")
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        )),
      ),
    );
  }
}

class AddMyAddress extends StatefulWidget {
  const AddMyAddress({super.key});

  @override
  State<AddMyAddress> createState() => _AddMyAddressState();
}

class _AddMyAddressState extends State<AddMyAddress> {
  TextEditingController addressNameController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController extendedController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Background(
        child: Container(
      padding: const EdgeInsets.fromLTRB(15, 45, 15, 0),
      child: Column(
        children: [
          const Text(
            'Add Address',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor),
          ),
          const SizedBox(height: defaultPadding),
          flatTextField("Address Name", addressNameController),
          const SizedBox(height: defaultPadding),
          flatTextField("Barangay", barangayController),
          const SizedBox(height: defaultPadding),
          flatTextField("City", cityController),
          const SizedBox(height: defaultPadding),
          flatTextField("Extended Address", extendedController),
          const SizedBox(height: defaultPadding),
          flatTextField("Province", provinceController),
          const SizedBox(height: defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back')),
              TextButton(
                  onPressed: () async {
                    await _addAddress().then((value) {
                      Navigator.of(context).pop();
                      setState(() {});
                    });
                  },
                  child: const Text('Add Address')),
            ],
          ),
        ],
      ),
    ));
  }

  Future<void> _addAddress() async {
    try {
      if (addressNameController.text.isNotEmpty &&
          barangayController.text.isNotEmpty &&
          cityController.text.isNotEmpty &&
          extendedController.text.isNotEmpty &&
          provinceController.text.isNotEmpty) {
        await db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('addresses')
            .add({
          "Address Name": addressNameController.text,
          "Barangay": barangayController.text,
          "City": cityController.text,
          "Extended Address": extendedController.text,
          "Province": provinceController.text,
        });
      } else {
        toastification.show(
          type: ToastificationType.error,
          context: context,
          title: const Text('Incomplete Address'),
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      log("error adding address $e");
    }
  }
}
