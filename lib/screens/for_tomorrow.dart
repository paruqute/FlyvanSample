import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:week_number/iso.dart';

import '../custom_widgets/appbar_widget.dart';
import '../custom_widgets/table_column_name.dart';
import '../model/employee_model.dart';
import '../model/station_model.dart';
import '../provider/employee.dart';
import '../provider/location.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';
import '../week_methods.dart';

class ForTomorrowScreen extends StatefulWidget {
  static const routeName = "/for_tomorrow";

  const ForTomorrowScreen({super.key});

  @override
  State<ForTomorrowScreen> createState() => _ForTomorrowScreenState();
}

class _ForTomorrowScreenState extends State<ForTomorrowScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<LocationProvider>(context, listen: false).fetchStations();
    super.initState();
  }

  List<Employee> tomorrowsList = [];
  String? selectedStation;
  DateTime selectedDate = DateTime.now();

  Future<void> selectDate(BuildContext context) async {
    final DateTime datePicked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    ) ??
        selectedDate;

    if (datePicked != selectedDate) {
      setState(() {
        selectedDate = datePicked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            CustomAppBar(
              size: size,
              title: "For Tomorrow",
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
                padding: EdgeInsets.all(20),
                shrinkWrap: true,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Select Date:",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: primaryColor),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: primaryColor),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        IconButton(
                          onPressed: () {
                            selectDate(context);
                          },
                          icon: Icon(Icons.calendar_month),
                          color: primaryColor,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      "Select station",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: primaryColor),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Consumer<LocationProvider>(
                    builder: (context, station, child) {
                      return Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: ListView.builder(

                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: station.stationList.length,
                          itemBuilder: (context, index) {
                            return StationWidget(
                              selectedStation: selectedStation,
                              station: station.stationList[index],
                             onTap: () {
                              setState(() {
                                selectedStation = station.stationList[index].name!;
                              });
                            },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  selectedStation != null
                      ? FutureBuilder(
                        future: Provider.of<EmployeeProvider>(context,
                                listen: false)
                            .fetchAvailableEmployeesInDate(
                               date: selectedDate.toString(),
                          location: selectedStation??'',
                          week: selectedDate.weekNumber.toString(),
                          year: getYearFromWeek(selectedDate).toString(),


                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 2,
                            ));
                          } else {
                            if (snapshot.hasData) {
                              tomorrowsList = snapshot.data!;
                              print(
                                  "listLength....................${snapshot.data!.length}");
                              return tomorrowsList.isNotEmpty
                                  ? Column(

                                      children: [
                                        DataTable(
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
                                          columns: [
                                            DataColumn(label: TableColumnName(columnTitle: "ID",),headingRowAlignment: MainAxisAlignment.start),
                                            DataColumn(label: TableColumnName(columnTitle: "Driver",),headingRowAlignment: MainAxisAlignment.start),

                                          ],
                                          rows: [
                                            ...tomorrowsList
                                                .map((driver) {


                                              return DataRow(cells: [
                                                DataCell(
                                                  TableRowText(title:driver.employeeID ?? "",),
                                                ),
                                                DataCell(
                                                  TableRowText(title:driver.employeeName ?? "",),
                                                ),
                                              ]);
                                            }),

                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.all(16.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Copy all names to the clipboard
                                              final allNames = [
                                                '*For Tomorrow*\n',
                                                ...tomorrowsList.map((e) =>
                                                    '- ${e.employeeID} - ${e.employeeName}')
                                              ].join(
                                                  "\n"); // Combine names with newline
                                              Clipboard.setData(
                                                  ClipboardData(
                                                text: allNames,
                                              ));

                                              // Show a confirmation message
                                              ScaffoldMessenger.of(
                                                      context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Driver details copied to clipboard!')),
                                              );
                                            },
                                            child: Text('Copy'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                          "No employees available in $selectedStation"));
                            }
                          }
                          return Center(
                              child: Text(snapshot.error.toString()));
                        },
                      )
                      : SizedBox()
                ],
              ),
            )
          ],
        )

        // Padding(
        //   padding: const EdgeInsets.all(20.0),
        //child:
        // ),
        );
  }
}

class StationWidget extends StatelessWidget {
  const StationWidget({
    super.key,
    required this.selectedStation,
    this.station,
    required this.onTap,
  });

  final String? selectedStation;
  final Station? station;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 25, bottom: 20),
        height: 50,
        width: 100,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 5),
                  color: Theme.of(context).primaryColor.withOpacity(.2),
                  spreadRadius: 2,
                  blurRadius: 5)
            ],
            borderRadius: BorderRadius.circular(20),
            color:
                selectedStation == station?.name ? primaryColor.withOpacity(0.8) : Colors.white,
            border: Border.all(color: primaryColor)),

        child: Center(
          child: Text(
            station?.name ?? "",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selectedStation == station?.name
                    ? Colors.white
                    : primaryColor),
          ),
        ),
      ),
    );
  }
}

