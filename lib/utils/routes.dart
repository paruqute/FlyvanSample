import 'package:flutter/material.dart';

import '../screens/add_user.dart';
import '../screens/admin_dashboard.dart';
import '../screens/dashboard.dart';
import '../screens/drivers.dart';
import '../screens/employee_availability.dart';
import '../screens/for_tomorrow.dart';
import '../screens/login.dart';
import '../screens/report_details.dart';
import '../screens/route_allocation.dart';
import '../screens/route_details.dart';
import '../screens/schedule_screen.dart';
import '../screens/van_view.dart';
import '../screens/weekly_report.dart';

class AppRoutes {
  Map<String, Widget Function(BuildContext)> get(BuildContext context) {
    return {
      LoginScreen.routeName:(context)=>const LoginScreen(),
      Dashboard.routeName:(context)=>const Dashboard(),
      AdminDashboard.routeName:(context)=>const AdminDashboard(),
      ScheduleScreen.routeName:(context)=>const ScheduleScreen(),
      EmployeeAvailabilityScreen.routeName:(context)=> EmployeeAvailabilityScreen(),
      ForTomorrowScreen.routeName:(context)=> ForTomorrowScreen(),
      RouteAllocation.routeName:(context)=> RouteAllocation(),
      RouteDetails.routeName:(context)=> RouteDetails(),
      WeeklyReport.routeName:(context)=> WeeklyReport(),
      ReportDetails.routeName:(context)=> ReportDetails(),
      DriversViewScreen.routeName:(context)=> DriversViewScreen(),
      VanViewScreen.routeName:(context)=> VanViewScreen(),
      AddUser.routeName:(context)=> AddUser(),




    };
  }
}