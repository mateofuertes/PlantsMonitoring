import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return 
    Column(children: <Widget>[
      Center(
        child: TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: provider.focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(provider.selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            provider.setSelectedDay(selectedDay);
            provider.setFocusedDay(focusedDay);
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.lightGreen,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
        ),
        onPressed: () {
          provider.setDate();
          if (provider.errorMessage != null) {
            SnackBar snackBar = SnackBar(content: Text(provider.errorMessage!));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: const Text('Synchronize date', style: TextStyle(color: Colors.white)),
      ),

    ]);
  }
}
