import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



import '../model/employee_model.dart';
import '../model/route_model.dart';
import '../model/vehicle.dart';
import '../week_methods.dart';

class RouteProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Employee>? unAllocatedEmployeeList = [];
  List<Vehicle>? vanList = [];
  List<Vehicle>? availableVanList = [];

  List<RouteModel>? assignedRouteList = [];

  Future<void> addRoute(RouteModel routeModel) async {
    assignedRouteList?.add(routeModel);
    notifyListeners();
  }

  Future<void> clearRouteList() async {
    assignedRouteList?.clear();
    notifyListeners();
  }

// create route

  Future<void> addSingleRoute({
    required String week,
    required String date,
    required String year,
    required RouteModel route,
  }) async {
    try {
      String? notes = "Notes for $date";
      // Reference to the weekly document
      final weekDocRef = firestore.collection('Route').doc("${week}_$year");

      // Check if the week document exists
      DocumentSnapshot weekDoc = await weekDocRef.get();

      if (!weekDoc.exists) {
        // Create the parent document with a placeholder if it doesn't exist
        await weekDocRef.set({'placeholder': true});
        print("Created document ${week}_$year with placeholder.");
      }



      // Reference to the RouteData document (for each date)
      final routeDataDocRef = weekDocRef
          .collection('RouteData')
          .doc(date);

      // Check if RouteData document for the date exists
      DocumentSnapshot routeDataDoc = await routeDataDocRef.get();

      if (!routeDataDoc.exists) {
        // Add Notes if RouteData document doesn't exist
        await routeDataDocRef.set({
          'Notes': notes,
          'CreatedAt':DateTime.now()// Add notes to new RouteData documents
        });

      } else {
        // Check if Notes already exist and skip if present
        if (!routeDataDoc.data().toString().contains('Notes')) {
          await routeDataDocRef.update({'Notes': notes});
          print("Updated Notes for $date: $notes");
        } else {
          print("Notes already exist for $date, skipping update.");
        }
      }

      // Proceed to add the route under RouteDetails subcollection
      final routeDocRef = routeDataDocRef
          .collection("Location")
          .doc(route.location)
          .collection('RouteDetails')
          .doc("${route.route}");
      //
      // // Proceed to add route under RouteData subcollection
      // final routeDocRef = weekDocRef
      //     .collection('RouteData')
      //     .doc(date)
      //     .collection('RouteDetails')
      //     .doc(route.route);

      await routeDocRef.set(route.toJson());
      // Update availability as allocated
      await updateEmployeeAvailability(
        isAllocated: true,
        employeeId: route.employeeId ?? '',
        location: route.location ?? '',
        date: route.date ?? '',
        week: route.week ?? '',
      );
// update vans availability is allocated to true
//       if (route.vehicleRegNum != null) {
//         await updateVanAvailability(
//             isAllocated: true, vanRegNo: route.vehicleRegNum ?? '',date: route.date??'');
//       }

      print("Route added successfully!");
    } catch (e) {
      print("Error adding route: $e");
    }
  }

// delete single route
  Future<void> deleteSingleRoute({
    required String week,
    required String date,
    required String year,
    required RouteModel route, // Document ID of the route
  }) async {
    try {
      // Reference to the specific route document in RouteDetails subcollection
      await firestore
          .collection('Route')
          .doc("${week}_$year")
          .collection('RouteData')
          .doc(date)
          .collection("Location")
          .doc(route.location)
          .collection('RouteDetails')
          .doc("${route.route}") // Route ID
          .delete();

      // update the employee availability isAllocated is  to false
      await updateEmployeeAvailability(
        isAllocated: false,
        employeeId: route.employeeId ?? '',
        location: route.location ?? '',
        date: route.date ?? '',
        week: route.week ?? '',
      );
      //update vans availability isAllocated to false
      // if (route.vehicleRegNum != null) {
      //   await updateVanAvailability(
      //       isAllocated: false,vanRegNo: route.vehicleRegNum ?? '',date: route.date??'');
      // }
       await fetchAvailableVan();
       await fetchUnallocatedEmployees(
          location: route.location ?? '',
          date: route.date ?? '',
          year: route.year??'',
          week: route.week??'',);
        await fetchRoutesByDate(
          year: year,
          week: route.week ?? '',
          location: route.location ?? '',
          date: route.date ?? '');
      notifyListeners();
      print("Route with ID ${route.route} deleted successfully!");
    } catch (e) {
      print("Error deleting route: $e");
      rethrow;
    }
  }

  // add notes

  Future<void> addOrUpdateNotes({
    required String week,
    required String date,
    required String notes,
    required String year,
  }) async {
    try {
      // Reference to the specific date document
      final dateDocRef = firestore
          .collection('Route')
          .doc("${week}_$year")
          .collection('RouteData')
          .doc(date);

      // Add or update the Notes field
      await dateDocRef.set({
        'Notes': notes,
        'UpdatedAt':DateTime.now(),
      }, SetOptions(merge: true)); // Merge with existing data

      print("Notes added/updated successfully!");
    } catch (e) {
      print("Error adding/updating notes: $e");
    }
  }

  /// fetch notes
  Future<String?> fetchNotesForDate({
    required String week,
    required String date,
    required String year,
  }) async {
    try {
      // Reference to the specific date document
      final dateDocRef = firestore
          .collection('Route')
          .doc("${week}_$year")
          .collection('RouteData')
          .doc(date);

      // Get the document snapshot
      final snapshot = await dateDocRef.get();

      if (snapshot.exists) {
        return snapshot.data()?['Notes'] as String?; // Fetch the Notes field
      } else {
        print("No notes found for this date.");
        return null;
      }
    } catch (e) {
      print("Error fetching notes: $e");
      return null;
    }
  }

  // // query the Routes collection to get routes by location, date, or week.
  //
  // Future<List<RouteModel>> fetchRoutesByDate(String location, String date) async {
  //
  //   try {
  //     QuerySnapshot snapshot = await firestore
  //         .collection('Routes')
  //         .where('Location', isEqualTo: location)
  //         .where('Date', isEqualTo: date)
  //         .get();
  //
  //     return snapshot.docs
  //         .map((doc) => RouteModel.fromJson(doc.data() as Map<String, dynamic>))
  //         .toList();
  //   } catch (e) {
  //     print("Error fetching routes by date: $e");
  //     return [];
  //   }
  // }

// save list of routes
  Future<void> saveAllRoutes(
      String week, String date, List<RouteModel>? routes) async {
    final WriteBatch batch = firestore.batch();

    try {
      // Reference to the week and date
      final weekRef = firestore.collection('Route').doc(week);
      final dateRef = weekRef.collection('RouteData').doc(date);

      // Ensure the week document exists
      final weekDoc = await weekRef.get();
      if (!weekDoc.exists) {
        batch.set(weekRef, {
          'Week': week, // Metadata for the week, if necessary
        });
      }

      // Ensure the date document exists
      final dateDoc = await dateRef.get();
      if (!dateDoc.exists) {
        batch.set(dateRef, {
          'Date': date, // Metadata for the date, if necessary
        });
      }

      // Add all routes to the RouteDetails subcollection
      for (RouteModel route in routes!) {
        final routeRef = dateRef.collection('RouteDetails').doc(route.route);
        batch.set(routeRef, route.toJson()); // Add the route data
        // Update availability as allocated
        await updateEmployeeAvailability(
          isAllocated: true,
          employeeId: route.employeeId ?? '',
          location: route.location ?? '',
          date: route.date ?? '',
          week: route.week ?? '',

        );
      }

      // Commit the batch
      await batch.commit();

      print("All routes saved successfully!");
    } catch (e) {
      print("Error saving routes: $e");
    }
  }

  // fetch routes of a date

  Future<List<RouteModel>?> fetchRoutesByDate({
    required String week,
    required String date,
    required String location,
    required String year,
  }) async {
    List<RouteModel> routes = [];

    try {
      // Reference to the RouteDetails subcollection for the selected date
      QuerySnapshot snapshot = await firestore
          .collection('Route')
          .doc("${week}_$year")
          .collection('RouteData')
          .doc(date)
          .collection("Location")
          .doc(location)
          .collection('RouteDetails')
          // .where('Location', isEqualTo: location) // Filter by location
          .get();

      // Map the query results into a list of route data
      routes = snapshot.docs.map((doc) {
        return RouteModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      assignedRouteList = routes;
      notifyListeners();
      print("Routes for $date: ${routes.length}");
      return assignedRouteList;
    } catch (e) {
      print("Error fetching routes for date $date: $e");
      return [];
    }
  }

  // update employees is allocated
  // Future<void> updateEmployeeAvailability({
  //   required String employeeId,
  //   required String location,
  //   required String date,
  //   required String week,
  //   required String day,
  //   required bool isAllocated,
  // }) async {
  //   try {
  //     // Reference to the specific availability document
  //     final availabilityDoc = firestore
  //         .collection('Employees')
  //         .doc(employeeId)
  //         .collection('Location')
  //         .doc(location)
  //         .collection('Availability')
  //         .doc("${week}_${getYearFromWeek(DateTime.parse(date))}");
  //
  //     // Update only the 'IsAllocated' field for the specific day using dot notation
  //     await availabilityDoc.update({
  //       'Days.$day.IsAllocated': isAllocated,
  //     });
  //
  //     //SetOptions(merge: true),
  //     // Merge with existing data
  //
  //     print("Availability updated successfully!");
  //   } catch (e) {
  //     print("Error updating availability: $e");
  //   }
  // }


  Future<void> updateEmployeeAvailability({
    required String employeeId,
    required String location,
    required String date,
    required String week,
    required bool isAllocated,
  }) async {
    try {
      // Reference to the specific availability document
      int weekDay = DateTime.parse(date).weekday;
      
      final availabilityDoc = firestore
          .collection('Employees')
          .doc(employeeId)
          .collection('Availability')
          .doc("${week}_${getYearFromWeek(DateTime.parse(date))}")
          .collection('Days').doc("${weekDay}_${getDay(weekDay)}");

      // Update only the 'IsAllocated' field for the specific day using dot notation
      await availabilityDoc.update({
        'isAllocated': isAllocated,
      });

      //SetOptions(merge: true),
      // Merge with existing data

      print("Availability updated successfully!");
    } catch (e) {
      print("Error updating availability: $e");
    }
  }

  // fetch available employees for the selected date and location

  Future<List<Employee>?> fetchUnallocatedEmployees({
    required String week,
    required String year,
    required String date,
    required String location,
  }) async {

    List<Employee> availableEmployees = [];

    try {
      // Fetch all employees
      QuerySnapshot employeeSnapshot =
      await firestore.collection('Employees').get();

      //find weekday of the date
      int weekDay = DateTime.parse(date).weekday;

      for (var employeeDoc in employeeSnapshot.docs) {
        // Reference to the specific day under Availability
        DocumentSnapshot daySnapshot = await firestore
            .collection('Employees')
            .doc(employeeDoc.id)
            .collection('Availability')
            .doc("${week}_$year")
            .collection('Days')
            .doc("${weekDay}_${getDay(weekDay)}")
            .get();

        // Check if employee is available and in the selected location
        if (daySnapshot.exists) {
          Map<String, dynamic> data = daySnapshot.data() as Map<String, dynamic>;

          if (data['status'] == "On" && data['location'] == location && data['isAllocated'] == false) {
            availableEmployees.add(Employee.fromJson(employeeDoc.data() as Map<String, dynamic>));
          }
        }
      }

      print("unAllocated available employees for $date: ${availableEmployees.length}");
      unAllocatedEmployeeList = availableEmployees;
      notifyListeners();
      return unAllocatedEmployeeList;
    } catch (e) {
      print("Error fetching unallocated available employees: $e");
      return [];
    }
  }




  // Future<List<Employee>?> fetchAvailableEmployees(
  //     {String? location,
  //     String? date,
  //     String? day,
  //     String? week,
  //     String? year}) async {
  //   List<Employee> unallocatedEmployees = [];
  //
  //   try {
  //     QuerySnapshot employeeSnapshot =
  //         await firestore.collection('Employees').get();
  //
  //     for (var employeeDoc in employeeSnapshot.docs) {
  //       final employeeId = employeeDoc.id;
  //       Map<String, dynamic> employeeData =
  //           employeeDoc.data() as Map<String, dynamic>;
  //
  //       // Fetch availability for the day
  //       DocumentSnapshot availabilityDoc = await firestore
  //           .collection('Employees')
  //           .doc(employeeId)
  //           .collection('Location')
  //           .doc(location)
  //           .collection('Availability')
  //           .doc("${week}_$year")
  //           .get();
  //
  //       if (availabilityDoc.exists) {
  //         Map<String, dynamic> weekData =
  //             availabilityDoc.data() as Map<String, dynamic>;
  //         //Days days = Days.fromJson(weekData['Days']);
  //         // Map<String, dynamic>? days = weekData['Days'];
  //         print(".............days ${weekData.length}");
  //
  //         if (weekData['Days'] is Map<String, dynamic>) {
  //           Map<String, dynamic> daysData = weekData['Days'];
  //
  //           // Check if tomorrow's date matches and status is "On"
  //           for (var day in daysData.entries) {
  //             if (day.value['Date'] == date &&
  //                 day.value["IsAllocated"] == false &&
  //                 day.value['Status'] == "On") {
  //               // Add employee to the list
  //               print("....................${day.value['IsAllocated']}");
  //               unallocatedEmployees.add(Employee(
  //                 employeeID: employeeDoc.id.toString(),
  //                 employeeName: employeeData['EmployeeName'],
  //                 // You can add locations if needed
  //               ));
  //             }
  //           }
  //         }
  //       } else {
  //         print("availability not exist");
  //       }
  //     }
  //     availableEmployees = unallocatedEmployees;
  //     notifyListeners();
  //     return availableEmployees;
  //   } catch (e) {
  //     print("Error fetching unallocated employees: $e");
  //     return [];
  //   }
  // }

  // fetch van list
  Future<List<Vehicle>?> fetchVans() async {
    try {
      List<Vehicle>? vanNames = [];
      QuerySnapshot querySnapshot =
          await firestore.collection('Vehicles').get();
      vanNames = querySnapshot.docs.map((doc) {
        return Vehicle.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      vanList = vanNames;
      notifyListeners();
      return vanList;
    } catch (e) {
      print("Error fetching vans: $e");
      return [];
    }
  }

  // update van availability for the date

  Future<void> updateVanAvailability({
    required String vanRegNo,
    required String date, // Date of assignment
    required bool isAllocated,
  }) async {
    try {
      // Reference to van assignments for the specific date
      final availabilityDoc = firestore
          .collection('Vans')
          .doc(vanRegNo)
          .collection('Assignments')
          .doc(date); // Use date as doc ID

      await availabilityDoc.set({
        'isAllocated': isAllocated,
      }, SetOptions(merge: true));

      print("Van $vanRegNo availability updated for $date.");
    } catch (e) {
      print("Error updating van availability: $e");
    }
  }

  // Future<void> updateVanAvailability({
  //   required String regNumber,
  //   required bool isAllocated,
  // }) async {
  //   try {
  //     final availabilityDoc = firestore.collection('Vehicles').doc(regNumber);
  //
  //     await availabilityDoc.update({
  //       'IsAvailable': isAllocated, // Unassign employee
  //     });
  //
  //     print("Van availability updated to $isAllocated successfully!");
  //   } catch (e) {
  //     print("Error  updating van availability to $isAllocated  : $e");
  //   }
  // }

  // fetch available vans
  Future<List<Vehicle>?> fetchAvailableVan() async {
    List<Employee> unallocatedEmployees = [];

    try {
      List<Vehicle>? vanNames = [];
      QuerySnapshot querySnapshot = await firestore
          .collection('Vehicles')
         // .where('IsAvailable', isEqualTo: false)
          .get();
      vanNames = querySnapshot.docs.map((doc) {
        return Vehicle.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      availableVanList = vanNames;
      notifyListeners();
      print("............available van ${availableVanList?.length}");
      return availableVanList;
    } catch (e) {
      print("Error fetching unallocated employees: $e");
      return [];
    }
  }

// fetch van availability for the date

  // Future<List<Vehicle>> fetchAvailableVan({required String date}) async {
  //   List<Vehicle> availableVans = [];
  //
  //   try {
  //     QuerySnapshot vansSnapshot = await firestore.collection('Vehicles').get();
  //
  //     for (var vanDoc in vansSnapshot.docs) {
  //       // Check for van assignment on the specific date
  //       DocumentSnapshot assignmentSnapshot = await firestore
  //           .collection('Vehicles')
  //           .doc(vanDoc.id)
  //           .collection('Assignments')
  //           .doc(date)
  //           .get();
  //
  //       // If not allocated or no entry, consider the van available
  //       if (!assignmentSnapshot.exists ||
  //           !(assignmentSnapshot['isAllocated'] ?? false)) {
  //         availableVans.add(Vehicle.fromJson(vanDoc.data() as Map<String, dynamic>));
  //       }
  //     }
  //
  //     print("Fetched available vans for $date: ${availableVans.length}");
  //     return availableVans;
  //   } catch (e) {
  //     print("Error fetching available vans: $e");
  //     return [];
  //   }
  // }

//
// Future<void> addRoute( String location, RouteModel route) async {
//
//
//   try {
//     // Reference the Routes subcollection
//     DocumentReference routeRef = firestore
//         .collection('Routes')
//         .doc(route.date);
//
//     // Save the route using the RouteModel's toJson() method
//     await routeRef.set(route.toJson());
//     print("Route added successfully!");
//   } catch (e) {
//     print("Error adding route: $e");
//   }
// }
//
// ///fetch routes
//
// Future<List<RouteModel>> fetchRoutes(String employeeId, String location) async {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   try {
//     // Query the Routes subcollection for the given location
//     QuerySnapshot routeSnapshot = await firestore
//         .collection('Employees')
//         .doc(employeeId)
//         .collection('Location')
//         .doc(location)
//         .collection('Routes')
//         .get();
//
//     // Convert each document into a RouteModel
//     List<RouteModel> routes = routeSnapshot.docs.map((doc) {
//       return RouteModel.fromJson(doc.data() as Map<String, dynamic>);
//     }).toList();
//
//     return routes;
//   } catch (e) {
//     print("Error fetching routes: $e");
//     return [];
//   }
// }

//
// /// Fetch employees available for today's allocation
// Future<void> fetchAvailableEmployees() async {
//   try {
//     final now = DateTime.now();
//     final dayName = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][now.weekday - 1];
//     final date = now.toIso8601String().split('T')[0]; // e.g., 2023-12-11
//     final year = now.year.toString();
//     final week = "week${getWeekNumber(now)}";
//
//     QuerySnapshot employeeSnapshot = await firestore.collection('Employees').get();
//
//     List<Map<String, dynamic>> fetchedEmployees = [];
//
//     for (var employeeDoc in employeeSnapshot.docs) {
//       final employeeId = employeeDoc.id;
//       final employeeData = employeeDoc.data() as Map<String, dynamic>;
//
//       final availabilityDoc = await firestore
//           .collection('Employees')
//           .doc(employeeId)
//           .collection('Location')
//           .doc(widget.location)
//           .collection('Availability')
//           .doc(year)
//           .collection('Year')
//           .doc(week)
//           .get();
//
//       if (availabilityDoc.exists) {
//         final days = availabilityDoc['Days'] as Map<String, dynamic>;
//
//         if (days[dayName]['status'] == "On" && days[dayName]['allocated'] == false) {
//           fetchedEmployees.add({
//             'employeeId': employeeId,
//             'employeeName': employeeData['employeeName'],
//             'dayName': dayName,
//             'date': date,
//             'availabilityRef': availabilityDoc.reference,
//           });
//         }
//       }
//     }
//
//     setState(() {
//       availableEmployees = fetchedEmployees;
//       isLoading = false;
//     });
//   } catch (e) {
//     print("Error fetching available employees: $e");
//     setState(() {
//       isLoading = false;
//     });
//   }
// }
//
// /// Allocate a route to an employee and update Firestore
// Future<void> allocateRoute(String employeeId, String route, String van, String dayName, String date, DocumentReference availabilityRef) async {
//   try {
//     await firestore.runTransaction((transaction) async {
//       // Add route to the Routes subcollection
//       final routeRef = firestore
//           .collection('Employees')
//           .doc(employeeId)
//           .collection('Location')
//           .doc(widget.location)
//           .collection('Routes')
//           .doc(date);
//
//       transaction.set(routeRef, {
//         'date': date,
//         'route': route,
//         'van': van,
//       });
//
//       // Update the allocated status in the Availability subcollection
//       transaction.set(
//         availabilityRef,
//         {
//           'Days.$dayName.allocated': true,
//         },
//         SetOptions(merge: true),
//       );
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Route allocated successfully!")));
//     fetchAvailableEmployees(); // Refresh the employee list
//   } catch (e) {
//     print("Error allocating route: $e");
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error allocating route: $e")));
//   }
// }
}
