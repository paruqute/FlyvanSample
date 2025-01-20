import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String? date;
  String? route;
  String? vehicleRegNum;
  String? vehicleName;
  final String? week;
  String? employee;
  final String? location;
  final String? employeeId;
  final String? year;
  final String? time;
  final String? routeType;
  final bool isAvailableOnly;
  DateTime? createdAt;
  RouteModel({
    this.date,
    this.route,
    this.vehicleRegNum,
    this.employee,
    this.week,
    this.location,
    this.employeeId,
    this.year,
    this.vehicleName,
    this.time,
    this.routeType,
    this.isAvailableOnly = false,
    DateTime? createdAt,
  }): createdAt = createdAt ?? DateTime.now();

  /// Factory method to create a RouteModel from Firestore data
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      date: json['Date'],
      route: json['Route'],
      vehicleRegNum: json['VehicleRegNumber'],
      employee: json['EmployeeName'],
      week: json['Week'],
      vehicleName: json['VehicleName'],
      location: json['Location'],
      employeeId: json['EmployeeID'],
      year: json['Year'],
      time: json['Time'],
      routeType: json['RouteType'],
      createdAt :json['CreatedAt'] != null
            ? (json['CreatedAt'] as Timestamp).toDate()
            : DateTime.now(),
    );
  }

  /// Convert RouteModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Route': route,
      'VehicleRegNumber': vehicleRegNum,
      'EmployeeName': employee,
      'VehicleName': vehicleName,
      'Week': week,
      'EmployeeID': employeeId,
      'Location': location,
      'Year': year,
      'Time': time,
      'RouteType': routeType,
      'CreatedAt': createdAt,
    };
  }
}
