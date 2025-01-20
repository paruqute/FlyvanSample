import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/Day_model.dart';
import '../model/employee_model.dart';
import '../model/route_model.dart';
import '../model/vehicle.dart';
import '../model/weekly_report.dart';
import '../week_methods.dart';

class WeeklyReportProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<WeeklyReportModel>? weeklyReportList = [];
  List<Employee> employeesList = [];
  List<Vehicle> vanUsageList =[];
  List<Employee> employeeRouteList =[];
  //
  // Future<Map<String, List<RouteModel>>> fetchRoutesForWeek({
  //   required String week,
  //   required String year,
  // }) async {
  //   Map<String, List<RouteModel>> weeklyRoutes = {};
  //
  //   try {
  //     QuerySnapshot routeDataSnapshot = await firestore
  //         .collection('Routes')
  //         .doc("${week}_$year")
  //         .collection('RouteData')
  //         .get();
  //
  //     for (var dateDoc in routeDataSnapshot.docs) {
  //       QuerySnapshot routeDetailsSnapshot = await dateDoc.reference
  //           .collection('RouteDetails')
  //           .get();
  //
  //       List<RouteModel> routes = routeDetailsSnapshot.docs.map((doc) {
  //         return RouteModel.fromJson(doc.data() as Map<String, dynamic>);
  //       }).toList();
  //
  //       weeklyRoutes[dateDoc.id] = routes;
  //     }
  //
  //     print("Fetched all routes for week ${week}_$year size ${weeklyRoutes.length}");
  //     return weeklyRoutes;
  //   } catch (e) {
  //     print("Error fetching routes for week: $e");
  //     return {};
  //   }
  // }


// fetch weekly route data along with available employees

Future<List<WeeklyReportModel>?> fetchRouteDetailsForWeekAndLocation({
  required String week,
  required String location,
  required String year,
}) async {

  List<WeeklyReportModel> weeklyReports = [];

  try {
    // 1. Fetch all employees with availability status
    QuerySnapshot employeeSnapshot = await firestore
        .collection('Employees')
        .get();

    // 2. Fetch route assignments for each day in the selected week
    QuerySnapshot dateSnapshots = await firestore
        .collection('Route')
        .doc("${week}_$year")
        .collection('RouteData')
        .get();

    for (var dateDoc in dateSnapshots.docs) {
      String date = dateDoc.id;

      String? notes = dateDoc['Notes'] ?? "No Notes Available";

      // Fetch route assignments for this date
      QuerySnapshot routeSnapshots = await dateDoc.reference
          .collection("Location")
          .doc(location)
          .collection('RouteDetails')
         // .where('Location', isEqualTo: location)
          .get();

      // Map route details to RouteModel
      List<RouteModel> routes = routeSnapshots.docs.map((doc) {
        return RouteModel.fromJson(doc.data() as Map<String, dynamic>,);
      }).toList();



//............sort routeList in descending order
      routes.sort((a, b) {
        DateTime parseTime(String? time) {
          if (time == null) {
            throw FormatException("Time is null");
          }
          // Use a fixed date for parsing time
          return DateTime.parse('1970-01-01T$time:00');
        }

        return parseTime(b.time).compareTo(parseTime(a.time)); // Descending order
      });


      // 3. Get available employees for this day
      int weekDay = DateTime.parse(date).weekday;

      for (var employeeDoc in employeeSnapshot.docs) {
        var availabilityDoc = await firestore
            .collection('Employees')
            .doc(employeeDoc.id)
            .collection('Availability')
            .doc("${week}_$year")
            .collection('Days')
            .doc("${weekDay}_${getDay(weekDay)}")
            .get();


        // Map<String, dynamic>? days = availabilityDoc['Days'];
        // DateTime parsedDate = DateTime.parse(date);
        // String dayName = getDay(parsedDate.weekday);

        // Check if employee is available but not allocated
        // Check if employee is available and in the selected location
        if (availabilityDoc.exists) {
          Map<String, dynamic> data = availabilityDoc.data() as Map<String, dynamic>;

          if (data['status'] == "On" && data['location'] == location && data["isAllocated"] == false) {
            routes.add(RouteModel(
              employee: employeeDoc['EmployeeName'],
              route: "-",
              vehicleName: "-",
              time: "-",
              routeType: "-",
              location: location,
              date: date,
              isAvailableOnly: true,
            ));
          }
        }
      }


  // 6. Build the WeeklyReportModel with routes and notes
      weeklyReports.add(WeeklyReportModel(
        date: date,
        notes: notes??'',
        routes: routes,
      ));
    }


    weeklyReportList = weeklyReports;


  notifyListeners();
    return weeklyReportList;
  } catch (e) {
    print("Error fetching route details: $e");
    return [];
  }
}

// fetch all employees

//
// Future<List<Employee>> fetchEmployees({
//   required String week,
//   required String year,
//   required String location,
// }) async {
//
//   try {
//     // Fetch all employees
//     QuerySnapshot employeeSnapshot = await firestore.collection('Employees').get();
//
//     List<Employee> fetchedEmployees = [];
//     for (var employeeDoc in employeeSnapshot.docs) {
//       Map<String, dynamic> employeeData = employeeDoc.data() as Map<String, dynamic>;
//
//       // Check if the location exists
//       DocumentSnapshot locationSnapshot = await firestore
//           .collection('Employees')
//           .doc(employeeDoc.id)
//           .collection('Location')
//           .doc(location)
//           .collection('Availability')
//           .doc("${week}_$year")
//           .get();
//       print("document...........${week}_$year.");
//       if (locationSnapshot.exists) {
//         // Map the availability data
//         Map<String, dynamic> weekData = locationSnapshot.data() as Map<String, dynamic>;
//         Days days = Days.fromJson(weekData['Days']);
//
//         Availability availability = Availability(
//           week: week,
//           days: days,
//           year: year,
//         );
//
//         Location locationModel = Location(
//           location: location,
//           availability: [availability],
//         );
//
//         fetchedEmployees.add(Employee(
//           employeeID: employeeDoc.id,
//           employeeName: employeeData['EmployeeName'],
//           locations: [locationModel],
//         ));
//         notifyListeners();
//       }
//     }
//
//     employeesList = fetchedEmployees;
//     notifyListeners();
//     return employeesList;
//
//   } catch (e) {
//     print("Error fetching routes for week: $e");
//     return [];
//   }
// }


// weekly van usage

  Future<List<Vehicle>?> fetchVanUsageForWeekByLocation({
    required String week,
    required String year,
    required String location,
  }) async {
    Map<String, Map<String, dynamic>> vanUsage = {};

    try {
      // Fetch all dates for the selected week
      QuerySnapshot routeDataSnapshot = await FirebaseFirestore.instance
          .collection('Route')
          .doc("${week}_$year")
          .collection('RouteData')
          .get();

      for (var dateDoc in routeDataSnapshot.docs) {
        QuerySnapshot routeDetailsSnapshot = await dateDoc.reference
            .collection("Location")
            .doc(location)
            .collection('RouteDetails')
          //  .where('Location', isEqualTo: location)
            .get();

        for (var routeDoc in routeDetailsSnapshot.docs) {
          String vanName = routeDoc['VehicleName']??'';
          String vanRegNo = routeDoc['VehicleRegNumber']??'';

          // Skip "Own" vans
          if (vanName == "Own" || vanRegNo.isEmpty) {
            continue;
          }

          // Fetch van owner from Vehicles collection
          DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance
              .collection('Vehicles')
              .doc(vanRegNo)  // Van reg no. is the document ID
              .get();

          String owner = vehicleDoc.exists
              ? vehicleDoc['Owner'] ?? 'N/A'
              : 'Unknown Owner';
          String vehicleName = vehicleDoc['VehicleName'];



          // Add to usage count
          if (vanUsage.containsKey(vehicleName)) {
            vanUsage[vehicleName]!['count'] += 1;
          } else {
            vanUsage[vehicleName] = {'count': 1, 'owner': owner};
          }
        }
      }

      // Convert Map to List of VanUsage objects
  vanUsageList = vanUsage.entries.map((entry) {
        return Vehicle(
          vehicleName: entry.key,
          usage: entry.value['count'],
          owner: entry.value['owner'],
        );
      }).toList();


      vanUsageList.sort((a, b) => b.usage!.compareTo(a.usage!)); //......................sorting with time

      print("Van Usage List (Excluding 'Own'): $vanUsageList");
      return vanUsageList;
    } catch (e) {
      print("Error fetching van usage: $e");
      return [];
    }
  }


  // count of route assignment of each employees

  Future<List<Employee>?> fetchWeeklyEmployeeRoutes({
    required String week,
    required String year,
    required String location,
  }) async {
    Map<String, Employee> reportMap = {};

    try {
      // 1. Fetch all employees (to include those with 0 routes)
      QuerySnapshot employeeSnapshot =
      await FirebaseFirestore.instance.collection('Employees').get();

      for (var empDoc in employeeSnapshot.docs) {
        Map<String, dynamic> empData = empDoc.data() as Map<String, dynamic>;
        reportMap[empDoc.id] = Employee(
          employeeName: empData['EmployeeName'],
          employeeID: empDoc.id,
          routeCount: 0,
          totalHours: Duration(),
        );
      }

      // 2. Fetch all route assignments for the selected week
      QuerySnapshot routeDataSnapshot = await FirebaseFirestore.instance
          .collection('Route')
          .doc("${week}_$year")
          .collection('RouteData')
          .get();

      // 3. Aggregate route counts by employee
      for (var dateDoc in routeDataSnapshot.docs) {
        QuerySnapshot routeDetailsSnapshot = await dateDoc.reference
            .collection("Location")
            .doc(location)
            .collection('RouteDetails')
           // .where('Location', isEqualTo: location)
            .get();

        for (var routeDoc in routeDetailsSnapshot.docs) {
          String employeeId = routeDoc['EmployeeID'] ?? '';
          String employeeName = routeDoc['EmployeeName'] ?? 'Unknown';
          String routeTime = routeDoc['Time']??"0:00";// Extract working hours


          // Convert route time to Duration
          Duration routeDuration = _parseTime(routeTime);


          if (reportMap.containsKey(employeeId)) {
            reportMap[employeeId] = Employee(
              employeeName: employeeName,
              employeeID: employeeId,
              routeCount: reportMap[employeeId]!.routeCount! + 1,
            totalHours:  reportMap[employeeId]!.totalHours! + routeDuration, // Sum hours

            );
          } else {
            reportMap[employeeId] = Employee(
              employeeName: employeeName,
              employeeID: employeeId,
              routeCount: 1,
              totalHours: routeDuration,
            );
          }
        }
      }

      // Convert the map to a list of EmployeeRouteReport
       employeeRouteList = reportMap.values.toList();
      employeeRouteList.sort((a, b) => b.totalHours!.compareTo(a.totalHours!)); //......................sorting with time


      print("Weekly Report: ${employeeRouteList.length} employees fetched.");
      return employeeRouteList;
    } catch (e) {
      print("Error fetching weekly route assignments: $e");
      return [];
    }
  }

  Duration _parseTime(String time) {
    List<String> parts = time.split(':');
    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = int.tryParse(parts[1]) ?? 0;
    return Duration(hours: hours, minutes: minutes);
  }

// get start &end date of the week

  Map<String, String> calculateWeekStartEndDate(int week, int year) {
    // Get the first Monday of the year
    DateTime jan4 = DateTime(year, 1, 4);  // Jan 4 is always in week 1
    int diff = jan4.weekday - 1; // Calculate how far from Monday
    DateTime firstMonday = jan4.subtract(Duration(days: diff));

    // Calculate the start date of the requested week
    DateTime startOfWeek = firstMonday.add(Duration(days: (week - 1) * 7));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    // Format dates
    String start = "${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}";
    String end = "${endOfWeek.year}-${endOfWeek.month.toString().padLeft(2, '0')}-${endOfWeek.day.toString().padLeft(2, '0')}";

    return {
      'start': start,
      'end': end,
    };
  }

// save to pdf

Future<bool> savePdf({required String name, required Document pdf}) async {

  try {
    // Request permission to access storage


      // Get Downloads directory
      Directory? downloadsDir = Platform.isAndroid? await getDownloadsDirectory()  : await getApplicationDocumentsDirectory();

//Directory("/storage/emulated/0/Documents")
     // String fileName = "DriversAvailability_${DateTime.now().year}.pdf";
      String savePath = "${downloadsDir?.path}/$name";

      // Save the PDF file
      final File file = File(savePath);
      await file.writeAsBytes(await pdf.save());

      print("PDF Saved....................................: $savePath");

      // Open the PDF file
      await OpenFile.open(savePath);
      return true;


  } catch (e) {
    print("Error Saving PDF..........: $e");
    return false;

  }


   // final root = Platform.isAndroid?
   //        await getExternalStorageDirectory(): await getApplicationDocumentsDirectory();
   //
   // final file = File('${root?.path}/$name');
   // await file.writeAsBytes(await pdf.save());
   // print(".............path  ${root?.path}/$name ");
   // final path = file.path;
   // await OpenFile.open(path);
   // return file;
}


  // Future<void> openPdf({required File file}) async {
  //  final path = file.path;
  //  await OpenFile.open(path);
  //
  // }
}
