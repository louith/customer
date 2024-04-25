// ignore_for_file: unused_element, non_constant_identifier_names, must_be_immutable

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/models/service.dart';
import 'package:customer/screens/Booking/payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BookingAppointment extends StatefulWidget {
  String userID;
  String username;
  String role;
  String address;

  BookingAppointment({
    super.key,
    required this.userID,
    required this.username,
    required this.role,
    required this.address,
  });

  @override
  State<BookingAppointment> createState() => _BookingAppointmentState();
}

User? currentUser = FirebaseAuth.instance.currentUser;
final db = FirebaseFirestore.instance;

class _BookingAppointmentState extends State<BookingAppointment> {
  DateTime timeFrom = DateTime.now();
  DateTime timeTo = DateTime.now();
  FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, ClientService> addedService = {};
  String username = '';
  late String lat;
  late String long;
  GeoCode geoCode = GeoCode();
  String location = '';

  String formatNum(num value) {
    final format = NumberFormat('#,##0.00');
    return format.format(value);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsername();
  }

  @override
  Widget build(BuildContext context) {
    List<int> prices = [];
    return Container(
      color: kPrimaryColor,
      padding: const EdgeInsets.only(top: 45),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            badges.Badge(
                position: badges.BadgePosition.topEnd(top: 1, end: 4),
                badgeStyle:
                    const badges.BadgeStyle(badgeColor: kPrimaryLightColor),
                showBadge: true,
                badgeContent: Text(addedService.length.toString()),
                child: IconButton(
                    onPressed: () {
                      /////////////////////////RAAAAAAAGHHHHHH///////////////////////////
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(defaultPadding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Services Cart - ${widget.username}'),
                                const SizedBox(height: defaultPadding),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: addedService.isEmpty
                                      ? 1
                                      : addedService.length + 1,
                                  itemBuilder: (context, index) {
                                    if (addedService.isEmpty) {
                                      return const Center(
                                          child: Text('Cart is Empty'));
                                    } else if (index == addedService.length) {
                                      for (var price in addedService.values) {
                                        prices.add(int.parse(price.price));
                                      }
                                      // setState(() {
                                      //   serviceFee = getServiceFee(prices)!;
                                      // });
                                      // log(serviceFee);
                                      var total =
                                          double.parse(getServiceFee(prices)!) +
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
                                              Text("PHP ${formatNum(total)}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else {
                                      final mapToList =
                                          addedService.values.toList();
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(mapToList[index].serviceName),
                                          Text(
                                              "PHP ${formatNum(double.parse(mapToList[index].price))}"),
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
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
                                  if (date == null)
                                    return; // when pressed cancel
                                  final time = await pickTime(
                                      TimeOfDay.fromDateTime(timeFrom));
                                  if (time == null)
                                    return; // when pressed cancel
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
                                        style: const TextStyle(
                                            color: kPrimaryColor))),
                              ],
                            )
                        ],
                      ),
                      const Text(
                        'Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      widget.role == 'salon'
                          ? Text(widget.address)
                          : Column(
                              children: [
                                Text(location.isEmpty
                                    ? 'My Location'
                                    : location),
                                const SizedBox(height: defaultPadding),
                                ElevatedButton(
                                    style: const ButtonStyle(
                                        foregroundColor:
                                            MaterialStatePropertyAll(
                                                kPrimaryLightColor)),
                                    onPressed: _selectAddress,
                                    child:
                                        const Text('Select From My Addresses')),
                                const SizedBox(height: defaultPadding),
                                ElevatedButton(
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                kPrimaryLightColor),
                                        foregroundColor:
                                            MaterialStatePropertyAll(
                                                kPrimaryColor)),
                                    onPressed: () {
                                      getCurrentLocation().then((value) {
                                        lat = '${value!.latitude}';
                                        long = '${value.longitude}';
                                        geocodeAddress(lat, long);
                                      });
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_pin),
                                        SizedBox(width: defaultPadding / 2),
                                        Text('Get Current Address'),
                                      ],
                                    )),
                                const SizedBox(height: defaultPadding),
                                ElevatedButton(
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                kPrimaryLightColor),
                                        foregroundColor:
                                            MaterialStatePropertyAll(
                                                kPrimaryColor)),
                                    onPressed: () {},
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.map),
                                        SizedBox(width: defaultPadding / 2),
                                        Text('Open In Google Maps'),
                                      ],
                                    )),
                              ],
                            ),
                    ],
                  ),
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
      ),
    );
  }

  Future<void> _selectAddress() async {
    return showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: getMyAddresses(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return AlertDialog(
                title: const Text('Select Address'),
                content: StatefulBuilder(builder: (context, setState) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      String address =
                          "${snapshot.data![index].addressname} - ${snapshot.data![index].barangay}, ${snapshot.data![index].city}, ${snapshot.data![index].province}";
                      return RadioListTile<String>(
                        title: Text(address),
                        value: address,
                        groupValue: location,
                        onChanged: (value) => setState(() {
                          location = value.toString();
                        }),
                      );
                    },
                  );
                }),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('BACK'))
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }

  geocodeAddress(String latitude, String longitude) async {
    try {
      Address address = await geoCode.reverseGeocoding(
          latitude: double.parse(latitude), longitude: double.parse(longitude));
      String locationNow =
          '${address.streetAddress}, ${address.city}, ${address.countryName}';
      setState(() {
        location = locationNow;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> openMap(String lat, String long) async {
    try {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$lat,$long';
      log(googleUrl);

      await canLaunchUrlString(googleUrl)
          ? await launchUrlString(googleUrl)
          : throw 'cannot launch $googleUrl';
    } catch (e) {
      log(e.toString());
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        log('Location permission denied');
        // return Future.error('Location permission denied');
      }
      if (permission == LocationPermission.deniedForever) {
        log('Location permission permanently denied, cannot get location');
        // return Future.error(
        //     'Location permission permanently denied, cannot get location');
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      log('error getting current location $e');
      return null;
    }
  }

  DateTime addDuration(DateTime from) {
    List<String> serviceDurations = [];
    if (addedService.isNotEmpty) {
      for (var timeTo in addedService.values) {
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
                              clientUsername: widget.username,
                              customerUsername: username,
                              serviceTypes: serviceTypes.data!,
                              services: services.data!,
                              serviceTypeIndex: index,
                              updateCart: updateCart,
                              cart: addedService,
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

  void updateCart(ClientService service) {
    if (!addedService.keys.contains(service.serviceName)) {
      addedService[service.serviceName] = service;
    } else {
      addedService.remove(service.serviceName);
    }
    setState(() {});
  }

  getUsername() async {
    DocumentSnapshot docRef =
        await db.collection('users').doc(currentUser!.uid).get();
    setState(() {
      username = docRef['Username'];
    });
  }

  Future<void> finishDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Finish Booking?'),
          content:
              const Text("Appointment details can't be edited once submitted"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('BACK'),
            ),
            TextButton(
              onPressed: () {
                if (addedService.isEmpty ||
                    timeTo.isBefore(DateTime.now()) ||
                    (widget.role == 'freelancer' && location.isEmpty)) {
                  Navigator.of(context).pop();
                  toastification.show(
                    type: ToastificationType.error,
                    context: context,
                    title: const Text('Invalid Booking'),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                } else {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      if (widget.role == 'salon') {
                        return PaymentScreen(
                          clientUsername: widget.username,
                          clientID: widget.userID,
                          customerUsername: username,
                          address: widget.address,
                          dateTimeFrom: timeFrom,
                          dateTimeTo: addDuration(timeTo),
                          cart: addedService,
                          role: widget.role,
                        );
                      } else if (widget.role == 'freelancer') {
                        return PaymentScreen(
                          clientUsername: widget.username,
                          clientID: widget.userID,
                          customerUsername: username,
                          address: location,
                          dateTimeFrom: timeFrom,
                          dateTimeTo: addDuration(timeTo),
                          cart: addedService,
                          role: widget.role,
                        );
                      } else {
                        return Container();
                      }
                    },
                  ));
                }
              },
              child: const Text('BOOK'),
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

  String? getServiceFee(List<int> list) {
    if (list.isEmpty) {
      return null;
    }
    int sum = list.reduce((value, element) => value + element);
    return (sum * .05).toStringAsFixed(2);
  }
}

class ServicesBookingList extends StatefulWidget {
  List<String> serviceTypes;
  List<ClientService> services;
  int serviceTypeIndex;
  Function(ClientService) updateCart;
  Map<String, dynamic> cart;
  String customerUsername;
  String clientUsername;

  ServicesBookingList({
    super.key,
    required this.clientUsername,
    required this.serviceTypes,
    required this.services,
    required this.serviceTypeIndex,
    required this.updateCart,
    required this.cart,
    required this.customerUsername,
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
            priceFormat.format(double.parse(widget.services[index].price));
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
                widget.updateCart(
                  widget.services[index],
                );
              });
            },
          ),
        );
      },
    );
  }
}

class MyAddress {
  String id;
  String addressname;
  String barangay;
  String city;
  String extended;
  String province;

  MyAddress({
    required this.id,
    required this.addressname,
    required this.barangay,
    required this.city,
    required this.extended,
    required this.province,
  });
}

Future<List<MyAddress>> getMyAddresses() async {
  try {
    List<MyAddress> addresses = [];
    QuerySnapshot querySnapshot = await db
        .collection('users')
        .doc(currentUser!.uid)
        .collection('addresses')
        .get();
    querySnapshot.docs.forEach((element) {
      addresses.add(MyAddress(
          id: element.id,
          addressname: element['Address Name'],
          barangay: element['Barangay'],
          city: element['City'],
          extended: element['Extended Address'],
          province: element['Province']));
    });
    return addresses;
  } catch (e) {
    log('error getting addresses');
    return [];
  }
}
