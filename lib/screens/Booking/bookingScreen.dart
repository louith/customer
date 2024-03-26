<<<<<<< HEAD
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/features/parse.dart';
import 'package:customer/screens/Booking/EditEventComponents/event_provider.dart';
=======
// ignore: file_names
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/features/parse.dart';
>>>>>>> 3a40f45acddc24627a5f3aeca589558fc98da565
import 'package:customer/screens/Booking/editEvent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
=======
>>>>>>> 3a40f45acddc24627a5f3aeca589558fc98da565
import 'package:syncfusion_flutter_calendar/calendar.dart';

// ignore: must_be_immutable
class BookingScreen extends StatefulWidget {
<<<<<<< HEAD
  String username;
  String userID;
  BookingScreen({super.key, required this.username, required this.userID});
=======
  String clientId;
  String clientUsername;

  BookingScreen({
    super.key,
    required this.clientId,
    required this.clientUsername,
  });
>>>>>>> 3a40f45acddc24627a5f3aeca589558fc98da565

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
<<<<<<< HEAD
  List<String> calendarViewOptions = [
    'Week',
    'Day',
    'Month',
  ];
  String selectedView = 'Week';
  Parse parser = Parse();
=======
  Parse convert = Parse();
>>>>>>> 3a40f45acddc24627a5f3aeca589558fc98da565

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
<<<<<<< HEAD
=======
        actions: [],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Text('Book ${widget.clientUsername}'),
>>>>>>> 3a40f45acddc24627a5f3aeca589558fc98da565
        foregroundColor: kPrimaryLightColor,
        title: Text(widget.username),
      ),
<<<<<<< HEAD
      body: Column(
        children: [
          FutureBuilder(
            future: getAppointments(),
            builder: (context, appointments) {
              if (appointments.hasData) {
                return Expanded(
                  child: SfCalendar(
                    view: CalendarView.month,
                    dataSource: MeetingDataSource(appointments.data!),
                    allowedViews: const [
                      CalendarView.month,
                      CalendarView.week,
                      CalendarView.day,
                      CalendarView.schedule,
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              }
            },
          ),
        ],
=======
      body: Background(
        child: StreamBuilder<List<Appointment>>(
            stream: Stream.fromFuture(getAppointments()),
            builder: (context, appointments) {
              if (appointments.hasError) {
                return Center(
                  child:
                      Text('Error getting appointments ${appointments.error}'),
                );
              } else if (appointments.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                );
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: SfCalendar(
                        showTodayButton: true,
                        allowViewNavigation: true,
                        view: CalendarView.month,
                        dataSource: MeetingDataSource(appointments.data!),
                        onTap: (details) =>
                            {calendarOnTap(details, 'Services go here')},
                        allowedViews: const [
                          CalendarView.month,
                          CalendarView.week,
                          CalendarView.day,
                        ],
                      ),
                    ),
                  ],
                );
              }
            }),
>>>>>>> 3a40f45acddc24627a5f3aeca589558fc98da565
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BookingAppointment(userID: widget.userID)));
          },
          backgroundColor: kPrimaryColor,
          child: const Icon(
            Icons.add,
            color: kPrimaryLightColor,
          )),
    );
  }

<<<<<<< HEAD
  Future<List<Appointment>> getAppointments() async {
    List<Map<String, dynamic>> appointments = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .collection('bookings')
          .get();
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        appointments.add(data);
      });

      final List<Appointment> appointmentList = appointments.map((a) {
        // Assign a default color if 'status' doesn't match any expected values
        final color = a['status'] == 'pending'
            ? const Color.fromARGB(255, 158, 158, 158)
            : a['status'] == 'confirmed'
                ? kPrimaryColor
                : const Color.fromARGB(255, 76, 175, 80);
        final appointment = Appointment(
          id: a['reference'].toString(),
          subject: parser.extractServiceNamesFromListofMap(
              parser.stringToMap(a['services'].toString())),
          notes: a['customerID'].toString(),
          location: a['location'],
          startTime: a['dateFrom'].toDate(),
          endTime: a['dateTo'].toDate(),
          color: color, // Fallback color
        );
        return appointment;
      }).toList();

      return appointmentList;
    } catch (e) {
      log('Error getting appointments: $e');
      return []; // Return empty list in case of error
=======
  List<Map<String, dynamic>> convertList(List<dynamic> inputList) {
    List<Map<String, dynamic>> resultList = [];
    for (var item in inputList) {
      if (item is Map<String, dynamic>) {
        resultList.add(item);
      }
    }
    return resultList;
  }

  Future<List<Appointment>> getAppointments() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientId)
          .collection('bookings')
          .get();
      List<Appointment> appointments = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Color color = data['status'].isNotEmpty ? kPrimaryColor : Colors.grey;
        appointments.add(Appointment(
          subject: convert.extractServiceNamesFromListofMap(data['services']),
          startTime: data['dateFrom'].toDate(),
          endTime: data['dateTo'].toDate(),
          color: color,
        ));
      }
      return appointments;
    } catch (e) {
      log('Error fetching appointments: $e');
      return [];
    }
  }

  void calendarOnTap(CalendarTapDetails details, String services) {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      showModalBottomSheet<void>(
        context: context,
        builder: (context) {
          return Container(
            height: 250,
            color: kPrimaryLightColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(services),
                  const Text('Time to - Time from'),
                ],
              ),
            ),
          );
        },
      );
>>>>>>> 3a40f45acddc24627a5f3aeca589558fc98da565
    }
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
