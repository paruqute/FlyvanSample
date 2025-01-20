import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/appbar_widget.dart';
import '../custom_widgets/table_column_name.dart';
import '../model/Day_model.dart';
import '../model/employee_model.dart';
import '../provider/location.dart';
import '../provider/weekly_report.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class EmployeeAvailabilityScreen extends StatefulWidget {
  static const routeName = "/employee_availability_screen";

  const EmployeeAvailabilityScreen(
      {super.key, this.year, this.week, this.station});

  final int? year;
  final int? week;
  final String? station;

  @override
  State<EmployeeAvailabilityScreen> createState() =>
      _EmployeeAvailabilityScreenState();
}

class _EmployeeAvailabilityScreenState
    extends State<EmployeeAvailabilityScreen> {
  EmployeeAvailabilityScreen _args() {
    final args = ModalRoute.of(context)!.settings.arguments
        as EmployeeAvailabilityScreen;
    return args;
  }

  //List<Employee> employees = [];
  bool isSavingData = false;
  int overAllTotal = 0;
  int totalOnDays = 0;
 bool canSavePDF = false;
  Map<String, int> dayCounts = {
    "Monday": 0,
    "Tuesday": 0,
    "Wednesday": 0,
    "Thursday": 0,
    "Friday": 0,
    "Saturday": 0,
    "Sunday": 0,
  };

  // /// Fetch counts for all days using AggregateQuerySnapshot
  // Future<void> fetchDayCounts() async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //
  //   try {
  //     Map<String, int> counts = {};
  //
  //     // List of days to query
  //     List<String> days = [
  //       "Monday",
  //       "Tuesday",
  //       "Wednesday",
  //       "Thursday",
  //       "Friday",
  //       "Saturday",
  //       "Sunday"
  //     ];
  //
  //     // Iterate through days and perform aggregation query
  //     for (String day in days) {
  //       final query = firestore
  //           .collectionGroup('Availability') // Collection group query
  //           .where('Days.$day.status', isEqualTo: "On")
  //           .where('Location', isEqualTo: _args().station)
  //           .where('Year', isEqualTo: _args().year.toString())
  //           .where('Week', isEqualTo: "Week${_args().week.toString()}");
  //
  //       final AggregateQuerySnapshot snapshot = await query.count().get();
  //
  //       counts[day] = snapshot.count!; // Save count for the day
  //     }
  //
  //     setState(() {
  //       dayCounts = counts; // Update state with counts
  //     });
  //   } catch (e) {
  //     print("Error fetching day counts: $e");
  //   }
  // }

  // Future<void> fetchData() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     employees = await fetchEmployeesWithAvailability(
  //       selectedLocation,
  //       selectedYear,
  //       selectedWeek,
  //     );
  //   } catch (e) {
  //     print("Error fetching data: $e");
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    // Provider.of<LocationProvider>(context, listen: false)
    //     .fetchEmployeesWithDefaultAvailability(
    //     location: _args().station!,
    //     year: _args().year.toString(),
    //     week: "Week${_args().week.toString()}");

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            CustomAppBar(
              size: size,
              title: "Driver Availability\n${_args().station}",
            ),

            Container(
              //  padding: EdgeInsets.all(20),
              height: size.height * 0.85,

              decoration: BoxDecoration(
                  color: Colors.white,
                  image: logoBgDecorationImage(),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: Consumer<LocationProvider>(
                builder: (context, employees, child) {
                  // Check if the data is still loading
                  // List<DataRow> rows = employees.employeeFetch.map((employee) {
                  //   Days days = employee.locations![0].availability![0].days!;
                  //
                  //   return buildDataRow(employee, context, days);
                  // }).toList();
                  //
                  if (employees.isEmployeeLoading ||
                      employees.employeeFetch.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                      ), // Show loading spinner
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   "Week ${_args().week}",
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .titleLarge
                        //       ?.copyWith(color: primaryColor, fontSize: 20),
                        // ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        Expanded(
                          child: DataTable2(
                            scrollController: ScrollController(),
                            //minWidth: MediaQuery.of(context).size.width*3,
                            isVerticalScrollBarVisible: false,
                            //isHorizontalScrollBarVisible:false,
                            //horizontalScrollController: ScrollController(),
                            bottomMargin: 15.0,
                            showBottomBorder: true,
                            fixedTopRows: 1,
                           // fixedLeftColumns: 1,
                            columnSpacing: 5.0,
                            horizontalMargin: 12.0,
                            border: TableBorder(
                              horizontalInside:
                                  BorderSide(color: Colors.grey.shade200),
                              verticalInside:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            columns: [
                              DataColumn2(
                               fixedWidth: 85,
                            headingRowAlignment:
                            MainAxisAlignment.start,
                                  label: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TableColumnName(
                                        columnTitle: "Week ${_args().week}",
                                      ),
                                      TableColumnName(
                                        columnTitle: "Driver",
                                      ),
                                    ],
                                  ),
                               size: ColumnSize.L,
                              ),
                              ...employees.dayAvailabilityList.map(
                                (e) {
                                  String extractDay(String date) {
                                    List<String> parts = date.split('-');
                                    return parts
                                        .last; // Get the last part (day)
                                  }

                                  return DataColumn2(
                                      size: ColumnSize.S,
                                      label: Column(
                                        children: [
                                          TableColumnName(
                                              columnTitle: extractDay(e.date)),
                                          TableColumnName(
                                              columnTitle:
                                                  e.day.substring(0,1)),
                                        ],
                                      ),
                                      headingRowAlignment:
                                          MainAxisAlignment.center);
                                },
                              ),
                              DataColumn2(
                                  size: ColumnSize.M,
                                  label: TableColumnName(
                                    columnTitle: "Total",
                                  ),
                                  headingRowAlignment: MainAxisAlignment.start),
                            ],
                            rows: [
                              ...employees.employeeFetch.map((employee) {
                                // Days days = employee.locations![0].availability![0]
                                //     .days!;

                                // Initialize column totals
                                int mondayTotal = 0;
                                totalOnDays = employees.calculateEmployeeTotal(location: _args().station??'',employee: employee);
                                overAllTotal += totalOnDays;

                                return DataRow2(
                                  cells: [
                                    DataCell(
                                      TableRowText(
                                        title:
                                            employee.employeeName ?? "Unknown",
                                      ),
                                    ),
                                    ...?employee.availability?.map(
                                      (days) {
                                        // Accumulate totals for each day

                                        return DataCell(
                                          buildAvailabilityIcon(
                                            isAlreadyAvailable: employees.checkingDayConflict(day: days.day,currentLocation: _args().station??'',employeeId: employee.employeeID??''),
                                            days: days,
                                            station: _args().station ?? '',
                                            dayValue: days.status,
                                            onToggle: employees.checkingDayConflict(day: days.day,currentLocation: _args().station??'',employeeId: employee.employeeID??'')
                                                ? () {}
                                                : () async {

                                              ///save to firestore each time when the button toggled
                                                    // await Provider
                                                    //         .of<LocationProvider>(context, listen: false).saveAvailabilityPerDay(
                                                    //         day: days.day,
                                                    //         employeeId: employee.employeeID ??'',
                                                    //         week: _args().week.toString(),
                                                    //         year: _args().year.toString(),
                                                    //         dayDocID: "${DateTime.parse(days.date).weekday}_${days.day}",
                                                    //         isOn: !(days.status ==
                                                    //                 "On"),
                                                    //         location: _args()
                                                    //                 .station ??'');
                                                    // await Provider.of<LocationProvider>(context, listen: false).fetchDriversAvailability(
                                                    //         week: _args().week.toString(),
                                                    //         year: _args().year.toString(),
                                                    //         location: _args().station ?? '');
                                              /// saving data to local list

                                                    setState(() {
                                                      canSavePDF = true;
                                                     // days.status = toggleAvailability(days.status);
                                                    });
                                                    employees.toggleAvailability(

                                                      employeeId: employee.employeeID??'',
                                                      day: days.day,
                                                      location: _args().station??'',
                                                    );


                                                  },
                                          ),
                                        );
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: TableRowText(
                                          title: "$totalOnDays",
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              DataRow2(
                                // color: MaterialStateColor.resolveWith(
                                //         (states) => Colors.grey.shade200),
                                cells: [
                                  DataCell(TableRowText(
                                    title: "Total ",
                                  )),
                                  DataCell(
                                    Center(
                                        child: TableRowText(
                                            title:
                                                "${employees.dayCounts['Monday']}")),
                                  ),
                                  DataCell(Center(
                                      child: TableRowText(
                                          title:
                                              "${employees.dayCounts['Tuesday']}"))),
                                  DataCell(Center(
                                      child: TableRowText(
                                          title:
                                              "${employees.dayCounts['Wednesday']}"))),
                                  DataCell(Center(
                                      child: TableRowText(
                                          title:
                                              "${employees.dayCounts['Thursday']}"))),
                                  DataCell(Center(
                                      child: TableRowText(
                                          title:
                                              "${employees.dayCounts['Friday']}"))),
                                  DataCell(Center(
                                      child: TableRowText(
                                          title:
                                              "${employees.dayCounts['Saturday']}"))),
                                  DataCell(Center(
                                      child: TableRowText(
                                          title:
                                              "${employees.dayCounts['Sunday']}"))),
                                  DataCell(
                                      Center(child: TableRowText(title: ""))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height:5),
                        Row(
                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isSavingData = true;
                                });
                                final success=   await Provider.of<LocationProvider>(context, listen: false).saveAvailabilityList(

                                    year: _args().year??0,
                                    week: _args().week??0,
                                    employeeList: employees.employeeFetch
                                );
                                if(success){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Availability saved successfully!")),
                                  );
                                  setState(() {
                                    isSavingData = false;
                                    canSavePDF = false;
                                  });
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Something went wrong!")),
                                  );
                                  setState(() {
                                    isSavingData = false;
                                    canSavePDF = false;
                                  });
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Save Availability"),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  isSavingData
                                      ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ))
                                      : SizedBox()
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: canSavePDF? null:() {
                                try {
                                  exportTableToPDF(
                                    context: context,
                                    location: _args().station??'',
                                    employees: employees.employeeFetch,
                                    dayAvailabilityList:
                                    employees.dayAvailabilityList,
                                    dayCounts: employees.dayCounts,
                                    overAllTotal: overAllTotal,
                                  );
                                } catch (e) {
                                  print("Error saving pdf: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                        Text("Error saving pdf: $e")),
                                  );
                                }
                              },
                              child: Text("Save as PDF"),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ));
  }

  Future<void> exportTableToPDF({
    required BuildContext context,
    required List<Employee> employees,
    required List<DayAvailability> dayAvailabilityList,
    required Map<String, int> dayCounts,
    required int overAllTotal,
    required String location,
    // required int totalOnDays,
  }) async {
    final pdf = pw.Document();
    int totalCount = 0;
    int overAllTotalCount = 0;

    // Generate PDF Table
    // pdf.addPage(
    //   pw.Page(
    //     pageFormat: PdfPageFormat.a4,
    //     build: (pw.Context context) {
    //       return pw.Column(
    //         mainAxisSize: pw.MainAxisSize.min,
    //         children: [
    //           pw.Text(
    //             "Driver Availability",
    //             style:
    //                 pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
    //           ),
    //           pw.SizedBox(height: 10),
    //           pw.Text(
    //             "Year : ${_args().year}",
    //             style:
    //                 pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
    //           ),
    //           pw.SizedBox(height: 10),
    //           pw.Text(
    //             "Week : ${_args().week}",
    //             style:
    //                 pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
    //           ),
    //           pw.SizedBox(height: 10),
    //           pw.Text(
    //             "Station : ${_args().station}",
    //             style:
    //                 pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
    //           ),
    //           pw.SizedBox(height: 20),
    //         ],
    //       );
    //     },
    //   ),
    // );
    pdf.addPage(pw.MultiPage(
      margin: pw.EdgeInsets.all(10),
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return [
          pw.Center(
            child: pw.Text(
              "Driver Availability",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Year : ${_args().year}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.Center(
                  child: pw.Text(
                    "Station : ${_args().station}",
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Text(
                  "Week : ${_args().week}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ]),
          pw.SizedBox(height: 10),
          pw.Table(
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: {
                0: pw.FlexColumnWidth(2), // Driver Name (wider)
                1: pw.IntrinsicColumnWidth(), // Monday
                2: pw.IntrinsicColumnWidth(), // Tuesday
                3: pw.IntrinsicColumnWidth(), // Wednesday
                4: pw.IntrinsicColumnWidth(), // Thursday
                5: pw.IntrinsicColumnWidth(), // Friday
                6: pw.IntrinsicColumnWidth(), // Saturday
                7: pw.FlexColumnWidth(),
              },
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    _buildCell(text: "Driver", isHeader: true),
                    ...dayAvailabilityList.map(
                      (e) {
                        String extractMonthDay(String date) {
                          List<String> parts = date.split('-');
                          return "${parts[1]}-${parts[2]}"; // Get MM and dd
                        }

                        return pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("(MM-DD)",
                                  style: pw.TextStyle(
                                      color: PdfColors.grey500,
                                      fontSize: 10,
                                      fontStyle: pw.FontStyle.italic)),
                              _buildCell(
                                  text: "${extractMonthDay(e.date)}\n${e.day}",
                                  isHeader: true),
                            ]);
                      },
                    ),
                    _buildCell(text: "Total", isHeader: true),
                  ],
                ),
                ...employees.where((employee) {
                  // Check if the employee has at least one "On" day in the given location
                  return employee.availability?.any((e) => e.status == "On" && e.location == location) ?? false;
                }).map((employee)  {
                  totalCount = _calculateEmployeeTotal(employee);
                  overAllTotalCount += totalCount;
                  return pw.TableRow(children: [
                    _buildCell(text: "${employee.employeeName}"),
                    ...?employee.availability?.map(
                      (e) {
                        return pw.Center(
                          child: pw.Text(e.status == "On" && e.location == location? "ON" : "OFF",
                              style: pw.TextStyle(
                                  color: e.status == "On" && e.location == location
                                      ? PdfColors.green
                                      : PdfColors.red,
                                  fontSize: 10)),
                        );
                      },
                    ),
                    pw.Center(
                      child: _buildCell(text: "$totalCount"),
                    )
                  ]);
                }),
                pw.TableRow(children: [
                  _buildCell(text: "Total", isHeader: true),
                  pw.Center(
                    child: _buildCell(
                        text: "${dayCounts['Monday'] ?? 0}", isHeader: true),
                  ),
                  pw.Center(
                      child: _buildCell(
                          text: "${dayCounts['Tuesday'] ?? 0}",
                          isHeader: true)),
                  pw.Center(
                      child: _buildCell(
                          text: "${dayCounts['Wednesday'] ?? 0}",
                          isHeader: true)),
                  pw.Center(
                      child: _buildCell(
                          text: "${dayCounts['Thursday'] ?? 0}",
                          isHeader: true)),
                  pw.Center(
                      child: _buildCell(
                          text: "${dayCounts['Friday'] ?? 0}", isHeader: true)),
                  pw.Center(
                      child: _buildCell(
                          text: "${dayCounts['Saturday'] ?? 0}",
                          isHeader: true)),
                  pw.Center(
                      child: _buildCell(
                          text: "${dayCounts['Sunday'] ?? 0}", isHeader: true)),
                  pw.Center(child: _buildCell(text: "", isHeader: true)),
                ])
              ])
        ];

        // pw.TableHelper.fromTextArray(
        //   headers: [
        //     "Driver",
        //     dayAvailabilityList.map(
        //       (e) {
        //         return "${e.date}\n${e.day}";
        //       },
        //     ).toList(),
        //     "Total"
        //   ],
        //
        //   data: data,
        //   border: pw.TableBorder.all(),
        //   cellStyle: pw.TextStyle(
        //       fontWeight: pw.FontWeight.normal, color: PdfColors.black),
        //   headerStyle: pw.TextStyle(
        //       fontWeight: pw.FontWeight.bold, color: PdfColors.black),
        //   context: context,
        //   cellAlignment: pw.Alignment.center,
        //   // columnWidths: {
        //   //   0: pw.FlexColumnWidth(2), // Wider driver column
        //   //   for (int i = 1; i <= 7; i++) i: pw.FlexColumnWidth(1),
        //   // },
        // );
      },
    ));

    final success =
        await Provider.of<WeeklyReportProvider>(context, listen: false).savePdf(
            name: "DriversAvailability_${_args().station}_${_args().week}_${_args().year}.pdf",
            pdf: pdf);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              success ? "pdf saved successfully!" : "Something went wrong!")),
    );
  }

  pw.Widget _buildCell({required String text, bool isHeader = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(2),
      child: // Padding for each cell
          pw.Text(
        text,
        softWrap: true,
        maxLines: 3,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 12,
        ),
      ),
    );
  }

  // Helper to Get Availability Symbol
  String _availabilitySymbol(String? status) {
    return status == "On" ? "ON" : "OFF";
  }

  /// Helper Method to Toggle Availability Value
  String toggleAvailability(String? currentValue) {
    return currentValue == "On" ? "Off" : "On";
  }

  /// Widget to Build Availability Icon
  Widget buildAvailabilityIcon({
    // String dayLabel,
    required String? dayValue,
    required VoidCallback onToggle,
    required DayAvailability days,
    required String station,
    required bool isAlreadyAvailable
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Center(
        child: Icon(
          dayValue == "On" ? Icons.check_circle : Icons.cancel,
          //color: days.status == "On" && days.location != _args().station
          color: isAlreadyAvailable
              ? Colors.grey
              : dayValue == "On"
                  ? Colors.green
                  : Colors.red,
          size: 20,
        ),
      ),
    );
  }

  /// Helper Function to Calculate Total "On" Days
  int _calculateEmployeeTotal(Employee employee) {
    int count = 0;

    List<DayAvailability>? days = employee.availability;

    for (var day in days!) {
      if (day.status == "On" && day.location == _args().station) {
        count++;
      }
    }

    return count;
  }
}
