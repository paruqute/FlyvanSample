import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widgets/appbar_widget.dart';
import '../custom_widgets/confirm_dialog.dart';
import '../custom_widgets/cutom_text_field.dart';
import '../custom_widgets/table_column_name.dart';
import '../model/employee_model.dart';
import '../provider/employee.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';

class DriversViewScreen extends StatefulWidget {
  static const routeName = "/drivers-screen";

  const DriversViewScreen({super.key});

  @override
  State<DriversViewScreen> createState() => _DriversViewScreenState();
}

class _DriversViewScreenState extends State<DriversViewScreen> {
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  final TextEditingController countryCodeController =
      TextEditingController(text: "+1");
  final _formGlobalKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    idController = TextEditingController();
    phoneController = TextEditingController();
    nameController = TextEditingController();
    //  nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    idController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<EmployeeProvider>(
      builder: (context, driver, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              CustomAppBar(
                size: size,
                title: "Drivers",
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
                child: driver.employeeList.isNotEmpty
                    ? ListView(
                        padding: EdgeInsets.all(15),
                        shrinkWrap: true,
                        children: [
                          DataTable(
                            columnSpacing: 12.0,
                            horizontalMargin: 5.0,
                            border: TableBorder(
                              //top: BorderSide(color: Colors.grey.shade200),
                              // right: BorderSide(color: Colors.grey.shade200),
                              // left: BorderSide(color: Colors.grey.shade200),
                              bottom: BorderSide(color: Colors.grey.shade200),
                              horizontalInside:
                                  BorderSide(color: Colors.grey.shade200),
                              verticalInside:
                                  BorderSide(color: Colors.grey.shade200),
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
                                  label: TableColumnName(
                                    columnTitle: "Phone",
                                  ),
                                  headingRowAlignment: MainAxisAlignment.start),
                              DataColumn(
                                  label: TableColumnName(columnTitle: "")),
                              DataColumn(
                                  label: TableColumnName(columnTitle: "")),
                            ],
                            rows: [
                              ...driver.employeeList.map((driver) {
                                return DataRow(cells: [
                                  DataCell(TableRowText(
                                      title: driver.employeeID ?? '')),
                                  DataCell(TableRowText(
                                      title: driver.employeeName ?? '')),
                                  DataCell(GestureDetector(
                                    onTap: () async {
                                      try {
                                        final url = Uri(
                                            scheme: 'tel', path: driver.phone);
                                        if (await canLaunchUrl(url)) {
                                          launchUrl(url);
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    child:
                                        TableRowText(title: driver.phone ?? ''),
                                  )),
                                  DataCell(
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          idController.text =
                                              driver.employeeID ?? '';
                                          nameController.text =
                                              driver.employeeName ?? '';
                                          phoneController.text =
                                              driver.phone?.replaceFirst(
                                                      '+1', '') ??
                                                  '';
                                        });
                                        showAddDriverDialog(
                                          context: context,
                                          title:  "Edit Driver",
                                          buttonTitle: "Update",
                                          onPressed: () async {
                                            // add driver to firestore
                                            if (_formGlobalKey.currentState!
                                                .validate()) {
                                              if (phoneController
                                                      .text.length ==
                                                  10) {
                                                await updateEmployee();
                                              } else {
                                                ScaffoldMessenger.of(
                                                        context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Enter a valid contact number")),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size:18,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  DataCell(

                                    GestureDetector(
                                        child: Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: primaryColor,
                                        ),
                                        onTap: () async {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              return ConfirmDialog(
                                                name: "Delete ${driver.employeeName}",
                                                onPressed: () {
                                                  deleteEmployee(
                                                      employee: driver);
                                                  // delete employee
                                                },
                                              );
                                            },
                                          );
                                        }),
                                  ),
                                ]);
                              }),
                              DataRow(
                                  color: WidgetStateProperty.resolveWith(
                                      (states) =>
                                          secondaryColor.withOpacity(0.1)),
                                  cells: [
                                    DataCell(
                                      Text(
                                        "Total",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontSize: 15,
                                                color: primaryColor),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        "${driver.employeeList.length}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontSize: 15,
                                                color: primaryColor),
                                      ),
                                    ),
                                    DataCell(
                                      Text(""),
                                    ),
                                    DataCell(
                                      Text(""),
                                    ),
                                    DataCell(
                                      Text(""),
                                    ),
                                  ])
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          "No drivers available",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
              )
            ],
          ),

          // Padding(
          //   padding: const EdgeInsets.all(15.0),
          //child:
          // ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () async {
              showAddDriverDialog(
                context: context,
                buttonTitle: "Add",
                title:  "Add Driver",
                onPressed: () async {
                  // add driver to firestore
                  if (_formGlobalKey.currentState!.validate()) {
                    if (phoneController.text.length == 10) {
                      await addEmployee();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Enter a valid contact number")),
                      );
                    }
                  }
                },
              );
            },
            tooltip: "Add Driver", // Call function to show dialog
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        );
      },
    );
  }

  // Show a dialog to take note input
  void showAddDriverDialog({
    required BuildContext context,
    required void Function()? onPressed,
    required String buttonTitle,
    required String title,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: primaryColor, fontSize: 18),
          title: Text(
           title,
          ),
          content: Form(
            key: _formGlobalKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                        flex: 1,
                        child: CustomTextField(
                          textFieldController: idController,
                          labelText: "ID",
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        flex: 2,
                        child: CustomTextField(
                          textFieldController: nameController,
                          labelText: "Name",
                        )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: CustomTextField(
                        textFieldController: countryCodeController,
                        labelText: "Country",
                        readOnly: true,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      flex: 2,
                      child: CustomTextField(
                        textFieldController: phoneController,
                        keyboardType: TextInputType.number,
                        labelText: "Phone",
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                idController.clear();
                nameController.clear();
                phoneController.clear();
                Navigator.pop(context);
                }, // Close dialog
              child: Text(
                "Cancel",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: primaryColor, fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(
                buttonTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> addEmployee() async {
    Employee newEmployee = Employee(
        employeeID: idController.text, // Document ID
        employeeName: nameController.text,
        phone: countryCodeController.text + phoneController.text);

    bool success = await Provider.of<EmployeeProvider>(context, listen: false)
        .addEmployee(newEmployee);

    if (success) {
      await Provider.of<EmployeeProvider>(context, listen: false)
          .fetchEmployeeList();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${idController.text} added successfully!")),
      );
      idController.clear();
      nameController.clear();
      phoneController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Employee already exists or an error occurred.")),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> updateEmployee() async {
    Employee newEmployee = Employee(
        employeeID: idController.text, // Document ID
        employeeName: nameController.text,
        phone: countryCodeController.text + phoneController.text,
      updatedAt: DateTime.now(),
    );

    bool success = await Provider.of<EmployeeProvider>(context, listen: false)
        .updateEmployee(newEmployee);

    if (success) {
      await Provider.of<EmployeeProvider>(context, listen: false)
          .fetchEmployeeList();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${idController.text} updated successfully!")),
      );
      idController.clear();
      nameController.clear();
      phoneController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Employee not exists or an error occurred.")),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> deleteEmployee({required Employee employee}) async {
    bool success = await Provider.of<EmployeeProvider>(context, listen: false)
        .deleteEmployee(employee.employeeID ?? '');

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${idController.text} deleted successfully!")),
      );
      await Provider.of<EmployeeProvider>(context, listen: false)
          .fetchEmployeeList();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" an error occurred.")),
      );
    }
  }

// confirmation dialog
}
