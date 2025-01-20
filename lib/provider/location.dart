import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/Day_model.dart';
import '../model/employee_model.dart';
import '../model/station_model.dart';
import '../week_methods.dart';

class LocationProvider with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, int> dayCounts = {
    'Monday': 0,
    'Tuesday': 0,
    'Wednesday': 0,
    'Thursday': 0,
    'Friday': 0,
    'Saturday': 0,
    'Sunday': 0,
  };
  List<Employee> employee = [];
  List<Employee> employees = [];
  List<Employee> employeeFetch = [];
  List<DayAvailability> dayAvailabilityList = [];
  List<Station> stationList=[];
  bool isEmployeeLoading = false;
  // Getter to access employees list
  List<Employee> get getEmployees => employee;

  // Station.convertToList(data['StationName'])
  // fetching stations

  Future<List<Station>> fetchStations() async {
    try {
      // Fetch all employee documents
      QuerySnapshot stationSnapshot =
      await firestore.collection('Stations').get();

      // Map Firestore documents to Employee model
      stationList = stationSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Station(
        //  employeeID: doc.id,
          name: data['StationName'],
        );
      }).toList();
      print("Stations...............................${stationList.length}");
      notifyListeners();
      return stationList;
    } catch (e) {
      print("Error fetching stations: $e");
      return [];
    }
  }




//Fetch all locations and disable toggle if the employee is already "On" elsewhere.
  Future<bool> checkDayConflict({
    required String employeeId,
    required String week,
    required String year,
    required String day,
  }) async {
    final employeeRef = firestore.collection('Employees').doc(employeeId);
    final locationsSnapshot = await employeeRef.collection('Location').get();

    for (var locationDoc in locationsSnapshot.docs) {
      final availabilitySnapshot = await locationDoc.reference
          .collection('Availability')
          .doc("${week}_$year")
          .get();

      Map<String, dynamic>? days = availabilitySnapshot['Days'];

      if (days != null &&
          days[day] != null &&
          days[day]['Status'] == 'On') {
        return true; // Conflict found
      }
    }
    return false; // No conflict
  }


  //Fetch employee names and their availability for a selected location, year, and week.
  // Future<List<Employee>> fetchEmployeesWithAvailability(
  //     String location, String year, String week) async {
  //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //
  //   try {
  //     // Fetch all employees
  //     QuerySnapshot employeeSnapshot = await _firestore.collection('Employees').get();
  //
  //     List<Employee> employees = [];
  //
  //     for (var employeeDoc in employeeSnapshot.docs) {
  //       Map<String, dynamic> employeeData = employeeDoc.data() as Map<String, dynamic>;
  //
  //       // Fetch the location document
  //       DocumentSnapshot locationSnapshot = await _firestore
  //           .collection('Employees')
  //           .doc(employeeDoc.id)
  //           .collection('Location')
  //           .doc(location)
  //           .get();
  //
  //       if (locationSnapshot.exists) {
  //         // Fetch the week availability
  //         DocumentSnapshot weekSnapshot = await locationSnapshot.reference
  //             .collection('Availability')
  //             .doc(year)
  //             .collection("Year")
  //             .doc(week)
  //             .get();
  //
  //         if (weekSnapshot.exists) {
  //           Map<String, dynamic> weekData = weekSnapshot.data() as Map<String, dynamic>;
  //           Days days = Days.fromJson(weekData['Days']);
  //
  //           Availability availability = Availability(
  //             week: weekData['week'],
  //             days: days,
  //           );
  //
  //           Location locationModel = Location(
  //             location: location,
  //             availability: [availability],
  //           );
  //
  //           employees.add(Employee(
  //             employeeID: employeeDoc.id,
  //             employeeName: employeeData['EmployeeName'],
  //             locations: [locationModel],
  //           ));
  //         }
  //       }
  //     }
  //     employeeFetch = employees;
  //     notifyListeners();
  //     return employeeFetch;
  //   } catch (e) {
  //     print("Error fetching employees: $e");
  //     return [];
  //   }
  // }

  // Future<List<Employee>> fetchEmployeesWithDefaultAvailability(
  // {required String location, required String year, required String week}) async {
  //
  //   try {
  //     // Fetch all employees
  //     QuerySnapshot employeeSnapshot = await firestore.collection('Employees').get();
  //
  //     List<Employee> fetchedEmployees = [];
  //
  //     for (var employeeDoc in employeeSnapshot.docs) {
  //       Map<String, dynamic> employeeData = employeeDoc.data() as Map<String, dynamic>;
  //
  //       // Default availability (if no data exists)
  //       Days defaultDays = Days(
  //         monday: "Off",
  //         tuesday: "Off",
  //         wednesday: "Off",
  //         thursday: "Off",
  //         friday: "Off",
  //         saturday: "Off",
  //         sunday: "Off",
  //       );
  //
  //       // Check if the location exists
  //       DocumentSnapshot locationSnapshot = await firestore
  //           .collection('Employees')
  //           .doc(employeeDoc.id)
  //           .collection('Location')
  //           .doc(location)
  //           .collection('Availability')
  //           .doc(year)
  //           .collection('Year')
  //           .doc(week)
  //           .get();
  //       print("Firestore Path: Employees/${employeeDoc.id}/Location/$location ....${locationSnapshot.id}");
  //       if (locationSnapshot.exists) {
  //         // Check if the year and week exist
  //         // DocumentSnapshot weekSnapshot = await locationSnapshot.reference
  //         //     .collection('Availability')
  //         //     .doc(year)
  //         //     .collection('Year')
  //         //     .doc(week)
  //         //     .get();
  //
  //
  //           // Map the availability data
  //           Map<String, dynamic> weekData = locationSnapshot.data() as Map<String, dynamic>;
  //           Days days = Days.fromJson(weekData['Days']);
  //
  //           Availability availability = Availability(
  //             week: week,
  //             days: days,
  //           );
  //
  //           Location locationModel = Location(
  //             location: location,
  //             availability: [availability],
  //           );
  //
  //           fetchedEmployees.add(Employee(
  //             employeeID: employeeDoc.id,
  //             employeeName: employeeData['EmployeeName'],
  //             locations: [locationModel],
  //           ),);
  //           notifyListeners();
  //
  //       } else {
  //         // Add default location and availability if the location doesn't exist
  //         Availability defaultAvailability = Availability(
  //           week: week,
  //           days: defaultDays,
  //         );
  //
  //         Location defaultLocation = Location(
  //           location: location,
  //           availability: [defaultAvailability],
  //         );
  //
  //         fetchedEmployees.add(Employee(
  //           employeeID: employeeDoc.id,
  //           employeeName: employeeData['EmployeeName'],
  //           locations: [defaultLocation],
  //         ));
  //       }
  //     }
  //     employeeFetch = fetchedEmployees;
  //     notifyListeners();
  //     return employeeFetch;
  //   } catch (e) {
  //     print("Error fetching employees with default availability: $e");
  //     return [];
  //   }
  // }

///here fetch employees with dates

  Future<List<Employee>> fetchEmployeesWithDefaultAvailability(
      {required String location, required String year, required String week}) async {

    isEmployeeLoading = true;
    notifyListeners();
    try {
      // Fetch all employees
      QuerySnapshot employeeSnapshot = await firestore.collection('Employees').get();

      List<Employee> fetchedEmployees = [];

      // Calculate the current week's Monday as the base date
      DateTime now = DateTime.now();
      int currentWeekday = now.weekday; // Monday = 1, Sunday = 7
      DateTime mondayOfWeek = now.subtract(Duration(days: currentWeekday - 1));

      // Generate default days with current week's dates
      Map<String, dynamic> generateDefaultDays() {
        List<String> daysOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
        Map<String, dynamic> defaultDays = {};
        for (int i = 0; i < daysOrder.length; i++) {
          DateTime currentDay = mondayOfWeek.add(Duration(days: i));
          String formattedDate = DateFormat('yyyy-MM-dd').format(currentDay);
          defaultDays[daysOrder[i]] = {"Status": "Off", "Date": formattedDate,"IsAllocated":false};
        }
        return defaultDays;
      }

      Map<String, dynamic> defaultDaysJson = generateDefaultDays();

      for (var employeeDoc in employeeSnapshot.docs) {
        Map<String, dynamic> employeeData = employeeDoc.data() as Map<String, dynamic>;

        // refference to the location document
        DocumentReference locationRef =  firestore
            .collection('Employees')
            .doc(employeeDoc.id)
            .collection('Location')
            .doc(location);

        // Step 1: Ensure the Location document exists with a placeholder field
        DocumentSnapshot locationSnapshot = await locationRef.get();
        if (!locationSnapshot.exists) {
          await locationRef.set({
            'Location': location,
          }); // Adds the placeholder field if Location does not exist
          print("Added placeholder field to Location: $location");
        }



        // Step 2: Check for Availability under Location
        DocumentSnapshot availabilitySnapshot = await locationRef
            .collection('Availability')
            .doc("${week}_$year")
            .get();



         print("document...........${week}_$year.");
        if (availabilitySnapshot.exists) {
          // Map the availability data
          Map<String, dynamic> weekData = availabilitySnapshot.data() as Map<String, dynamic>;
          Days days = Days.fromJson(weekData['Days']);

          Availability availability = Availability(
            week: week,
            days: days,
            year: year,
          );

          Location locationModel = Location(
            location: location,
            availability: [availability],
          );

          fetchedEmployees.add(Employee(
            employeeID: employeeDoc.id,
            employeeName: employeeData['EmployeeName'],
            locations: [locationModel],
          ));
          notifyListeners();
        } else {
          // Add default location and availability if the location doesn't exist
          Days defaultDays = Days.fromJson(defaultDaysJson);

          Availability defaultAvailability = Availability(
            week: week,
            days: defaultDays,
          );

          Location defaultLocation = Location(
            location: location,
            availability: [defaultAvailability],
          );

          fetchedEmployees.add(Employee(
            employeeID: employeeDoc.id,
            employeeName: employeeData['EmployeeName'],
            locations: [defaultLocation],
          ));
        }
      }

      employeeFetch = fetchedEmployees;
      notifyListeners();
      return employeeFetch;
    } catch (e) {
      print("Error fetching employees with default availability: $e");
      return [];
    }finally{
      isEmployeeLoading = false;
      notifyListeners();
    }
  }


  /// testing fetch employee availability
  ///

  //
  // Future<List<Employee>> fetchEmployeesWithAvailability({
  //   required String week,
  //   required String year,
  //   required String location,
  // }) async {
  //   List<Employee> employeeList = [];
  //   final List<String> daysOfWeek = [
  //     "Monday",
  //     "Tuesday",
  //     "Wednesday",
  //     "Thursday",
  //     "Friday",
  //     "Saturday",
  //     "Sunday"
  //   ];
  //
  //   try {
  //     // Fetch all employees
  //     QuerySnapshot employeeSnapshot =
  //     await firestore.collection('Employees').get();
  //
  //     for (var employeeDoc in employeeSnapshot.docs) {
  //       Employee employee = Employee.fromJson(
  //         employeeDoc.data() as Map<String, dynamic>,
  //       );
  //
  //       // Fetch availability for the selected week
  //       DocumentReference availabilityRef = firestore
  //           .collection('Employees')
  //           .doc(employee.employeeID)
  //           .collection('Availability')
  //           .doc("${week}_$year");
  //
  //       QuerySnapshot daysSnapshot =
  //       await availabilityRef.collection('Days').get();
  //
  //       if (daysSnapshot.docs.isEmpty) {
  //         // No availability data exists – create default
  //         List<DayAvailability> defaultAvailability = daysOfWeek.map((day) {
  //           DateTime today = DateTime.now();
  //           int dayIndex = daysOfWeek.indexOf(day);
  //           String formattedDate = today
  //               .add(Duration(days: dayIndex - today.weekday + 1))
  //               .toIso8601String()
  //               .split("T")[0];
  //
  //           DayAvailability newDay = DayAvailability(
  //             day: day,
  //             date: formattedDate,
  //             status: "Off",
  //             location: null,
  //             isAllocated: false,
  //
  //           );
  //
  //           // Add each day to Firestore
  //           availabilityRef.collection('Days').doc(day).set(newDay.toJson());
  //
  //           return newDay;
  //         }).toList();
  //
  //         employee.availability = defaultAvailability;
  //       } else {
  //         // Map existing availability from Firestore
  //         employee.availability = daysSnapshot.docs.map((dayDoc) {
  //           return DayAvailability.fromJson(
  //               dayDoc.data() as Map<String, dynamic>);
  //         }).toList();
  //       }
  //
  //       employeeList.add(employee);
  //     }
  //   } catch (e) {
  //     print("Error fetching employees: $e");
  //   }
  //
  //   return employeeList;
  // }

// fetching employees with their availability to schedule

  Future<List<Employee>> fetchEmployeesWithAvailability({
    required String week,
    required String year,
    required String location,
  }) async {
    isEmployeeLoading = true;
    notifyListeners();

    List<Employee> employeeList = [];
    final List<String> daysOfWeek = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    final Map<String, String> dayPrefixes = {
      "Monday": "1",
      "Tuesday": "2",
      "Wednesday": "3",
      "Thursday": "4",
      "Friday": "5",
      "Saturday": "6",
      "Sunday": "7"
    };

    try {

      // Clear the list at the beginning to avoid duplication
      employeeList.clear();
      employeeFetch.clear();
      // Fetch all employees
      QuerySnapshot employeeSnapshot =
      await firestore.collection('Employees')
          .orderBy('EmployeeName', descending: false)  // Sort alphabetically (A-Z)
          .get();

      for (var employeeDoc in employeeSnapshot.docs) {
        Employee employee = Employee.fromJson(
          employeeDoc.data() as Map<String, dynamic>,
         // employeeDoc.id,
        );

        // Reference to Availability
        DocumentReference availabilityRef = firestore
            .collection('Employees')
            .doc(employee.employeeID)
            .collection('Availability')
            .doc("${week}_$year");

        // Check if Availability exists
        DocumentSnapshot availabilitySnapshot = await availabilityRef.get();

        if (!availabilitySnapshot.exists) {
          // Create Availability Document with year and week
          await availabilityRef.set({
            'year': year,
            'week': week,
          });

          // Create Default Days Subcollection
          // Generate dates for the target week
          List<DateTime> weekDates = getDaysOfWeek(int.parse(year),int.parse(week));

          List<DayAvailability> defaultAvailability = daysOfWeek.map((day) {
            String docId = "${dayPrefixes[day]}_$day";
            DateTime today = DateTime.now();
            int dayIndex = daysOfWeek.indexOf(day);
            String formattedDate = today
                .add(Duration(days: dayIndex - today.weekday + 1))
                .toIso8601String()
                .split("T")[0];

            DayAvailability newDay = DayAvailability(
              day: day,
              date:  DateFormat('yyyy-MM-dd').format(weekDates[dayIndex]),
              status: "Off",
              location: null,
              isAllocated: false,

            );

            // Add each day to Firestore
            availabilityRef.collection('Days').doc(docId).set(newDay.toJson());

            return newDay;
          }).toList();

          // Assign default availability to employee
          employee.availability = defaultAvailability;
          dayAvailabilityList = employee.availability!;
          employeeList.add(employee);
          //employeeFetch = employeeList;
        }

        else {
          // If availability exists, fetch days
          QuerySnapshot daysSnapshot =
          await availabilityRef.collection('Days').get();

          employee.availability = daysSnapshot.docs.map((dayDoc) {
            return DayAvailability.fromJson(
                dayDoc.data() as Map<String, dynamic>);
          }).toList();

          dayAvailabilityList = employee.availability!;
          employeeList.add(employee);
        }

      }
      print("........................................... fetching employees");
      employeeFetch = employeeList;
      notifyListeners();
      return employeeList;
    } catch (e) {
      print("Error fetching employees: $e");
      return [];
    }finally{
      isEmployeeLoading = false;
      notifyListeners();
    }


  }



  // update availability

  // Future<void> saveAvailabilityToFirestore(String location, String year, String week) async {
  //
  //
  //   try {
  //     for (var employee in employeeFetch) {
  //       // Get the days object
  //       Days days = employee.locations![0].availability![0].days!;
  //
  //       // Save the updated availability to Firestore
  //       DocumentReference weekRef = firestore
  //           .collection('Employees')
  //           .doc(employee.employeeID)
  //           .collection('Location')
  //           .doc(location)
  //           .collection('Availability')
  //           .doc(year)
  //           .collection("Year")
  //           .doc(week);
  //
  //       await weekRef.set({
  //         'Week': week,
  //         'Year':year,
  //         'Days': days.toJson(),
  //       });
  //     }
  //
  //
  //   } catch (e) {
  //     print("Error saving availability: $e");
  //
  //   }
  // }



  // Future<void> saveAvailabilityToFirestore(String location, String year, String week) async {
  //   try {
  //     // Calculate the current week's Monday as the base date
  //     DateTime now = DateTime.now();
  //     int currentWeekday = now.weekday; // Monday = 1, Sunday = 7
  //     DateTime mondayOfWeek = now.subtract(Duration(days: currentWeekday - 1));
  //
  //     // Generate dates for the week
  //     List<String> daysOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  //
  //
  //     Map<String, String> generateDates() {
  //       Map<String, String> dates = {};
  //       for (int i = 0; i < daysOrder.length; i++) {
  //         DateTime currentDay = mondayOfWeek.add(Duration(days: i));
  //         dates[daysOrder[i]] = DateFormat('yyyy-MM-dd').format(currentDay);
  //       }
  //       return dates;
  //     }
  //
  //     Map<String, String> weekDates = generateDates();
  //
  //     for (var employee in employeeFetch) {
  //       // Get the days object
  //       Days days = employee.locations![0].availability![0].days!;
  //
  //       // Update each day's date in the Days object
  //       Map<String, dynamic> updatedDaysJson = days.toJson();
  //
  //       updatedDaysJson.forEach((day, value) {
  //         if (weekDates.containsKey(day)) {
  //           value['Date'] = weekDates[day];// Update the date for each day
  //           value['IsAllocated']=false;
  //         }
  //       });
  //
  //       // Save the updated availability to Firestore
  //       DocumentReference weekRef = firestore
  //           .collection('Employees')
  //           .doc(employee.employeeID)
  //           .collection('Location')
  //           .doc(location)
  //           .collection('Availability')
  //           .doc(year)
  //           .collection("Year")
  //           .doc(week);
  //
  //       await weekRef.set({
  //         'Week': week,
  //         'Year': year,
  //         'Days': updatedDaysJson,
  //       });
  //     }
  //   } catch (e) {
  //     print("Error saving availability: $e");
  //   }
  // }



  // fetch availability count

  Future<void> fetchAvailabilityCount({
    required String week,
    required String year,
    required String location,

  }) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('Employees')
          .get();

      Map<String, int> newCounts = {
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
        'Sunday': 0,
      };

      for (var doc in snapshot.docs) {
        var daysSnapshot = await doc.reference
            .collection('Availability')
            .doc("${week}_$year")
            .collection('Days')
            .get();

        for (var dayDoc in daysSnapshot.docs) {
          var dayData = dayDoc.data();
          if (dayData['status'] == "On" && dayData['location'] == location) {
            newCounts[dayData['day']] = (newCounts[dayData['day']] ?? 0) + 1;
          }
        }
      }

      dayCounts = newCounts;
      notifyListeners();
    } catch (e) {
      print("Error fetching availability count: $e");
    }
  }
// save employee availability for a day



  Future<void> saveAvailabilityPerDay({
    required String employeeId,
    required String week,
    required String year,
    required String dayDocID,
    required bool isOn,
    required String location,
    required String day,
  }) async {


    try {
      // Reference to the specific day
      DocumentReference dayDoc = firestore
          .collection('Employees')
          .doc(employeeId)
          .collection('Availability')
          .doc("${week}_$year")
          .collection('Days')
          .doc(dayDocID);

      // Update status and location
      await dayDoc.set({
        'status': isOn ? "On" : "Off",
        'location': isOn ? location : null
      }, SetOptions(merge: true));

      // Update the day count
      dayCounts[day] = isOn
          ? (dayCounts[day] ?? 0) + 1
          : (dayCounts[day] ?? 0) - 1;
         // await fetchDriversAvailability(week: week, year: year, location: location);

      print("driver Availability saved successfully!");
    } catch (e) {
      print("Error updating driver availability: $e");
    }
  }

  //toggle availability localy
  void toggleAvailability({required String employeeId, required String day,required String location,}) {
    for (var employee in employeeFetch) {
      if (employee.employeeID == employeeId) {
        var targetDay = employee.availability!
            .firstWhere((avail) => avail.day == day, orElse: () => DayAvailability(
          day: day,
          status: "Off",
          date: DateTime.now().toIso8601String(),
        ));
       print("....................${targetDay.day}");
        targetDay.status = targetDay.status == "On" ? "Off" : "On";
        //targetDay.status = !(targetDay.status == "On")? "On" : "Off";
        //targetDay.location = !(targetDay.status == "On")? location : null;


      targetDay.location = targetDay.status == "On" ? location : null;
        print("............location ${!(targetDay.status == "On")}..status day. ${targetDay.status}...${targetDay.location}");
        // Update the day count
        dayCounts[day] = targetDay.status == "On"
            ? (dayCounts[day] ?? 0) + 1
            : (dayCounts[day] ?? 0) - 1;
        notifyListeners();
        break;
      }
    }
  }
  int calculateEmployeeTotal({required Employee employee,required String location}) {
    int count = 0;

    List<DayAvailability>? days = employee.availability;

    for (var day in days!) {
      if (day.status == "On" && day.location == location) {
        count++;
      }
    }

    return count;
  }
// checking locally if the day’s availability for the employee already exists at another location.
  bool checkingDayConflict({
    //required List<Employee> employeeAvailability,
    required String employeeId,
    required String day,
    required String currentLocation,
  }) {
    try {
      // Find the employee from the local list
      Employee employee = employeeFetch.firstWhere(
            (emp) => emp.employeeID == employeeId,
      );

      // Search for the specific day's availability
      DayAvailability dayAvailability = employee.availability!.firstWhere(
            (avail) => avail.day == day,
        orElse: () => DayAvailability(
          day: day,
          status: "Off",
          location: null,
          date: DateTime.now().toIso8601String(),
        ),
      );

      // Return true if the employee is available at a different location
      return dayAvailability.status == "On" &&
          dayAvailability.location != currentLocation;
    } catch (e) {
      // If employee or availability is not found, return false (no conflict)
      return false;
    }
  }

  Future<List<Employee>> fetchDriversAvailability({
    required String week,
    required String year,
    required String location,
  }) async {
    isEmployeeLoading = true;
    notifyListeners();

    List<Employee> employeeList = [];


    try {
      // Fetch all employees
      QuerySnapshot employeeSnapshot =
      await firestore.collection('Employees')
          .orderBy('EmployeeName', descending: false)  // Sort alphabetically (A-Z)
          .get();

      for (var employeeDoc in employeeSnapshot.docs) {
        Employee employee = Employee.fromJson(
          employeeDoc.data() as Map<String, dynamic>,
          // employeeDoc.id,
        );

        // Reference to Availability
        DocumentReference availabilityRef = firestore
            .collection('Employees')
            .doc(employee.employeeID)
            .collection('Availability')
            .doc("${week}_$year");

        // Check if Availability exists
        DocumentSnapshot availabilitySnapshot = await availabilityRef.get();

          // If availability exists, fetch days
          QuerySnapshot daysSnapshot =
          await availabilityRef.collection('Days').get();

          employee.availability = daysSnapshot.docs.map((dayDoc) {
            return DayAvailability.fromJson(
                dayDoc.data() as Map<String, dynamic>);
          }).toList();

          dayAvailabilityList = employee.availability!;


        employeeList.add(employee);
        employeeFetch = employeeList;
        notifyListeners();
      }
      return employeeList;
    } catch (e) {
      print("Error fetching employees: $e");
      return [];
    }finally{
      isEmployeeLoading = false;
      notifyListeners();
    }


  }

//new.........................................
  Future<bool> saveAvailabilityList(
      { required int year, required int week, required List<Employee> employeeList}) async {
    try {


      for (var employee in employeeList) {
        // Get the days object

           for(var day in employee.availability!){
             int weekDay = DateTime.parse(day.date).weekday;
             // Save the updated availability to Firestore
             DocumentReference weekRef = firestore
                 .collection('Employees')
                 .doc(employee.employeeID)
                 .collection('Availability')
                 .doc("${week}_$year")
                 .collection('Days')
                 .doc("${weekDay}_${getDay(weekDay)}");

             await weekRef.set({
               'day': day.day,
               'date': day.date,
               'status': day.status,
               'UpdatedAt':DateTime.now(), //...............................................
               // 'status':  !(day.status == "On") ? "On" : "Off",
               // 'location': !(day.status == "On") ? location : null,
               'location': day.location,
             },SetOptions(merge: true));
           }
      }
      return true;
    } catch (e) {
      print("Error saving availability: $e");
      return false;
    }
  }


//old
  Future<void> saveAvailabilityToFirestore(String location, String year, int week) async {
    try {
      // Convert year and week to integers

      // Generate dates for the target week
      List<DateTime> weekDates = getDaysOfWeek(int.parse(year), week);
      List<String> daysOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

      // Create a map of days and their corresponding dates
      Map<String, String> generateDates() {
        Map<String, String> dates = {};
        for (int i = 0; i < daysOrder.length; i++) {
          dates[daysOrder[i]] = DateFormat('yyyy-MM-dd').format(weekDates[i]);
        }
        return dates;
      }

      Map<String, String> weekDatesMap = generateDates();

      for (var employee in employeeFetch) {
        // Get the days object
        Days days = employee.locations![0].availability![0].days!;

        // Update each day's date in the Days object
        Map<String, dynamic> updatedDaysJson = days.toJson();

        updatedDaysJson.forEach((day, value) {
          if (weekDatesMap.containsKey(day)) {
            value['Date'] = weekDatesMap[day]; // Update the date for each day
            value['IsAllocated'] = false; // Set IsAllocated to false
          }
        });

        // Save the updated availability to Firestore
        DocumentReference weekRef = firestore
            .collection('Employees')
            .doc(employee.employeeID)
            .collection('Location')
            .doc(location)
            .collection('Availability')
            .doc("${week}_$year");

        await weekRef.set({
          'Week': week,
          'Year': year,
          'Days': updatedDaysJson,
        });
      }
    } catch (e) {
      print("Error saving availability: $e");
    }
  }


}
