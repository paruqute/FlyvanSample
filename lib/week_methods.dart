import 'package:week_number/iso.dart';



int getIsoWeeksInYear(int year) {
  // Find January 1 of the year
  DateTime jan1 = DateTime(year, 1, 1);

  // Find December 31 of the year
  DateTime dec31 = DateTime(year, 12, 31);

  // ISO Week 1 must contain January 4
  // Check if the year has 53 weeks
  if (jan1.weekday == 4 || // Jan 1 is Thursday
      dec31.weekday == 4) { // Dec 31 is Thursday
    return 53;
  }

  // Otherwise, the year has 52 weeks
  return 52;
}



/// Calculate the first day of the first week of a given year
DateTime getFirstWeekStartDate(int year) {
  // Find the first Monday on or before January 4 of the given year
  DateTime jan4 = DateTime(year, 1, 4);
  int weekday = jan4.weekday; // 1 = Monday, 7 = Sunday
  return jan4.subtract(Duration(days: weekday - 1)); // Go back to Monday
}

/// Get all days of a specific week in a specific year
List<DateTime> getDaysOfWeek(int year, int week) {
  DateTime firstWeekStart = getFirstWeekStartDate(year);
  return List.generate(7, (index) {
    return firstWeekStart.add(Duration(days: (week - 1) * 7 + index));
  });
}


// int getWeekNumber(DateTime date) {
//   // Find the first Monday of the year
//   DateTime jan4 = DateTime(date.year, 1, 4); // January 4 is always in Week 1
//   int weekdayJan4 = jan4.weekday; // Weekday of January 4
//   DateTime firstMonday = jan4.subtract(Duration(days: weekdayJan4 - 1)); // Back to Monday
//
//   // Calculate difference in days and divide by 7 to get the week number
//   int daysSinceFirstMonday = date.difference(firstMonday).inDays;
//   return (daysSinceFirstMonday ~/ 7) + 1;
// }
getDay(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return "Monday";
    case DateTime.tuesday:
      return "Tuesday";
    case DateTime.wednesday:
      return "Wednesday";
    case DateTime.thursday:
      return "Thursday";
    case DateTime.friday:
      return "Friday";
    case DateTime.saturday:
      return "Saturday";
    case DateTime.sunday:
      return "Sunday";
    default:
      return "";
  }
}


int getYearFromWeek(DateTime date) {
  int weekNumber = date.weekNumber;
  int year = date.year;

  // If it's January and week is 52 or 53, adjust to the previous year
  if ((weekNumber == 52 || weekNumber == 53) && date.month == 1) {
    year -= 1;
  }

  // If it's December and week 1, adjust to next year
  if (weekNumber == 1 && date.month == 12) {
    year += 1;
  }

  return year;
}