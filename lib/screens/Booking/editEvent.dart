// ignore_for_file: unused_element, non_constant_identifier_names, must_be_immutable

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/models/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:badges/badges.dart' as badges;

class BookingAppointment extends StatefulWidget {
  String userID;
  String username;

  BookingAppointment({
    super.key,
    required this.userID,
    required this.username,
  });

  @override
  State<BookingAppointment> createState() => _BookingAppointmentState();
}

class _BookingAppointmentState extends State<BookingAppointment> {
  DateTime timeFrom = DateTime.now();
  DateTime timeTo = DateTime.now();
  FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, ClientService> addedServices = {};
  List<ClientService> cart = [];
  User? currentUser = FirebaseAuth.instance.currentUser;

  String formatDouble(double value) {
    final format = NumberFormat('#,##0.00');
    return format.format(value);
  }

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
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Services Cart - ${widget.username}'),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: cart.isEmpty ? 1 : cart.length + 1,
                                itemBuilder: (context, index) {
                                  if (cart.isEmpty) {
                                    return const Center(
                                        child: Text('Cart is Empty'));
                                  } else if (index == cart.length) {
                                    List<int> prices = [];
                                    for (var price in cart) {
                                      prices.add(int.parse(price.price));
                                    }
                                    var total =
                                        double.parse(getServiceFee(prices)) +
                                            prices.reduce((value, element) =>
                                                value + element);
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Service Fee'),
                                            Text(
                                                "PHP ${getServiceFee(prices)}"),
                                          ],
                                        ),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Total',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text("PHP ${formatDouble(total)}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(cart[index].serviceName),
                                        Text(
                                            "PHP ${formatDouble(double.parse(cart[index].price))}"),
                                      ],
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.list_alt_rounded,
                    size: 28,
                  )))
        ],
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
        title: const Column(
          children: [
            Text(
              'Services Booking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Make sure Service Provider\nhas no Appointment Conflicts',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            )
            // SizedBox(height: defaultPadding,)
          ],
        ),
      ),
      body: Background(
          child: Container(
        margin: const EdgeInsets.fromLTRB(15, 30, 15, 0),
        child: FutureBuilder<List<Appointment>>(
          future: getAppointmentsTime(),
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
                              final date = await pickDate(timeFrom);
                              if (date == null) return; // when pressed cancel
                              final time = await pickTime(
                                  TimeOfDay.fromDateTime(timeFrom));
                              if (time == null) return; // when pressed cancel
                              final dateTimeSet = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              if (dateTimeSet.isAfter(DateTime.now())) {
                                setState(() {
                                  timeFrom = dateTimeSet;
                                  timeTo = dateTimeSet;
                                });
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text('Invalid Date'),
                                  action: SnackBarAction(
                                      label: 'Close', onPressed: () {}),
                                ));
                                return;
                              }
                            },
                            child: Text(
                              '${DateFormat.MMMEd().format(timeFrom)}, ${DateFormat.jm().format(timeFrom)}',
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                      //will show after appointment from is after datetime now
                      if (timeFrom.isAfter(DateTime.now())) const Text('-'),
                      if (timeFrom.isAfter(DateTime.now()))
                        Column(
                          children: [
                            const Text('To'),
                            TextButton(
                                onPressed: null,
                                child: Text(
                                    //DAY, DATE                            TIME:00 @ PM
                                    '${DateFormat.MMMEd().format(addDuration(timeFrom))}, ${DateFormat.jm().format(addDuration(timeFrom))}',
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

  DateTime addDuration(DateTime from) {
    List<String> serviceDurations = [];
    if (cart.isNotEmpty) {
      for (var timeTo in cart) {
        String duration = timeTo.duration;
        serviceDurations.add(duration);
      }
      List<Map<String, dynamic>> parsedDuration =
          serviceDurations.map((duration) {
        List<String> parts = duration.split(' ');
        int value = int.parse(parts[0]);
        String unit = parts[1];
        return {'value': value, 'unit': unit};
      }).toList();

      for (var durations in parsedDuration) {
        if (durations['unit'] == 'hr') {
          from = from.add(Duration(hours: durations['value']));
        } else if (durations['unit'] == 'min') {
          from = from.add(Duration(minutes: durations['value']));
        }
      }

      return from;
    } else {
      return DateTime.now();
    }
  }

  String getServiceFee(List<int> list) {
    if (list.isEmpty) {
      return '0.00';
    }
    int sum = list.reduce((value, element) => value + element);
    return (sum * .05).toStringAsFixed(2);
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
          return ListView.separated(
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceTypes.data![index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder(
                      future: getServices(serviceTypes.data![index], id),
                      builder: (context, services) {
                        if (services.hasData) {
                          try {
                            return ServicesBookingList(
                              serviceTypes: serviceTypes.data!,
                              services: services.data!,
                              serviceTypeIndex: index,
                              updateCart: updateCart,
                              cart: cart,
                            );
                          } catch (e) {
                            return Text(e.toString());
                          }
                        } else {
                          return const Text('LOADING...');
                        }
                      },
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: serviceTypes.data!.length);
        } else {
          return const Text('LOADING...');
          // return const CircularProgressIndicator(color: kPrimaryColor);
        }
      },
    );
  }

  //FIX BUG
  void updateCart(ClientService service) {
    if (!addedServices.keys.contains(service.serviceName) &&
        !cart.contains(service)) {
      addedServices[service.serviceName] = service;
      cart.add(service);
    } else {
      addedServices.remove(service.serviceName);
      cart.remove(service);
    }
    setState(() {});
  }

  Future<void> finishDialog() {
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
              onPressed: () {
                if (cart.isEmpty || timeFrom.isBefore(DateTime.now())) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Invalid Booking'),
                    action: SnackBarAction(
                      label: 'Close',
                      onPressed: () {},
                    ),
                  ));
                } else {
                  addAppointmentToFirestore();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  log('added');
                  //save to firestore
                }
              },
              child: const Text('BOOK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addAppointmentToFirestore() async {
    List<Map<String, dynamic>> services = cart
        .map((e) => {
              'serviceName': e.serviceName,
              'duration': e.duration,
              'price': e.price,
              'description': e.description,
            })
        .toList();
    try {
      await db
          .collection('users')
          .doc(widget.userID)
          .collection('bookings')
          .add({
        'customerID': currentUser!.uid,
        'clientID': widget.userID,
        'status': 'pending',
        'dateFrom': timeFrom,
        'dateTo': addDuration(timeFrom),
        'worker': '',
        'paymentMethod': '',
        'location': '',
        'services': services,
      });
    } catch (e) {
      log('error adding appointment $e');
    }
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

class ServicesBookingList extends StatefulWidget {
  List<String> serviceTypes;
  List<ClientService> services;
  int serviceTypeIndex;
  Function(ClientService) updateCart;
  List<ClientService> cart;

  ServicesBookingList({
    super.key,
    required this.serviceTypes,
    required this.services,
    required this.serviceTypeIndex,
    required this.updateCart,
    required this.cart,
  });

  @override
  State<ServicesBookingList> createState() => _ServicesBookingListState();
}

class _ServicesBookingListState extends State<ServicesBookingList> {
  late List<List<bool>> checkboxvalues;
  final priceFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    checkboxvalues = List.generate(widget.serviceTypes.length,
        (index) => List.filled(widget.services.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.services.length,
      itemBuilder: (context, index) {
        String serviceName = widget.services[index].serviceName;
        String price =
            priceFormat.format(int.parse(widget.services[index].price));
        String duration = widget.services[index].duration;
        return Container(
          width: double.infinity,
          color: kPrimaryLightColor,
          margin: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
          child: CheckboxListTile(
            value: checkboxvalues[widget.serviceTypeIndex][index],
            title: Text(
              serviceName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("PHP $price"), Text(duration)],
            ),
            onChanged: (bool? value) {
              setState(() {
                checkboxvalues[widget.serviceTypeIndex][index] =
                    value!; //checks for each card
                widget.updateCart(widget.services[index]);
              });
            },
          ),
        );
      },
    );
  }
}
