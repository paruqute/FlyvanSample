import 'package:flutter/material.dart';
import 'package:flyvanexpress/screens/route_details.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/appbar_widget.dart';
import '../provider/location.dart';
import '../provider/route_provider.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';
import '../week_methods.dart';
import 'for_tomorrow.dart';
import 'package:week_number/iso.dart';
class RouteAllocation extends StatefulWidget {
  static const routeName = "/route_allocation";

  const RouteAllocation({super.key});

  @override
  State<RouteAllocation> createState() => _RouteAllocationState();
}

class _RouteAllocationState extends State<RouteAllocation> {
  late TextEditingController routeFieldController;

  List<String> routeList = [];
  List<String>? vanList = ["v1", "v2", "v3", "v4", "v5"];
  String? selectedVan;
  String selectedStation = " ";
  bool isSavingData = false;

  // String? selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
  void initState() {
    routeFieldController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    routeFieldController.dispose();
    // TODO: implement dispose
    super.dispose();
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
              title: "Route Allocation",
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(20),
                height: size.height * 0.85,
                decoration: BoxDecoration(
                    color: Colors.white,
                    image: logoBgDecorationImage(),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: ListTile(
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
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                        height: 100,
                        child: Consumer<LocationProvider>(
                          builder: (context, station, child) {
                            return ListView.builder(
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
                                      selectedStation =
                                          station.stationList[index].name!;
                                    });
                                  },
                                );
                              },
                            );
                          },
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedStation != " ") {
                          setState(() {
                            isSavingData = true;
                          });



                         await Provider.of<RouteProvider>(context, listen: false)
                              .fetchUnallocatedEmployees(
                                  location: selectedStation,
                                   date: DateFormat('yyyy-MM-dd').format(selectedDate),
                                   week:  "${selectedDate.weekNumber}",
                                   year: getYearFromWeek(selectedDate).toString());

                          await Provider.of<RouteProvider>(
                              context,
                              listen: false)
                              .fetchRoutesByDate(
                            year:getYearFromWeek(selectedDate).toString() ,
                              week: "${selectedDate.weekNumber}",
                              location: selectedStation,
                              date: DateFormat('yyyy-MM-dd')
                                  .format(selectedDate));

                          await Provider.of<RouteProvider>(context, listen: false)
                              .fetchAvailableVan().then((value) =>   Navigator.of(context).pushNamed(
                              RouteDetails.routeName,
                              arguments: RouteDetails(
                                week: "${selectedDate.weekNumber}",
                                location: selectedStation,
                                date: DateFormat('yyyy-MM-dd')
                                    .format(selectedDate),
                                day: getDay(selectedDate.weekday),
                                year: getYearFromWeek(selectedDate).toString(),
                              )),);
                          setState(() {
                            isSavingData = false;
                          });

                          // Provider.of<LocationProvider>(context, listen: false)
                          //     .fetchEmployeesWithDefaultAvailability(
                          //     location: selectedStation,
                          //     year: year.toString(),
                          //     week: "Week$selectedWeek")
                          //     .then(
                          //       (value) {
                          //     setState(() {
                          //       isSavingData=false;
                          //     });
                          //     Navigator.of(context).pushNamed(
                          //         EmployeeAvailabilityScreen.routeName,
                          //         arguments: EmployeeAvailabilityScreen(
                          //             year: year,
                          //             week: selectedWeek,
                          //             station: selectedStation)).then;
                          //   },
                          // );
                        }
                        // else{
                        //    Fluttertoast.showToast(
                        //     msg: "Select station",
                        //     toastLength: Toast.LENGTH_SHORT, // Toast.LENGTH_SHORT or Toast.LENGTH_LONG
                        //      // Position: TOP, BOTTOM, CENTER
                        //     backgroundColor: Colors.black,
                        //     textColor: Colors.white,
                        //     fontSize: 16.0,
                        //   );
                        //
                        // }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Next"),
                          SizedBox(
                            width: 5,
                          ),
                          isSavingData
                              ? SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ))
                              : SizedBox()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
// TextField(
// controller: routeFieldController,
// decoration: InputDecoration(hintText: "Routes"),
// ),
// ElevatedButton(
// onPressed: () {
// setState(() {
// routeList.add(routeFieldController.text);
// });
// },
// child: Text("Submit"),
// ),
// SizedBox(
// height: 20,
// ),
// Expanded(
// // height: 200,
// // width: double.infinity,
// child: routeList.isNotEmpty
// ? ListView.builder(
// physics: NeverScrollableScrollPhysics(),
// shrinkWrap: true,
// itemCount: routeList.length,
// itemBuilder: (context, index) {
// return Column(
// // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
// children: [
// Text("1${routeList[index]}"),
// DropdownButton<String>(
// value: selectedVan,
// hint: const Text('Select an item'),
// isExpanded: true,
// items: vanList?.map((String item) {
// return DropdownMenuItem(
// value: item,
// child: Text(item),
// );
// }).toList(),
// onChanged: (String? newValue) {
// setState(() {
// selectedVan = newValue;
// });
// },
// ),
// ],
// );
// },
// )
// : SizedBox.shrink())
