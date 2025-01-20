import 'package:flutter/material.dart';
import 'package:flyvanexpress/screens/route_allocation.dart';
import 'package:flyvanexpress/screens/schedule_screen.dart';
import 'package:flyvanexpress/screens/van_view.dart';
import 'package:flyvanexpress/screens/weekly_report.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/confirm_dialog.dart';
import '../provider/employee.dart';
import '../provider/location.dart';
import '../provider/login.dart';
import '../provider/vehicle.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';
import 'drivers.dart';
import 'for_tomorrow.dart';
import 'login.dart';

class Dashboard extends StatelessWidget {
  static const routeName = "/dashboard";

  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: primaryColor,
      body: ListView(

        padding: EdgeInsets.zero,
        // shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        //scrollDirection: Axis.vertical,
        children: [
          Container(
              //height: 200,

              height:MediaQuery.of(context).size.height*0.2,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                // borderRadius: BorderRadius.only(
                //   bottomRight: Radius.circular(50),
                // ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    height: 100,
                    width: 200,
                    child: Image.asset(
                      "assets/images/flyvanlogo1.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              )),
          Container(
            height: MediaQuery.of(context).size.height*0.8,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),topRight:Radius.circular(30) ),
              image: logoBgDecorationImage(),
            ),
            child: GridView.count(
              padding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),
              shrinkWrap: true,
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 20.0,
             scrollDirection: Axis.vertical,
             // physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisCount: 2,
              children: [
                GestureDetector(
                    onTap: () {
                      Provider.of<LocationProvider>(context, listen: false)
                          .fetchStations();
                      Navigator.of(context).pushNamed(ScheduleScreen.routeName);
                    },
                    child: DashboardCardWidget(
                        icon: Icons.people, text: "Schedule")),
                GestureDetector(
                    onTap: () {
                      Provider.of<LocationProvider>(context, listen: false)
                          .fetchStations();
                      Navigator.of(context)
                          .pushNamed(ForTomorrowScreen.routeName);
                    },
                    child: DashboardCardWidget(
                        icon: Icons.calendar_today, text: "For Tomorrow")),
                GestureDetector(
                    onTap: () {
                      Provider.of<LocationProvider>(context, listen: false)
                          .fetchStations();
                      Navigator.of(context)
                          .pushNamed(RouteAllocation.routeName);
                    },
                    child: DashboardCardWidget(
                        icon: Icons.route, text: "Route Allocation")),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(WeeklyReport.routeName);
                  },
                  child: DashboardCardWidget(
                      icon: Icons.view_week, text: "Weekly Report")),
                GestureDetector(
                    onTap: ()  {
                       Provider.of<EmployeeProvider>(context, listen: false)
                          .fetchEmployeeList();
                      Navigator.of(context)
                          .pushNamed(DriversViewScreen.routeName);
                    },
                    child: DashboardCardWidget(
                      icon: Icons.nature_people,
                      text: "Drivers",
                    )),
                GestureDetector(
                    onTap: () {
                      Provider.of<VehicleProvider>(context, listen: false).fetchVehicleList();
                      Navigator.of(context)
                          .pushNamed(VanViewScreen.routeName);
                    },
                    child: DashboardCardWidget(
                      icon: Icons.directions_car,
                      text: "Vehicles",
                    )),

                GestureDetector(
                    onTap: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return ConfirmDialog(
                            name: "Logout",
                            onPressed: () async {
                             final success= await Provider.of<LoginProvider>(context, listen: false).logOut();
                             if(success){
                               Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false,);
                             }
                             else{
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text("Logout error!")),
                               );
                               Navigator.of(context).pop();
                             }
                              // delete employee
                            },
                          );
                        },
                      );
                    },
                    child: DashboardCardWidget(
                      icon: Icons.logout,
                      text: "Logout",
                    )),
              ],
            ),
          )
          // Padding(
          //   padding: const EdgeInsets.all(15.0),
          //   child: GridView.count(
          //     mainAxisSpacing: 20.0,
          //     crossAxisSpacing: 20.0,
          //     physics: NeverScrollableScrollPhysics(),
          //     childAspectRatio: 1.5,
          //     crossAxisCount: 2,
          //   children: [
          //     GestureDetector(
          //         onTap: (){
          //           Provider.of<LocationProvider>(context, listen: false).fetchStations();
          //           Navigator.of(context).pushNamed(ScheduleScreen.routeName);
          //         },
          //         child: DashboardCardWidget(text: "Schedule",)),
          //     GestureDetector(
          //         onTap: (){
          //           Provider.of<LocationProvider>(context, listen: false).fetchStations();
          //           Navigator.of(context).pushNamed(ForTomorrowScreen.routeName);
          //         },
          //         child: DashboardCardWidget(text: "For Tomorrow")),
          //     GestureDetector(
          //         onTap: (){
          //           Navigator.of(context).pushNamed(RouteAllocation.routeName);
          //         },
          //         child: DashboardCardWidget(text: "Route Allocation",)),
          //
          //
          //   ],
          //   )
          //   ),
        ],
      ),
    );
  }
}

class DashboardCardWidget extends StatelessWidget {
  const DashboardCardWidget({
    super.key,
    this.text,
    this.icon,
  });

  final String? text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 5),
                color: Theme.of(context).primaryColor.withValues(alpha:0.2),
                spreadRadius: 2,
                blurRadius: 5)
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              )),
          const SizedBox(height: 8),
          Text(text ?? '', style: Theme.of(context).textTheme.titleMedium)
        ],
      ),
    );
  }
}
