import 'package:cloud_firestore/cloud_firestore.dart';

import 'Day_model.dart';

class Employee {
  String? employeeID;
  String? employeeName;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? phone;
  int? routeCount;
  List<Location>? locations;
  List<DayAvailability>? availability;
  Duration? totalHours;

  Employee(
      {this.employeeID,
      this.employeeName,
      this.locations,
      this.phone,
      this.routeCount,
      this.availability,
      this.totalHours,
      DateTime? createdAt,
      this.updatedAt,
      }): createdAt = createdAt ?? DateTime.now();

  Employee.fromJson(Map<String, dynamic> json) {
    employeeID = json['EmployeeID'];
    employeeName = json['EmployeeName'];
    createdAt = json['CreatedAt'] != null
        ? (json['CreatedAt'] as Timestamp).toDate()
        : DateTime.now();
    updatedAt= json['UpdatedAt'] != null
        ? (json['UpdatedAt'] as Timestamp).toDate()
        : null;// Allow null for updatedAt

    // routeCount = json['RouteCount'];
    phone = json['Phone'];
    if (json['Location'] != null) {
      locations = <Location>[];
      json['Locations'].forEach((v) {
        locations!.add(Location.fromJson(v));
      });
    }
    if (json['Availability'] != null) {
      availability = <DayAvailability>[];
      json['Locations'].forEach((v) {
        availability!.add(DayAvailability.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['EmployeeID'] = employeeID;
    data['EmployeeName'] = employeeName;
    data['CreatedAt'] = createdAt;
    data['UpdatedAt'] = updatedAt;

    // data['RouteCount'] = routeCount;
    data['Phone'] = phone;
    if (locations != null) {
      data['Locations'] = locations!.map((v) => v.toJson()).toList();
    }
    if (availability != null) {
      data['Availability'] = availability!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Location {
  String? location;
  List<Availability>? availability;

  //List<RouteModel>? route;

  Location({
    this.location,
    this.availability,
  });

  Location.fromJson(Map<String, dynamic> json) {
    location = json['Location'];
    if (json['Availability'] != null) {
      availability = <Availability>[];
      json['Availability'].forEach((v) {
        availability!.add(Availability.fromJson(v));
      });
    }
    // if (json['Route'] != null) {
    //   route = <RouteModel>[];
    //   json['Route'].forEach((v) {
    //     route!.add(RouteModel.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Location'] = location;
    if (availability != null) {
      data['Availability'] = availability!.map((v) => v.toJson()).toList();
    }
    // if (route != null) {
    //   data['Route'] = route!.map((v) => v.toJson()).toList();
    // }

    return data;
  }
}

class Availability {
  String? week;
  Days? days;
  String? year;

  Availability({this.week, this.days, this.year});

  Availability.fromJson(Map<String, dynamic> json) {
    week = json['Week'];
    year = json['Year'];
    days = json['Days'] != null ? Days.fromJson(json['Days']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Week'] = week;
    if (days != null) {
      data['Days'] = days!.toJson();
    }
    return data;
  }
}

// class Days {
//   String? monday;
//   String? tuesday;
//   String? wednesday;
//   String? thursday;
//   String? friday;
//   String? saturday;
//   String? sunday;
//
//   Days(
//       {this.monday,
//         this.tuesday,
//         this.wednesday,
//         this.thursday,
//         this.friday,
//         this.saturday,
//         this.sunday});
//
//   Days.fromJson(Map<String, dynamic> json) {
//     monday = json['Monday'];
//     tuesday = json['Tuesday'];
//     wednesday = json['Wednesday'];
//     thursday = json['Thursday'];
//     friday = json['Friday'];
//     saturday = json['Saturday'];
//     sunday = json['Sunday'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['Monday'] = monday;
//     data['Tuesday'] = tuesday;
//     data['Wednesday'] = wednesday;
//     data['Thursday'] = thursday;
//     data['Friday'] = friday;
//     data['Saturday'] = saturday;
//     data['Sunday'] = sunday;
//     return data;
//   }
// }
class DayAvailability {
  final String day;
  final String date;
  String status;
  String? location;
  bool? isAllocated;
   DateTime? updatedAt;

  DayAvailability({
    required this.day,
    required this.date,
    this.status = "Off",
    this.location,
    this.isAllocated,
    this.updatedAt,
  });

  // Factory constructor to create an instance from Firestore data
  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      day: json['day'],
      date: json['date'],
      status: json['status'] ?? "Off",
      location: json['location'],
      isAllocated: json['isAllocated'],
      updatedAt: json['UpdatedAt'] != null
          ? (json['UpdatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'status': status,
      'location': location,
      'isAllocated': isAllocated,
      'UpdatedAt': updatedAt,
    };
  }
}
