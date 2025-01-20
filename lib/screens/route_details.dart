import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dtp;


import 'package:provider/provider.dart';

import '../custom_widgets/appbar_widget.dart';
import '../custom_widgets/custom_dropdown.dart';
import '../custom_widgets/cutom_text_field.dart';
import '../custom_widgets/table_column_name.dart';
import '../model/employee_model.dart';
import '../model/route_model.dart';
import '../model/vehicle.dart';
import '../provider/route_provider.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';

class RouteDetails extends StatefulWidget {
  static const routeName = "/routeDetails";

  const RouteDetails(
      {super.key, this.year, this.location, this.week, this.date, this.day});

  final String? location;
  final String? date;
  final String? year;
  final String? week;
  final String? day;

  @override
  State<RouteDetails> createState() => _RouteDetailsState();
}

class _RouteDetailsState extends State<RouteDetails> {
  RouteDetails _args() {
    final args = ModalRoute
        .of(context)!
        .settings
        .arguments as RouteDetails;
    return args;
  }

  List<Employee>? availableEmployees = []; // Fetched from Firestore
  List<Vehicle>? availableVanList = []; // Fetched from Firestore

  //List<RouteModel> assignedRoutes = []; // Assigned locally

  late TextEditingController routeTextFieldController;
  late TextEditingController timeRouteFieldController;

  String? dropdownEmployeeID;
  String? selectedEmployeeName;
  Employee? employeeData;
  String? vanDropDown;
  bool isSave = false;
  bool isSaveNote = false;

  // fetch available employees in a list availableEmployees from firestore
  Future<List<Employee>?> fetchAvailableEmployeeToday() async {
    try {
      List<Employee>? employees = [];
      employees = Provider
          .of<RouteProvider>(context, listen: false)
          .unAllocatedEmployeeList;
      setState(() {
        availableEmployees = employees; // Initialize the local list
      });
      return availableEmployees;
    } catch (e) {
      print("error in fetching available employees $e");
    }
    return null;
  }

  // fetch van

  Future<List<Vehicle>?> fetchAvailableVan() async {
    List<Vehicle>? vanList = [];
    vanList = Provider
        .of<RouteProvider>(context, listen: false)
        .vanList;

    setState(() {
      availableVanList = vanList; // Initialize the local list
    });
    return availableVanList;
  }

// assign routes
//   void assignRouteLocally(RouteModel routeModel) {
//     setState(() {
//       // Add the route to the local list
//       assignedRoutes.add(routeModel);
//
//       // // Remove the assigned employee from the available list
//       // availableEmployees?.removeWhere(
//       //     (employee) => employee.employeeID == routeModel.employeeId);
//       //
//       // //Remove the assigned van from the available list
//       // availableVanList?.removeWhere(
//       //   (van) => van.vanName == routeModel.van,
//       // );
//       print("Assigned ${routeModel.employee} to ${routeModel.route} locally.");
//     });
//   }

  // save all routes

//To ensure the list excludes employees already assigned locally, filter the availableEmployees dynamically:

  // List<Employee>? getFilteredAvailableEmployees() {
  //   return availableEmployees?.where((employee) {
  //     return !assignedRoutes
  //         .any((route) => route.employeeId == employee.employeeID);
  //   }).toList();
  // }

  // List<Van>? getFilteredAvailableVan() {
  //   return availableVanList?.where((van) {
  //     return !assignedRoutes.any((route) => route.van == van.vanName);
  //   }).toList();
  // }
  DateTime? pickedTime;
  String? selectedTime;
  final _formGlobalKey = GlobalKey<FormState>();
  Vehicle? selectedVan;
  String? selectedRouteType;  // Default selection
  @override
  void initState() {
    // TODO: implement initState
    routeTextFieldController = TextEditingController();
    timeRouteFieldController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    routeTextFieldController.dispose();
    timeRouteFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Consumer<RouteProvider>(
      builder: (context, routeValue, child) {
        return Scaffold(
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          body: ListView(
            shrinkWrap: true,
            //scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            children: [
              CustomAppBar(
                size: size,
                title: "Routes",
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
                  padding: EdgeInsets.all(15),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      trailing: Text(
                        " ${_args().location}",
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: primaryColorOpacity,
                            fontSize: 18),
                      ),
                      leading: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Week ${_args().week}",
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                color: primaryColorOpacity),
                          ),
                          //  SizedBox(height: 5,),
                          Text(
                            "${_args().date}",
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                color: primaryColorOpacity),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Assign Route: ",
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: primaryColor),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _formGlobalKey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              textFieldController: routeTextFieldController,
                              labelText: "Route",
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: CustomTextField(
                              readOnly: true,
                              textFieldController: timeRouteFieldController,
                              onTap: () async {
                              await dtp.DatePicker.showTimePicker(
                                context,
                                  theme: dtp.DatePickerTheme(
                                    doneStyle:Theme
                                        .of(context)
                                        .textTheme
                                        .titleMedium
                                        !.copyWith(color: primaryColor, fontSize: 14),
                                    cancelStyle: Theme
                                        .of(context)
                                        .textTheme
                                        .titleMedium
                                    !.copyWith(color: primaryColor, fontSize: 14),
                                  ),
                                  showTitleActions:true,
                                showSecondsColumn: false,
                                onChanged: (time) {
                                 pickedTime = time;
                                 selectedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                              },

                                onConfirm: (time) {
                                  // Confirm selection
                                  setState(() {
                                    selectedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                                  });
                                },
                                currentTime: DateTime.now(),
                              );
                                if (selectedTime != null) {
                                  // Format the time and set it to the controller
                                  //final String formattedTime = pickedTime.format(context);
                                  setState(() {
                                    timeRouteFieldController.text = selectedTime??'';
                                  });
                                }
                              },
                              labelText: "Estimated Time",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: CustomDropDown(
                            value: dropdownEmployeeID,
                            items:
                            routeValue.unAllocatedEmployeeList?.map((employee) {
                              return DropdownMenuItem(
                                value: employee.employeeID,
                                child: Text(employee.employeeName ?? ''),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                dropdownEmployeeID = value;
                                print(".........$dropdownEmployeeID");
                                // Ensure dropdownEmployeeID matches an available item
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),

                        Expanded(
                          child: CustomDropDown(
                            value: vanDropDown,
                            items: [
                              DropdownMenuItem(
                                value: "Own",
                                child: Text("Own"),  // Static value at the top
                              ),
                              ...?routeValue.availableVanList?.map((van) {
                                return DropdownMenuItem(
                                  value: van.registrationNumber,
                                  child: Text('${van.vehicleName}_${van.owner}'),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                vanDropDown = value;

                                print(".................$vanDropDown");
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex:1,
                          child: Text(
                            "Route Type: ",
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: primaryColor),
                          ),
                        ),
                        // Van Radio Button
                        Flexible(
                          flex: 1,
                          child: RadioListTile(

                            contentPadding: EdgeInsets.zero,
                            activeColor: primaryColor,
                            title: Text('Van',  style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: primaryColor),
                            ),
                            value: 'Van',
                            groupValue: selectedRouteType,
                            onChanged: (value) {
                              setState(() {
                                selectedRouteType = value.toString();
                              });
                            },
                          ),
                        ),

                        // Cargo Radio Button
                        Flexible(
                          flex: 1,
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,

                            activeColor: primaryColor,
                            title: Text('Cargo',style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: primaryColor),),
                            value: 'Cargo',
                            groupValue: selectedRouteType,
                            onChanged: (value) {
                              setState(() {
                                selectedRouteType = value.toString();
                              });
                            },
                          ),
                        ),


                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // print(
                        //     "..................$dropdownEmployeeID  $vanDropDown");
                      if(_formGlobalKey.currentState!.validate() ){
                        if(dropdownEmployeeID!=null && vanDropDown!=null && selectedRouteType!=null){

                          final List<Employee> filteredEmployees = routeValue
                              .unAllocatedEmployeeList
                              ?.where((employee) =>
                          employee.employeeID == dropdownEmployeeID)
                              .toList() ??
                              [];

                          final Employee selectedEmployee =
                              filteredEmployees.first;


                          if(vanDropDown!= "Own"){
                            final List<Vehicle> filteredVans = routeValue
                                .availableVanList
                                ?.where((van) =>
                            van.registrationNumber == vanDropDown)
                                .toList() ??
                                [];
                            selectedVan = filteredVans.first;
                          }


                          // if (filteredEmployees.isEmpty) {
                          //   print("No employee selected!");
                          //   return;
                          // }


                          // if (selectedEmployee != null) {
                          //   print(
                          //       "Selected Employee ID: ${selectedEmployee.employeeID}, Name: ${selectedEmployee.employeeName}");
                          // } else {
                          //   print("No employee selected!");
                          // }
                          // Assign the route locally
                          RouteModel routeModel = RouteModel(
                              date: _args().date,
                              route: routeTextFieldController.text,
                              vehicleRegNum: selectedVan?.registrationNumber,
                              week: _args().week,
                              employee: selectedEmployee.employeeName,
                              employeeId: selectedEmployee.employeeID,
                              location: _args().location,
                              year: _args().year,
                              vehicleName: vanDropDown !="Own"?"${selectedVan?.vehicleName}_${selectedVan?.owner}":vanDropDown,
                            routeType: selectedRouteType,
                            time: selectedTime

                          );

                          saveSingleRoute(context, routeModel);

                          print(
                              "........${routeValue.assignedRouteList
                                  ?.length}.......${routeModel.employee}");
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("You missed one field")),
                          );

                        }

                      }
                      },
                      child: Text("Add"),
                    ),


                    SizedBox(height: 20),

                    /// showing after route added
                    isSave
                        ? Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 1,
                        ))
                        : routeValue.assignedRouteList!.isNotEmpty
                        ? Column(
                      children: [
                        DataTable(

                          columnSpacing: 8.0,
                          horizontalMargin: 10.0,
                          border: TableBorder(
                            horizontalInside: BorderSide(
                                color: Colors.grey.shade200),
                            verticalInside: BorderSide(
                                color: Colors.grey.shade200),
                          ),
                          columns: [
                            DataColumn(
                              label: TableColumnName(
                                columnTitle: "Route",
                              ),
                            ),
                            DataColumn(
                                label: TableColumnName(
                                  columnTitle: "Driver",
                                )),
                            DataColumn(
                                label: TableColumnName(
                                    columnTitle: "Time")),
                            DataColumn(
                                label: TableColumnName(
                                    columnTitle: "vehicle")),
                            DataColumn(
                                label: TableColumnName(
                                    columnTitle: "Type")),
                            DataColumn(
                                label:
                                TableColumnName(columnTitle: "")),
                          ],
                          rows: [
                            ...?routeValue.assignedRouteList
                                ?.map((route) {
                              return DataRow(

                                  cells: [
                                    DataCell(
                                      TableRowText(title: route.route ?? "",),
                                    ),
                                    DataCell(
                                      TableRowText(title:route.employee ?? "",),
                                    ),
                                    DataCell(
                                      TableRowText(title: route.time??'',),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width:85,
                                        child: TableRowText(title:"${route.vehicleName}",),
                                      ),
                                    ),
                                    DataCell(
                                      TableRowText(title:route.routeType ?? "",
                                      ),
                                    ),
                                    DataCell(GestureDetector(
                                      child: Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: primaryColor,
                                      ),
                                      onTap: () {
                                        deleteSingleRoute(
                                            context: context,
                                            routeModel:
                                            route); // delete route
                                      },
                                    )),
                                  ]);
                            }),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Copy all route details to the clipboard
                              final allNames = [
                                '`Good Morning Team ${_args()
                                    .location}`\n\n*Driver List*\n',
                                ...?routeValue.assignedRouteList?.map(
                                        (e) =>
                                    '- ${e.employeeId} - ${e.employee} - ${e
                                        .route}  - ${e.vehicleName??"Own"}')
                              ].join(
                                  "\n"); // Combine names with newline
                              Clipboard.setData(ClipboardData(
                                text: allNames,
                              ));

                              // Show a confirmation message
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Driver list copied to clipboard!')),
                              );
                            },
                            child: Text("Copy"),
                          ),
                        ),
                      ],
                    )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme
                .of(context)
                .primaryColor,
            onPressed: () async {
              String? savedNotes = await Provider.of<RouteProvider>(context, listen: false)
                  .fetchNotesForDate(
                year: _args().year??'',
                  week: _args().week ?? '', date: _args().date ?? '');
              showAddNoteDialog(savedNotes: savedNotes);
            },
            tooltip: "Add Notes", // Call function to show dialog
            child: Icon(
              Icons.note_add,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Future<void> saveSingleRoute(BuildContext context,
      RouteModel routeModel) async {
    setState(() {
      isSave = true;
    });
    try {
      await Provider.of<RouteProvider>(context, listen: false)
          .addSingleRoute(
          year: _args().year??'',
          week:"${ _args().week}",
          date: _args().date ?? "",
          route: routeModel)
          .then(
            (value) async {
          setState(() {
            routeTextFieldController.clear();
            dropdownEmployeeID = null;
            vanDropDown = null;
            timeRouteFieldController.clear();
            selectedVan = null;
          });
          await Provider.of<RouteProvider>(context, listen: false)
              .fetchAvailableVan();
          await Provider.of<RouteProvider>(context, listen: false)
              .fetchUnallocatedEmployees(
             location:  _args().location ?? '',
             date:  _args().date ?? '',
            week:   "${_args().week}" ,
           year:    _args().year??'');
          await Provider.of<RouteProvider>(context, listen: false)
              .fetchRoutesByDate(
            year:_args().year??'' ,
              location: _args().location ?? '',
              week: _args().week ?? '',
              date: _args().date ?? '');
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Route ${routeModel.route} saved successfully!")),
      );
    } catch (e) {
      print("Error saving route: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving route: $e")),
      );
    } finally {
      setState(() {
        isSave = false;
      });
    }
  }

  // delete assigned route

  Future<void> deleteSingleRoute(
      {required BuildContext context, required RouteModel routeModel}) async {
    setState(() {
      isSave = true;
    });
    try {
      await Provider.of<RouteProvider>(context, listen: false)
          .deleteSingleRoute(
        week:  "${_args().week}",
          year: _args().year??'',
        date: _args().date ?? "",
        route: routeModel,
      )
          .then(
            (value) async {
          // await Provider.of<RouteProvider>(context, listen: false)
          //     .fetchAvailableVan();
          // await Provider.of<RouteProvider>(context, listen: false)
          //     .fetchAvailableEmployees(
          //     _args().location ?? '',
          //     _args().date ?? '',
          //     _args().day ?? '',
          //     _args().week ?? "",
          //     _args().year);
          // await Provider.of<RouteProvider>(context, listen: false)
          //     .fetchRoutesByDate(
          //     location: _args().location ?? '',
          //     week: _args().week ?? '',
          //     date: _args().date ?? '');
        },
      );
      setState(() {
        isSave = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Route ${routeModel.route} deleted successfully!")),
      );
    } catch (e) {
      print("Error deleting route: $e");
      setState(() {
        isSave = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting route: $e")),
      );
    }
  }

  // Show a dialog to take note input
  void showAddNoteDialog({String? savedNotes}) {
    final TextEditingController notesController =
    TextEditingController(text: savedNotes);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: Theme
              .of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: primaryColor, fontSize: 18),
          title: Text(
            "Add Notes",
          ),
          content: TextField(
            style: Theme
                .of(context)
                .textTheme
                .titleMedium
            ,
            controller: notesController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Enter notes here...",
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.2))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel", style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: primaryColor, fontSize: 12),),
            ),
            ElevatedButton(
              onPressed: () {
                addNote(context: context, noteTextController: notesController);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Save", style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white, fontSize: 12),),
                  SizedBox(
                    width: 5,
                  ),
                  isSaveNote
                      ? SizedBox(
                      height: 10,
                      width: 10,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ))
                      : SizedBox()
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> addNote({required BuildContext context,
    required TextEditingController noteTextController}) async {
    setState(() {
      isSaveNote = true;
    });
    try {
      // Add or update the notes
      await Provider.of<RouteProvider>(context, listen: false).addOrUpdateNotes(
          year: _args().year??'',
        week: _args().week ?? '',
        date: _args().date ?? '',
        notes: noteTextController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Note saved!")),
      );
    } catch (e) {
      print("Error saving route: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving route: $e")),
      );
    } finally {
      setState(() {
        Navigator.of(context).pop(); // Close the dialog
        isSaveNote = false;
      });
    }
  }
}
