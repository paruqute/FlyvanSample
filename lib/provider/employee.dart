

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:week_number/iso.dart';

import '../model/employee_model.dart';
import '../week_methods.dart';

class EmployeeProvider with ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
 List<Employee> availableEmployees = [];
  List<Employee> employeeListInDate = [];
  List<Employee> employeeList = [];


  // add new employee

  Future<bool> addEmployee(Employee employee) async {
    try {
      // Reference to the Firestore collection and document (employeeID as doc ID)
      DocumentReference employeeRef =
      firestore.collection('Employees').doc(employee.employeeID);

      // Check if the employee already exists
      DocumentSnapshot snapshot = await employeeRef.get();

      if (snapshot.exists) {
        print("Employee with ID ${employee.employeeID} already exists.");
        return false;  // Employee already exists
      }

      // Add employee if not exists
      await employeeRef.set(employee.toJson());
      print("Employee ${employee.employeeName} added successfully!");
      return true;  // Employee added successfully
    } catch (e) {
      print("Error adding employee: $e");
      return false;  // Error occurred
    }
  }

  // update employee details

  Future<bool> updateEmployee(Employee employee) async {
    try {
      DocumentReference employeeRef =
      firestore.collection('Employees').doc(employee.employeeID);

      // Update only the specified fields
      await employeeRef.update(employee.toJson());

      print("Employee ${employee.employeeName} updated successfully!");
      return true;
    } catch (e) {
      print("Error updating employee: $e");
      return false;
    }
  }


//delete employee

  Future<bool> deleteEmployee(String employeeID) async {
    try {
      DocumentReference employeeRef =
      firestore.collection('Employees').doc(employeeID);

      // Step 1: Recursively delete subcollections (Location -> Availability)
      await _deleteSubcollections(employeeRef);

      // Step 2: Now delete the employee document itself
      DocumentSnapshot snapshot = await employeeRef.get();
      if (snapshot.exists) {
        await employeeRef.delete();
        print("Employee $employeeID deleted successfully.");
      } else {
        print("Employee $employeeID already deleted.");
      }

      return true;
    } catch (e) {
      print("Error deleting employee: $e");
      return false;
    }
  }

// Recursively delete subcollections
  Future<void> _deleteSubcollections(DocumentReference parentRef) async {
    try {
      // Step 1: Query subcollections manually (e.g., Location)
      QuerySnapshot locationSnapshot = await parentRef.collection('Availability').get();

      for (QueryDocumentSnapshot locationDoc in locationSnapshot.docs) {
        // Step 2: Recursively delete Availability under Location
       await _deleteAvailability(locationDoc.reference);

        // Step 3: Delete the Location document itself
        await locationDoc.reference.delete();
        print("Deleted Availability document: ${locationDoc.reference.path}");
      }
    } catch (e) {
      print("Error deleting subcollections: $e");
    }
  }

// Delete Availability subcollection under Location
  Future<void> _deleteAvailability(DocumentReference locationRef) async {
    try {
      QuerySnapshot availabilitySnapshot =
      await locationRef.collection('Days').get();

      for (QueryDocumentSnapshot availabilityDoc in availabilitySnapshot.docs) {
        // Step 1: Delete each Availability document
        await availabilityDoc.reference.delete();
        print("Deleted Days document: ${availabilityDoc.reference.path}");
      }
    } catch (e) {
      print("Error deleting Days subcollection: $e");
    }
  }



  // fetch all employee list

  Future<List<Employee>?> fetchEmployeeList() async {
    try {
      // Fetch all employee documents
      QuerySnapshot stationSnapshot =
      await firestore.collection('Employees').orderBy('EmployeeName', descending: false).get();

      // Map Firestore documents to Employee model
      employeeList = stationSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // return Employee.fromJson(doc.data() as Map<String, dynamic>,);
        // Use the document ID as employeeID and pass to the model
        Employee employee = Employee.fromJson(data);
        employee.employeeID = doc.id;  // Assign document ID to employeeID

        return employee;
      }).toList();
      print("Employees...............................${employeeList.length}");
      notifyListeners();
      return employeeList;
    } catch (e) {
      print("Error fetching employees: $e");
      return [];
    }
  }
// fetch Available employees for a specific date


  Future<List<Employee>> fetchAvailableEmployeesInDate({
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

          if (data['status'] == "On" && data['location'] == location) {
            availableEmployees.add(Employee.fromJson(employeeDoc.data() as Map<String, dynamic>));
          }
        }
      }

      print("Available employees for $date: ${availableEmployees.length}");
      employeeListInDate = availableEmployees;
      notifyListeners();
      return employeeListInDate;
    } catch (e) {
      print("Error fetching available employees: $e");
      return [];
    }
  }



// fetch available drivers tomorrow
  Future<List<Employee>> fetchEmployeesAvailableTomorrow(
      String location,
      ) async {

    // Determine tomorrow's day
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final tomorrowDate = DateFormat('yyyy-MM-dd').format(tomorrow);
    // final tomorrowDay = getDay(tomorrow.weekday);
    final year = getYearFromWeek(tomorrow);
    final week = "${tomorrow.weekNumber}";

    try {
      List<Employee> employeesForTomorrow = [];

      QuerySnapshot employeeSnapshot = await firestore.collection('Employees').get();

      for (var employeeDoc in employeeSnapshot.docs) {
        Map<String, dynamic> employeeData = employeeDoc.data() as Map<String, dynamic>;

        DocumentSnapshot locationSnapshot = await firestore
            .collection('Employees')
            .doc(employeeDoc.id)
            .collection('Location')
            .doc(location)
            .collection('Availability')
            .doc("${week}_$year")
            .get();
        print("Firestore Path: Employees/${employeeDoc.id}/Location/$location");
        print('................$year.......$week........$tomorrowDate');

        if (locationSnapshot.exists) {
          // DocumentSnapshot weekSnapshot = await locationSnapshot.reference
          //     .collection('Availability')
          //     .doc(year.toString())
          //     .collection('Year')
          //     .doc(week)
          //     .get();


            Map<String, dynamic> weekData = locationSnapshot.data() as Map<String, dynamic>;
            //Days days = Days.fromJson(weekData['Days']);
            // Map<String, dynamic>? days = weekData['Days'];



            if (weekData['Days'] is Map<String, dynamic>) {
              Map<String, dynamic> daysData = weekData['Days'];

              // Check if tomorrow's date matches and status is "On"
              for (var day in daysData.entries) {
                if (day.value['Date'] == tomorrowDate && day.value['Status'] == "On") {
                  // Add employee to the list
                  employeesForTomorrow.add(Employee(
                    employeeID: employeeDoc.id,
                    employeeName: employeeData['EmployeeName'],
                    locations: [], // You can add locations if needed
                  ));
                  break;
                }
              }
            }
            // if (days != null && days. == "On") {
            //   print('Employee ${employeeData['EmployeeName']} is available tomorrow.');
            //   tomorrowEmployees.add(Employee(
            //     employeeID: employeeDoc.id,
            //     employeeName: employeeData['EmployeeName'],
            //   ));
            // }


        }else {
          print('Location $location not found for Employee ${employeeData['EmployeeName']}');
        }
      }
      availableEmployees = employeesForTomorrow;
      notifyListeners();
      return availableEmployees;
    } catch (e) {
      print("Error fetching employees available tomorrow: $e");
      return [];
    }
  }

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
}