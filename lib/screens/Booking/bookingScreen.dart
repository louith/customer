import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/features/parse.dart';
import 'package:customer/screens/Booking/editEvent.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// ignore: must_be_immutable
class BookingScreen extends StatefulWidget {
  String username;
  String userID;
  String role;
  String address;

  BookingScreen({
    super.key,
    required this.username,
    required this.userID,
    required this.role,
    required this.address,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<String> calendarViewOptions = [
    'Week',
    'Day',
    'Month',
  ];
  String selectedView = 'Week';
  Parse parser = Parse();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: const EdgeInsets.only(top: 45),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            foregroundColor: kPrimaryLightColor,
            title: Text(widget.username),
          ),
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
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookingAppointment(
                              userID: widget.userID,
                              username: widget.username,
                              role: widget.role,
                              address: widget.address,
                            )));
              },
              backgroundColor: kPrimaryColor,
              child: const Icon(
                Icons.add,
                color: kPrimaryLightColor,
              )),
        ),
      ),
    );
  }

  Future<List<Appointment>> getAppointments() async {
    try {
      List<Map<String, dynamic>> appointments = [];
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .collection('bookings')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          appointments.add(data);
        }
      }
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
