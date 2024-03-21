import 'package:customer/components/constants.dart';
import 'package:customer/screens/Booking/EditEventComponents/event_data_source.dart';
import 'package:customer/screens/Booking/EditEventComponents/event_provider.dart';
import 'package:customer/screens/Booking/EditEventComponents/task_widget.dart';
import 'package:customer/screens/Booking/editEvent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text('Booking indiv worker'),
        foregroundColor: kPrimaryLightColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
                child: SfCalendar(
              view: CalendarView.month,
              // initialSelectedDate: DateTime.now(),
              dataSource: EventDataSource(events),
              onLongPress: (details) {
                final provider =
                    Provider.of<EventProvider>(context, listen: false);
                provider.setDate(details.date!);
                showModalBottomSheet(
                    context: context, builder: (context) => TaskWidget());
              },
              allowedViews: [
                CalendarView.month,
                CalendarView.week,
                CalendarView.day,
                CalendarView.schedule,
              ],
            )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BookingEventDetails()));
          },
          backgroundColor: kPrimaryColor,
          child: Icon(
            Icons.add,
            color: kPrimaryLightColor,
          )),
    );
  }
}
