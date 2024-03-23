// ignore: file_names
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/features/parse.dart';
import 'package:customer/screens/Booking/editEvent.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// ignore: must_be_immutable
class BookingScreen extends StatefulWidget {
  String clientId;
  String clientUsername;

  BookingScreen({
    super.key,
    required this.clientId,
    required this.clientUsername,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Parse convert = Parse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        actions: [],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Text('Book ${widget.clientUsername}'),
        foregroundColor: kPrimaryLightColor,
      ),
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
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BookingEventDetails()));
          },
          backgroundColor: kPrimaryColor,
          child: const Icon(
            Icons.add,
            color: kPrimaryLightColor,
          )),
    );
  }

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
