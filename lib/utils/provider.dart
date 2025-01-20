


import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../provider/employee.dart';
import '../provider/location.dart';
import '../provider/login.dart';
import '../provider/route_provider.dart';
import '../provider/vehicle.dart';
import '../provider/weekly_report.dart';

class ProviderTree {
  List<SingleChildWidget> get(BuildContext context) {
    return [
      ChangeNotifierProvider.value(value: LocationProvider()),
      ChangeNotifierProvider.value(value: EmployeeProvider()),
      ChangeNotifierProvider.value(value: RouteProvider()),
      ChangeNotifierProvider.value(value: WeeklyReportProvider()),
      ChangeNotifierProvider.value(value: VehicleProvider()),
      ChangeNotifierProvider.value(value: LoginProvider()),




    ];
  }
}