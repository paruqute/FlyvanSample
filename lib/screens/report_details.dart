import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/appbar_widget.dart';
import '../custom_widgets/pdf_maker.dart';
import '../custom_widgets/table_column_name.dart';
import '../model/Day_model.dart';
import '../model/employee_model.dart';
import '../model/route_model.dart';
import '../model/vehicle.dart';
import '../provider/weekly_report.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';
import '../week_methods.dart';

class ReportDetails extends StatelessWidget {
  static const routeName = "/report_details";
  final String? week;
  final String? location;
  final String? year;
  final Map<String, String>? dates;

  const ReportDetails({super.key,this.week,this.location,this.year,this.dates});

  @override
  Widget build(BuildContext context) {
    ReportDetails _args() {
      final args = ModalRoute.of(context)!.settings.arguments
      as ReportDetails;
      return args;
    }
    Size size = MediaQuery.of(context).size;
    return Consumer<WeeklyReportProvider>(
      builder: (context, report, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              CustomAppBar(
                size: size,
                title: "Report of ${_args().location}",
              ),
              Container(
                height: size.height * 0.85,
                decoration: BoxDecoration(
                    color: Colors.white,
                    image: logoBgDecorationImage(),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Week ${_args().week}",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: primaryColor, fontSize: 16),
                        ),

                        ElevatedButton.icon(
                          onPressed: () {
                          try{
                            generateWeeklyReportPDF(
                              routeList: report.weeklyReportList!,
                              context: context,
                              week: _args().week!,
                              location: _args().location!,
                              year: _args().year!,
                              dates: _args().dates!,
                              employees: report.employeesList,
                              vanUsageList: report.vanUsageList,
                              employeeRouteList: report.employeeRouteList,
                            );

                            print("successfully saved pdf");

                          }catch(e){

                            print("error saving pdf $e");
                          }
                          },
                          icon: Icon(Icons.download),
                          label: Text("Download Report"),
                        )

                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      color: secondaryColor.withOpacity(0.2),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_args().dates?['start']}",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: primaryColor, fontSize: 16),
                          ),
                          Text(
                            "${_args().dates?['end']}",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: primaryColor, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Text(
                    //   "Weekly Availability",
                    //   style: Theme.of(context)
                    //       .textTheme
                    //       .titleLarge
                    //       ?.copyWith(color: primaryColor, fontSize: 20),
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    //
                    // employeeTable(
                    //     context: context, employee: report.employeesList),
                    // Divider(color: primaryColor,),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    Text(
                      "Final Route Distribution Details",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: primaryColor, fontSize: 16),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Using map() to build tables for each date
                    // routeTableReport(date: "2024-12-30",context: context,routes: report.weeklyReportList),
                    report.weeklyReportList != null
                        ? Column(
                            children: [
                              ...?report.weeklyReportList?.map((entry) {
                                return routeTableReport(
                                    date: entry.date ?? '',
                                    context: context,
                                    routes: entry.routes,
                                    note: entry.notes);
                              })
                            ],
                          )
                        : const Center(child: Text('No route data available')),
                    Divider(color: primaryColor,),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Van Usage",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                          color: primaryColor, fontSize:16),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    vanUsageTable(context: context,week: _args().week,van: report.vanUsageList),
                    Divider(color: primaryColor,),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Route Assignment",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                          color: primaryColor, fontSize: 16),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    employeeRouteAssignmentTable(context: context,week: _args().week,reportList: report.employeeRouteList),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }


  // calculate the total routes in a week
  int getTotalRoutes(List<Employee> reportList) {
    return reportList.fold(0, (total, report) => total + (report.routeCount ?? 0));
  }


  Widget employeeRouteAssignmentTable({List<Employee>? reportList,required BuildContext context,String? week}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: secondaryColor.withOpacity(0.2),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Routes : ${getTotalRoutes(reportList!)}",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: primaryColor),
              ),
              Text(
                "Week : $week",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: primaryColor),
              ),

            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: DataTable(
            columnSpacing: 8.0,
            horizontalMargin: 10.0,
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade200),
              verticalInside: BorderSide(color: Colors.grey.shade200),
            ),
            columns: const [
              DataColumn(label: TableColumnName(columnTitle:"ID")),
              DataColumn(label: TableColumnName(columnTitle:"Driver")),
              DataColumn(label: TableColumnName(columnTitle:"Routes")),
              DataColumn(label: TableColumnName(columnTitle:"Total Hrs")),
            ],
            rows: reportList.map((entry) {
              return DataRow(cells: [
                DataCell(TableRowText(title:entry.employeeID??'')),
                DataCell(TableRowText(title:entry.employeeName??'')),
                DataCell(TableRowText(title:entry.routeCount.toString())),
                DataCell(TableRowText(title:formatDuration(entry.totalHours!))),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return "$hours:$minutes";
  }


  Widget vanUsageTable({List<Vehicle>? van,required BuildContext context,String? week}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: secondaryColor.withOpacity(0.2),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Van Usage",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: primaryColor),
              ),
              Text(
                "Week : $week",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: primaryColor),
              ),

            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: DataTable(
            columnSpacing: 8.0,
            horizontalMargin: 10.0,
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade200),
              verticalInside: BorderSide(color: Colors.grey.shade200),
            ),
            columns: const [

              DataColumn(label: TableColumnName(columnTitle: "Van")),
              DataColumn(label: TableColumnName(columnTitle: "Owner")),
              DataColumn(label: TableColumnName(columnTitle: "Days")),
            ],
            rows: van!.map((entry) {
              return DataRow(cells: [

                DataCell(TableRowText( title: entry.vehicleName??'',)),
                DataCell(TableRowText( title: entry.owner??'',)),
                DataCell(TableRowText( title:entry.usage.toString())),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget employeeTable(
      {required List<Employee>? employee, required BuildContext context}) {
    // Initialize column totals
    int mondayTotal = 0;
    int tuesdayTotal = 0;
    int wednesdayTotal = 0;
    int thursdayTotal = 0;
    int fridayTotal = 0;
    int saturdayTotal = 0;
    int sundayTotal = 0;
    int overallTotal = 0;

    // Calculate total availability for each day
    List<DataRow> employeeRows = employee!.map((employee) {
      Days days = employee.locations![0].availability![0].days!;

      // Calculate the total "On" days for the employee
      int totalOnDays = _calculateTotalAvailability(days);

      // Accumulate totals for each day
      if (days.monday.status == "On") mondayTotal++;
      if (days.tuesday.status == "On") tuesdayTotal++;
      if (days.wednesday.status == "On") wednesdayTotal++;
      if (days.thursday.status == "On") thursdayTotal++;
      if (days.friday.status == "On") fridayTotal++;
      if (days.saturday.status == "On") saturdayTotal++;
      if (days.sunday.status == "On") sundayTotal++;

      // Add to overall total
      overallTotal += totalOnDays;

      return DataRow(cells: [
        DataCell(TableRowText(title: employee.employeeID ?? "Unknown")),
        DataCell(TableRowText(title: employee.employeeName ?? "Unknown")),
        DataCell(buildAvailabilityIcon(dayValue: days.monday.status)),
        DataCell(buildAvailabilityIcon(dayValue: days.tuesday.status)),
        DataCell(buildAvailabilityIcon(dayValue: days.wednesday.status)),
        DataCell(buildAvailabilityIcon(dayValue: days.thursday.status)),
        DataCell(buildAvailabilityIcon(dayValue: days.friday.status)),
        DataCell(buildAvailabilityIcon(dayValue: days.saturday.status)),
        DataCell(buildAvailabilityIcon(dayValue: days.sunday.status)),
        DataCell(TableRowText(title: totalOnDays.toString())),
      ]);
    }).toList();

    // Add the summary row at the bottom
    employeeRows.add(
      DataRow(
        color: WidgetStateProperty.resolveWith(
            (states) => secondaryColor.withOpacity(0.08)),
        cells: [
          const DataCell(TableRowText(title: "Total")),
          DataCell(TableRowText(title: employee.length.toString())),
          // Placeholder for Driver column
          DataCell(TableRowText(title: mondayTotal.toString())),
          DataCell(TableRowText(title: tuesdayTotal.toString())),
          DataCell(TableRowText(title: wednesdayTotal.toString())),
          DataCell(TableRowText(title: thursdayTotal.toString())),
          DataCell(TableRowText(title: fridayTotal.toString())),
          DataCell(TableRowText(title: saturdayTotal.toString())),
          DataCell(TableRowText(title: sundayTotal.toString())),
          DataCell(TableRowText(title: overallTotal.toString())),
        ],
      ),
    );

    return DataTable(
        columnSpacing: 8.0,
        horizontalMargin: 10.0,
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
          verticalInside: BorderSide(color: Colors.grey.shade200),
        ),
        columns: [
          DataColumn(
              label: TableColumnName(
                columnTitle: "ID",
              ),
              headingRowAlignment: MainAxisAlignment.start),
          DataColumn(
              label: TableColumnName(
                columnTitle: "Driver",
              ),
              headingRowAlignment: MainAxisAlignment.start),
          DataColumn(
              label: TableColumnName(columnTitle: "M"),
              headingRowAlignment: MainAxisAlignment.center),
          DataColumn(
              label: TableColumnName(columnTitle: "T"),
              headingRowAlignment: MainAxisAlignment.center),
          DataColumn(
              label: TableColumnName(columnTitle: "W"),
              headingRowAlignment: MainAxisAlignment.center),
          DataColumn(
              label: TableColumnName(columnTitle: "T"),
              headingRowAlignment: MainAxisAlignment.center),
          DataColumn(
              label: TableColumnName(columnTitle: "F"),
              headingRowAlignment: MainAxisAlignment.center),
          DataColumn(
              label: TableColumnName(columnTitle: "S"),
              headingRowAlignment: MainAxisAlignment.center),
          DataColumn(
              label: TableColumnName(columnTitle: "S"),
              headingRowAlignment: MainAxisAlignment.center),
          DataColumn(
              label: TableColumnName(columnTitle: "Total"),
              headingRowAlignment: MainAxisAlignment.start),
        ],
        rows: employeeRows

        // employee!.map((employee) {
        //   Days days = employee.locations![0].availability![0].days!;
        //   // Calculate the Total "On" Days
        //   int totalOnDays = _calculateTotalAvailability(days);
        //
        //   return DataRow(cells: [
        //     DataCell(TableRowText(title: employee.employeeID ?? "Unknown")),
        //     DataCell(TableRowText(title:employee.employeeName ?? "Unknown")),
        //     DataCell(buildAvailabilityIcon(dayValue:days.monday.status )),
        //     DataCell(buildAvailabilityIcon(dayValue:days.tuesday.status )),
        //     DataCell(buildAvailabilityIcon(dayValue:days.wednesday.status )),
        //     DataCell(buildAvailabilityIcon(dayValue:days.thursday.status )),
        //     DataCell(buildAvailabilityIcon(dayValue:days.friday.status )),
        //     DataCell(buildAvailabilityIcon(dayValue:days.saturday.status )),
        //     DataCell(buildAvailabilityIcon(dayValue:days.sunday.status )),
        //     DataCell(TableRowText(title: totalOnDays.toString())),
        //   ]);
        // }).toList(),
        );
  }

  Widget routeTableReport({
    List<RouteModel>? routes,
    required String date,
    required String note,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: secondaryColor.withOpacity(0.2),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${getDay(DateTime.parse(date).weekday)}",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: primaryColor),
              ),
              Text(
                date,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: primaryColor),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: DataTable(
            columnSpacing: 8.0,
            horizontalMargin: 10.0,
            border: TableBorder(
              top: BorderSide(color: Colors.grey.shade200),
              right: BorderSide(color: Colors.grey.shade200),
              left: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
              horizontalInside: BorderSide(color: Colors.grey.shade200),
              verticalInside: BorderSide(color: Colors.grey.shade200),
            ),
            columns: const [
              DataColumn(
                  label: TableColumnName(
                columnTitle: "Driver",
              )),
              DataColumn(label: TableColumnName(columnTitle: 'Route')),
              DataColumn(label: TableColumnName(columnTitle: 'Time')),
              DataColumn(label: TableColumnName(columnTitle: 'Van')),
              DataColumn(label: TableColumnName(columnTitle: 'Type')),
            ],
            rows: routes!.map((route) {
              return DataRow(cells: [
                DataCell(TableRowText(title: route.employee ?? 'None')),
                DataCell(TableRowText(title: route.route ?? 'Unassigned')),
                DataCell(TableRowText(title: route.time ?? 'N/A')),
                DataCell(SizedBox( width:85,child: TableRowText(title: route.vehicleName ?? 'Unknown'))),
                DataCell(TableRowText(title: route.routeType ?? 'Unknown')),
              ]);
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          color: secondaryColor.withOpacity(0.08),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Notes:",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: primaryColor, fontStyle: FontStyle.italic),
              ),
              Text(
                note,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget buildAvailabilityIcon({
    // String dayLabel,
    required String? dayValue,
  }) {
    return Icon(
      dayValue == "On" ? Icons.check_circle : Icons.cancel,
      color: dayValue == "On" ? Colors.green : Colors.red,
      size: 18,
    );
  }

  /// Helper Function to Calculate Total "On" Days
  int _calculateTotalAvailability(Days days) {
    int count = 0;
    if (days.monday.status == "On") count++;
    if (days.tuesday.status == "On") count++;
    if (days.wednesday.status == "On") count++;
    if (days.thursday.status == "On") count++;
    if (days.friday.status == "On") count++;
    if (days.saturday.status == "On") count++;
    if (days.sunday.status == "On") count++;
    return count;
  }
}
