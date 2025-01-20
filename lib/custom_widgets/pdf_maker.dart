import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../model/Day_model.dart';
import '../model/employee_model.dart';
import '../model/vehicle.dart';
import '../model/route_model.dart';
import '../model/weekly_report.dart';
import '../provider/weekly_report.dart';
import '../week_methods.dart';

Future<void> generateWeeklyReportPDF({
  required List<Employee> employees,
  required List<Vehicle> vanUsageList,
  required List<WeeklyReportModel> routeList,
  required List<Employee> employeeRouteList,
  required String week,
  required String location,
  required String year,
  required Map<String, String> dates,
  required BuildContext context,
}) async {
  final pdf = pw.Document();
  final logo = pw.MemoryImage(
    (await rootBundle.load('assets/images/logo4.png')).buffer.asUint8List(),
  );
  // Page 1: Cover Page
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                height:200,
               width: 300,
               child: pw.Image(logo,fit: pw.BoxFit.contain)
              ),
              pw.SizedBox(height: 20),
              pw.Text("Weekly Report",
                  style: pw.TextStyle(
                      fontSize: 40, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Week $week - $year", style: pw.TextStyle(fontSize: 24)),
              pw.Text(location, style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 40),
              pw.Text("Start: ${dates['start']}   |   End: ${dates['end']}",
                  style: pw.TextStyle(fontSize: 18)),
            ],
          ),
        );
      },
    ),
  );
  pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
    build: (context) => [
      // _buildEmployeeTable(employees),
      // pw.SizedBox(height: 20),
      pw.Column(children: [
        pw.Text("Route Distribution Details",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...routeList.map((route) {
          return _buildRouteTable(routeList: route.routes, weekly: route);
        }).toList(),
      ]),
      pw.SizedBox(height: 10),
      _buildVanUsageTable(vanUsageList),
      pw.SizedBox(height: 10),
      _buildEmployeeRouteAssignmentTable(employeeRouteList),
    ],
  ));
  // Page 2: Employee Availability Table
  // pdf.addPage(
  //   pw.Page(
  //     build: (pw.Context context) {
  //       return _buildEmployeeTable(employees);
  //     },
  //   ),
  // );

  // Page 3: Van Usage Table
  // pdf.addPage(
  //   pw.Page(
  //     build: (pw.Context context) {
  //       return _buildVanUsageTable(vanUsageList);
  //     },
  //   ),
  // );

  // Page 4: Route Distribution Details
  // pdf.addPage(
  //   pw.MultiPage(
  //     build: (pw.Context context) => [
  //       pw.Text("Route Distribution Details", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //       pw.SizedBox(height: 10),
  //       ...routeList.map((route) {
  //         return _buildRouteTable(routeList: route.routes,weekly: route);
  //       }).toList(),
  //     ],
  //   ),
  // );

  // Page 5: Route Assignment by Employee
  // pdf.addPage(
  //   pw.Page(
  //     build: (pw.Context context) {
  //       return _buildEmployeeRouteAssignmentTable(employeeRouteList);
  //     },
  //   ),
  // );

  // Save PDF to Device
  // final output = await getExternalStorageDirectory();
  // final file = File("${output!.path}/weekly_report_week${week}_$year.pdf");
  //
  // await file.writeAsBytes(await pdf.save());
String name = "weeklyReport_${location}_week_${week}_$year.pdf";
  final success = await Provider.of<WeeklyReportProvider>(context, listen: false)
      .savePdf(name: name, pdf: pdf);
  if(success){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("$name saved")),
    );
  }
  else{
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Can't save file")),
    );
  }
  // Open the PDF immediately after saving
  // await OpenFile.open(file.path);

  // print("PDF Generated and Opened: ${file.path}");
}

// Employee Availability Table
pw.Widget _buildEmployeeTable(List<Employee> employees,String location) {
  // Initialize column totals
  int mondayTotal = 0;
  int tuesdayTotal = 0;
  int wednesdayTotal = 0;
  int thursdayTotal = 0;
  int fridayTotal = 0;
  int saturdayTotal = 0;
  int sundayTotal = 0;
  int overallTotal = 0;

  final data = employees.map((employee) {
    Days days = employee.locations![0].availability![0].days!;
    int totalOnDays = _calculateEmployeeTotal(employee,location);

    if (days.monday.status == "On") mondayTotal++;
    if (days.tuesday.status == "On") tuesdayTotal++;
    if (days.wednesday.status == "On") wednesdayTotal++;
    if (days.thursday.status == "On") thursdayTotal++;
    if (days.friday.status == "On") fridayTotal++;
    if (days.saturday.status == "On") saturdayTotal++;
    if (days.sunday.status == "On") sundayTotal++;

    overallTotal += totalOnDays;

    return [
      employee.employeeID ?? "Unknown",
      employee.employeeName ?? "Unknown",
      _availabilitySymbol(days.monday.status),
      _availabilitySymbol(days.tuesday.status),
      _availabilitySymbol(days.wednesday.status),
      _availabilitySymbol(days.thursday.status),
      _availabilitySymbol(days.friday.status),
      _availabilitySymbol(days.saturday.status),
      _availabilitySymbol(days.sunday.status),
      totalOnDays.toString(),
    ];
  }).toList();

  // Add Total Row
  data.add([
    "Total",
    employees.length.toString(),
    mondayTotal.toString(),
    tuesdayTotal.toString(),
    wednesdayTotal.toString(),
    thursdayTotal.toString(),
    fridayTotal.toString(),
    saturdayTotal.toString(),
    sundayTotal.toString(),
    overallTotal.toString(),
  ]);

  return pw.Column(children: [
    pw.Text("Driver Availability",
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
    pw.SizedBox(height: 10),
    pw.TableHelper.fromTextArray(
      headers: [
        "ID",
        "Driver",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
        "Sun",
        "Total"
      ],
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      //  cellStyle: pw.TextStyle(font: notoFont),
      cellAlignment: pw.Alignment.center,
    )
  ]);
}

// Helper to display ✔ or ✖
String? _availabilitySymbol(String? status) {
  return status == "On" ? "Yes" : "No";
}

// Van Usage Table
pw.Widget _buildVanUsageTable(List<Vehicle> vans) {
  return pw.Column(
    //crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text("Van Usage",
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.TableHelper.fromTextArray(
        headers: ["Owner", "Van", "Days"],
        data: vans.map((van) {
          return [
            van.owner ?? "Unknown",
            van.vehicleName ?? "Unknown",
            van.usage.toString(),
          ];
        }).toList(),
        border: pw.TableBorder.all(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        cellAlignment: pw.Alignment.center,
      ),
    ],
  );
}

// Route Distribution Table
pw.Widget _buildRouteTable(
    {required List<RouteModel> routeList, required WeeklyReportModel weekly}) {
  return pw.Column(
    // crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        width: double.infinity,
        color: PdfColors.grey300,
        padding: const pw.EdgeInsets.all(8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "${getDay(DateTime.parse(weekly.date).weekday)}",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              "Date: ${weekly.date}",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      pw.TableHelper.fromTextArray(
        headers: ["Driver", "Route", "Time", "Van","Type"],
        data: routeList.map(
          (route) {
            return [
              route.employee ?? "None",
              route.route ?? "Unassigned",
              route.time ?? "N/A",
              route.vehicleName ?? "Unknown",
              route.routeType ?? "Unknown",
            ];
          },
        ).toList(),
        border: pw.TableBorder.all(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        cellAlignment: pw.Alignment.center,
      ),
      pw.SizedBox(height: 20),
      pw.Text("Notes: ${weekly.notes ?? 'No Notes'}",
          style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
      pw.SizedBox(height: 30),
    ],
  );
}

// Employee Route Assignment Table

int getTotalRoutes(List<Employee> reportList) {
  return reportList.fold(
      0, (total, employee) => total + (employee.routeCount ?? 0));
}

pw.Widget _buildEmployeeRouteAssignmentTable(List<Employee> reportList) {
  int totalRoutes = getTotalRoutes(reportList);

  return pw.Column(
     crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Text("Route Assignment",
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.Container(
        width: double.infinity,
        color: PdfColors.grey300,
        padding: const pw.EdgeInsets.all(8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Route Assignment",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              "Total Routes: $totalRoutes",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // pw.SizedBox(height: 10),
      pw.Table(
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        columnWidths: {
          0:pw.IntrinsicColumnWidth(), // Driver Name (wider)
          1:pw.FlexColumnWidth(2), // Monday
          2: pw.IntrinsicColumnWidth(), // Tuesday
          3: pw.IntrinsicColumnWidth(), // Wednesday
        },
        border: pw.TableBorder.all(),
        children: [
          pw.TableRow(children: [
            _buildCell(text: "Driver ID",isHeader: true),
            _buildCell(text:"Driver",isHeader: true),
            _buildCell(text:"Routes",isHeader: true),
            _buildCell(text: "Total Hrs",isHeader: true),
          ]),

          ...reportList.map((employee) {
            return pw.TableRow(children: [
             _buildCell(text:employee.employeeID ?? "Unknown"),
              _buildCell(text:employee.employeeName ?? "Unknown"),
              _buildCell(text:employee.routeCount.toString()),
              _buildCell(text:formatDuration(employee.totalHours!)),
            ]);
          }),
        ],


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

pw.Widget _buildCell({required String text, bool isHeader = false}) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(3),
    child: // Padding for each cell
    pw.Text(
      text,
      softWrap: true,
      maxLines: 3,
      style: pw.TextStyle(
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        fontSize: isHeader ? 14 : 12,
      ),
    ),
  );
}
// Helper function to calculate "On" days
/// Helper Function to Calculate Total "On" Days
int _calculateEmployeeTotal(Employee employee,String location) {
  int count = 0;

  List<DayAvailability>? days = employee.availability;

  for (var day in days!) {
    if (day.status == "On" && day.location == location) {
      count++;
    }
  }

  return count;
}
