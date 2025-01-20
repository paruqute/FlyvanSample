
import 'package:flyvanexpress/model/route_model.dart';

class WeeklyReportModel {
  final String date;
  final String notes;
  final List<RouteModel> routes;

  WeeklyReportModel({
    required this.date,
    required this.notes,
    required this.routes,
  });

  factory WeeklyReportModel.fromJson(Map<String, dynamic> json) {
    return WeeklyReportModel(
      date: json['Date'],
      notes: json['Notes'],
      routes: (json['Routes'] as List<dynamic>).map((route) {
        return RouteModel.fromJson(route as Map<String, dynamic>);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Notes': notes,
      'Routes': routes.map((route) => route.toJson()).toList(),
    };
  }
}