import 'package:flutter/material.dart';

String formatTime(BuildContext context, DateTime dt) {
  final time = TimeOfDay.fromDateTime(dt);
  return MaterialLocalizations.of(context).formatTimeOfDay(time);
}

String formatDateHeader(String dateStr) {
  final date = DateTime.parse(dateStr);
  final now = DateTime.now();

  if (isSameDay(date, now)) return "Today";
  if (isSameDay(date, now.subtract(const Duration(days: 1))))
    return "Yesterday";

  return "${date.day}/${date.month}/${date.year}";
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year &&
         a.month == b.month &&
         a.day == b.day;
}