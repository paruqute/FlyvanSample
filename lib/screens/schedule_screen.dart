import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:week_number/iso.dart';

import '../custom_widgets/appbar_widget.dart';
import '../provider/location.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';
import '../week_methods.dart';
import 'employee_availability.dart';
import 'for_tomorrow.dart';

class ScheduleScreen extends StatefulWidget {
  static const routeName = "/schedule-screen";

  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedWeek = DateTime.now().weekNumber;
  int year = DateTime.now().year;
  String selectedStation = " ";
  bool isSavingData = false;

  @override
  void initState() {
    Provider.of<LocationProvider>(context, listen: false).fetchStations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          CustomAppBar(size: size,title:  "Schedule",),
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
                  )
              ),
              child:Column(
               // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Select Year:",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: primaryColor),
                          ),
                          SizedBox(height: 20),
                          Container(

                            // decoration: BoxDecoration(
                            //   border: Border.all(color: primaryColor),),
                            child: DropdownButton<int>(
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: primaryColor),
                              underline: SizedBox.shrink(),
                              elevation: 0,
                              value: year,
                              items: List.generate(10, (index) {
                                int year = DateTime.now().year + index - 5; // 5 years before and after current year
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  year = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Select Week Number:",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: primaryColor),
                          ),
                          SizedBox(height: 20),
                          Container(

                            // decoration: BoxDecoration(
                            //   border: Border.all(color: primaryColor),),
                            child: DropdownButton<int>(

                                underline: SizedBox.shrink(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: primaryColor),
                              value: selectedWeek,
                              items: List.generate(getIsoWeeksInYear(year),
                                      (index) => index + 1) // Max 53 weeks in a year
                                  .map((week) => DropdownMenuItem(
                                value: week,
                                child: Text("Week $week"),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedWeek = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
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
                                    selectedStation = station.stationList[index].name!;
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

                        await Provider.of<LocationProvider>(context, listen: false).fetchAvailabilityCount(
                            location: selectedStation,
                            year: year.toString(),
                            week: "$selectedWeek"
                        );
                        await Provider.of<LocationProvider>(context, listen: false)
                            .fetchEmployeesWithAvailability(
                            location: selectedStation,
                            year: year.toString(),
                            week: "$selectedWeek")
                            .then(
                              (value) {
                                setState(() {
                                  isSavingData=false;
                                });
                            Navigator.of(context).pushNamed(
                                EmployeeAvailabilityScreen.routeName,
                                arguments: EmployeeAvailabilityScreen(
                                    year: year,
                                    week: selectedWeek,
                                    station: selectedStation));
                          },
                        );
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
              ) ,
            ),
          )
        ],
      )


      // Padding(
      //   padding: const EdgeInsets.all(15.0),
        //child:
      // ),
    );
  }
}
