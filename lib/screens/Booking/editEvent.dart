// ignore_for_file: unused_element, non_constant_identifier_names, must_be_immutable

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/models/service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:badges/badges.dart' as badges;

class BookingAppointment extends StatefulWidget {
  String userID;

  BookingAppointment({super.key, required this.userID});

  @override
  State<BookingAppointment> createState() => _BookingAppointmentState();
}

class _BookingAppointmentState extends State<BookingAppointment> {
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();
  FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, ClientService> addedServices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          badges.Badge(
              position: badges.BadgePosition.topEnd(top: 1, end: 4),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: kPrimaryLightColor,
              ),
              showBadge: true,
              badgeContent: Text(addedServices.length.toString()),
              child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.list_alt_rounded,
                    size: 28,
                  )))
        ],
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
        title: const Text('Services Booking'),
      ),
      body: Background(
          child: Container(
        margin: const EdgeInsets.fromLTRB(15, 30, 15, 0),
        child: FutureBuilder<List<Appointment>>(
          future:
              getAppointmentsTime(), //has starttime and endtime of appointments
          builder: (context, snapshot) {
            //enclosed in this builder since it needs the snapshot data of the future method
            bool hasOverlap(Appointment newAppointment) {
              for (Appointment existingAppointment in snapshot.data!) {
                if (newAppointment.startTime
                        .isBefore(existingAppointment.endTime) &&
                    newAppointment.endTime
                        .isAfter(existingAppointment.startTime)) {
                  return true; //has overlap
                }
              }
              return false; // has no overlap
            }

            if (snapshot.hasData) {
              return Column(
                children: [
                  const Text(
                    'Select Service(s)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .55,
                    child: ServicesList(widget.userID),
                  ),
                  const SizedBox(height: defaultPadding),
                  //list of services by client here
                  const Text(
                    'Select Date & Time of Appointment',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: defaultPadding),
                  //scheduling method
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('From'),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              )
                            ],
                          ),
                          TextButton(
                            onPressed: () async {
                              final date = await pickDate(from);
                              if (date == null) return; // when pressed cancel
                              final time =
                                  await pickTime(TimeOfDay.fromDateTime(from));
                              if (time == null) return; // when pressed cancel
                              final dateTimeSet = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              if (dateTimeSet.isAfter(DateTime.now())) {
                                log(dateTimeSet.toString());
                                setState(() {
                                  from = dateTimeSet;
                                  to = dateTimeSet;
                                });
                              } else {
                                log('date cannot be before now');
                                return;
                              }
                            },
                            child: Text(
                              '${DateFormat.MMMEd().format(from)}, ${DateFormat.jm().format(from)}',
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                      if (from.isAfter(DateTime.now())) const Text('-'),
                      if (from.isAfter(DateTime.now()))
                        Column(
                          children: [
                            const Text('To'),
                            TextButton(
                                onPressed: null,
                                child: Text(
                                    '${DateFormat.MMMEd().format(to)}, ${DateFormat.jm().format(to)}',
                                    style:
                                        const TextStyle(color: kPrimaryColor))),
                          ],
                        )
                    ],
                  ),
                ],
              );
              //test out function first by adding datettime pickers for datefrom and dateto
              //get services duration once checked and add the duration of each services to the datefrom time variable
            } else {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            }
          },
        ),
      )),
      floatingActionButton: FloatingActionButton(
          onPressed: finishDialog,
          backgroundColor: kPrimaryColor,
          child: const Icon(
            Icons.check,
            color: kPrimaryLightColor,
          )),
    );
  }

  Widget ServicesList(String id) {
    //gets service types of user
    Future<List<String>> getServiceTypes() async {
      try {
        List<String> serviceTypes = [];
        QuerySnapshot querySnapshot =
            await db.collection('users').doc(id).collection('services').get();
        for (var types in querySnapshot.docs) {
          serviceTypes.add(types.id);
        }
        return serviceTypes;
      } catch (e) {
        log('error getting service types $e');
        return [];
      }
    }

    return FutureBuilder<List<String>>(
      future: getServiceTypes(),
      builder: (context, serviceTypes) {
        if (serviceTypes.hasData) {
          return BookingList(
            //scrollwidget thingy
            clientID: widget.userID,
            serviceTypes: serviceTypes.data!,
            cartNum: addedServices.length,
            updateCart: updateCart,
          );
        } else {
          return const Text('LOADING...');
          // return const CircularProgressIndicator(color: kPrimaryColor);
        }
      },
    );
  }

  updateCart(ClientService service) {
    if (!addedServices.keys.contains(service.serviceName)) {
      addedServices[service.serviceName] = service;
    } else {
      addedServices.remove(service.serviceName);
    }
    setState(() {});
  }

  Future<void> finishDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Finish Booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('BACK'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> pickDate(DateTime dateTime) => showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialDate: dateTime,
      );

  Future<TimeOfDay?> pickTime(TimeOfDay timeOfDay) => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: timeOfDay.hour, minute: timeOfDay.minute),
      );

  Future<List<Appointment>> getAppointmentsTime() async {
    List<Map<String, dynamic>> appointments = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .collection('bookings')
          .get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        appointments.add(data);
      }

      final List<Appointment> appointmentList = appointments.map(
        (a) {
          final appointment = Appointment(
            startTime: a['dateFrom'].toDate(),
            endTime: a['dateTo'].toDate(),
          );
          return appointment;
        },
      ).toList();
      return appointmentList;
    } catch (e) {
      log('error getting start and end time $e');
      return [];
    }
  }
}

class BookingList extends StatefulWidget {
  String clientID;
  List<String> serviceTypes;
  int cartNum;
  Function(ClientService) updateCart;

  BookingList({
    super.key,
    required this.clientID,
    required this.serviceTypes,
    required this.cartNum,
    required this.updateCart,
  });

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late List<List<bool>> checkboxValues;

  @override
  void initState() {
    super.initState();
    checkboxValues = List.generate(widget.serviceTypes.length,
        (_) => List.filled(widget.serviceTypes.length, false));
  }

  @override
  Widget build(BuildContext context) {
    ////////////////LIST OF DIFFERENT SERVICES////////////////////
    return ListView.separated(
      itemCount: widget.serviceTypes.length,
      separatorBuilder: (context, serviceTypeIndex) => const Divider(),
      itemBuilder: (context, serviceTypeIndex) {
        String serviceType =
            widget.serviceTypes[serviceTypeIndex]; // Hair, Wax, etc.
        //FUTUREBUILDER/////////////////////////////////////////////////////////////////////////////////////////////
        return FutureBuilder(
          future: getServices(serviceType, widget.clientID),
          builder: (context, services) {
            if (services.hasData) {
              return buildServiceCheckBox(
                serviceType, //string Hair, Wax, etc...
                services.data!, // list of services List of ClientService
                serviceTypeIndex, // index of each service from a single service type
                widget.cartNum, // int cart values
              );
            } else {
              return const Text('LOADING...');
            }
          },
        );
      },
    );
  }

  Widget buildServiceCheckBox(
    String serviceType,
    List<ClientService> services,
    int serviceTypeIndex,
    int cartNum,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, serviceIndex) {
            try {
              String servicename = services[serviceIndex].serviceName;
              String price = services[serviceIndex].price;
              String duration = services[serviceIndex].duration;
              bool checkboxValue =
                  checkboxValues[serviceTypeIndex][serviceIndex];
              // log(serviceType + servicename + checkboxValue.toString());
              return CheckboxListTile(
                title: Text(servicename),
                value: checkboxValue,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PHP $price'), //price
                    Text(duration),
                  ],
                ),
                onChanged: (bool? value) {
                  setState(() {
                    checkboxValues[serviceTypeIndex][serviceIndex] =
                        value!; //checks for each card
                    widget.updateCart(services[serviceIndex]);
                  });
                },
              );
            } catch (e) {
              return Center(child: Text(e.toString()));
            }
          },
        ),
      ],
    );
  }
}
