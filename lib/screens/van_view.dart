import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/appbar_widget.dart';
import '../custom_widgets/confirm_dialog.dart';
import '../custom_widgets/cutom_text_field.dart';
import '../custom_widgets/table_column_name.dart';
import '../model/vehicle.dart';
import '../provider/vehicle.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';

class VanViewScreen extends StatefulWidget {
  static const routeName = "/van-screen";

  const VanViewScreen({super.key});

  @override
  State<VanViewScreen> createState() => _VanViewScreenState();
}

class _VanViewScreenState extends State<VanViewScreen> {
  final _formGlobalKey = GlobalKey<FormState>();
  late TextEditingController regNumberController;
  late TextEditingController ownerController;
  late TextEditingController vinController;
  late TextEditingController yearController;
  late TextEditingController nameController;
  late TextEditingController modelController;

  File? regFile;
  File? insuranceFile;
  String? regFileName;
  String? insuranceFileName;

  @override
  void initState() {
    Provider.of<VehicleProvider>(context, listen: false).fetchVehicleList();
    regNumberController = TextEditingController();
    ownerController = TextEditingController();
    vinController = TextEditingController();
    yearController = TextEditingController();
    modelController = TextEditingController();
    nameController = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    regNumberController.dispose();
    ownerController.dispose();
    vinController.dispose();
    yearController.dispose();
    modelController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<VehicleProvider>(
      builder: (context, van, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              CustomAppBar(
                size: size,
                title: "Van",
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
                child: van.vehicleList != null
                    ? ListView(
                        padding: EdgeInsets.all(15),
                        shrinkWrap: true,
                        children: [
                          DataTable(
                            columnSpacing: 12.0,
                            horizontalMargin: 5.0,
                            border: TableBorder(
                              // top: BorderSide(color: Colors.grey.shade200),
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
                                    columnTitle: "Reg No.",
                                  ),
                                  headingRowAlignment: MainAxisAlignment.start),
                              DataColumn(
                                  label: TableColumnName(
                                    columnTitle: "Name",
                                  ),
                                  headingRowAlignment: MainAxisAlignment.start),
                              // DataColumn(
                              //     label: TableColumnName(
                              //       columnTitle: "VIN No.",
                              //     ),
                              //     headingRowAlignment: MainAxisAlignment.start),
                              DataColumn(
                                  label: TableColumnName(
                                    columnTitle: "Model",
                                  ),
                                  headingRowAlignment: MainAxisAlignment.start),
                              DataColumn(
                                  label: TableColumnName(columnTitle: "")),
                              DataColumn(
                                  label: TableColumnName(columnTitle: "")),
                            ],
                            rows: [
                              ...?van.vehicleList?.map((vehicle) {
                                return DataRow(cells: [
                                  DataCell(TableRowText(
                                      title: vehicle.registrationNumber ?? '')),
                                  DataCell(SizedBox(
                                    width:85,
                                    child: TableRowText(
                                        title:
                                            "${vehicle.vehicleName}_${vehicle.owner}"),
                                  )),
                                  // DataCell(TableRowText(
                                  //     title: vehicle.vinNumber ?? '')),
                                  DataCell(
                                      TableRowText(title: vehicle.model ?? '')),

                                  DataCell(
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          yearController.text =
                                              vehicle.year ?? '';
                                          modelController.text =
                                              vehicle.model ?? '';
                                          vinController.text =
                                              vehicle.vinNumber ?? '';
                                          regNumberController.text =
                                              vehicle.registrationNumber ?? '';
                                          nameController.text =
                                              vehicle.vehicleName ?? '';
                                          ownerController.text =
                                              vehicle.owner ?? '';
                                        });
                                        addVanDialog(
                                          context: context,
                                          title: "Edit Vehicle",
                                          buttonTitle: "Update",
                                          onPressed: () async {
                                            // add driver to firestore

                                            if (_formGlobalKey.currentState!
                                                .validate()) {
                                              // if (regFile != null && insuranceFile != null) {
                                              //
                                              // } else {
                                              //   ScaffoldMessenger.of(context).showSnackBar(
                                              //     SnackBar(content: Text("Upload file")),
                                              //   );
                                              // }
                                              Vehicle? vehicle = Vehicle(
                                                updatedAt: DateTime.now(),
                                                year: yearController.text,
                                                model: modelController.text,
                                                vinNumber: vinController.text,
                                                registrationNumber:
                                                    regNumberController.text,
                                                vehicleName:
                                                    nameController.text,
                                                owner: ownerController.text,
                                              );
                                              updateVehicle(
                                                  vehicle: vehicle,
                                                  registrationFile: regFile,
                                                  insurance: insuranceFile);
                                              Navigator.of(context)
                                                  .pop(); // add vehicles
                                            }
                                          },
                                        );
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size: 18,
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
                                                name: vehicle.vehicleName,
                                                onPressed: () {
                                                  deleteVehicle(
                                                      vehicle: vehicle);
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
                                        "${van.vehicleList?.length}",
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
                          "No vehicles available",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () async {
              addVanDialog(
                context: context,
                title: "Add Vehicle",
                buttonTitle: "Add",
                onPressed: () async {
                  // add driver to firestore
                  if (_formGlobalKey.currentState!.validate()) {
                    // if (regFile != null && insuranceFile != null) {
                    //
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(content: Text("Upload file")),
                    //   );
                    // }
                    Vehicle? vehicle = Vehicle(
                      year: yearController.text,
                      model: modelController.text,
                      vinNumber: vinController.text,
                      registrationNumber: regNumberController.text,
                      vehicleName: nameController.text,
                      owner: ownerController.text,
                    );
                    addVehicle(
                        vehicle: vehicle,
                        registrationFile: regFile,
                        insurance: insuranceFile);
                    Navigator.of(context).pop(); // add vehicles
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

          // Padding(
          //   padding: const EdgeInsets.all(15.0),
          //child:
          // ),
        );
      },
    );
  }

  Future<dynamic> addVanDialog({
    required BuildContext context,
    required void Function()? onPressed,
    required String buttonTitle,
    required String title,
  }) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              titleTextStyle: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: primaryColor, fontSize: 18),
              title: Text(
                title,
              ),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Form(
                  key: _formGlobalKey,
                  child: Column(
                    spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        textFieldController: nameController,
                        labelText: "Name",
                      ),
                      CustomTextField(
                        textFieldController: ownerController,
                        labelText: "Owner",
                      ),
                      CustomTextField(
                        textFieldController: yearController,
                        labelText: "Year",
                      ),
                      CustomTextField(
                        textFieldController: modelController,
                        labelText: "Model",
                      ),
                      CustomTextField(
                        textFieldController: regNumberController,
                        labelText: "Reg No.",
                      ),
                      CustomTextField(
                        textFieldController: vinController,
                        keyboardType: TextInputType.text,
                        labelText: "VIN No.",
                      ),
                      // Row(
                      //   spacing: 10,
                      //   mainAxisAlignment:
                      //       MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Expanded(
                      //       child: Container(
                      //         padding: EdgeInsets.all(10),
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.zero,
                      //             border: Border.all(
                      //               color:
                      //                   primaryColor.withOpacity(0.3),
                      //               // Default border color
                      //               width: 1.0,
                      //             )),
                      //         child: Center(
                      //             child: GestureDetector(
                      //           onTap: () async {
                      //             FilePickerResult? result =
                      //                 await FilePicker.platform
                      //                     .pickFiles(
                      //               type: FileType.custom,
                      //               allowedExtensions: ['pdf', 'doc'],
                      //             );
                      //
                      //             if (result != null &&
                      //                 result.files.single.path !=
                      //                     null) {
                      //               setState(() {
                      //                 insuranceFile = File(
                      //                     result.files.single.path!);
                      //                 insuranceFileName =
                      //                     result.files.single.name;
                      //               });
                      //               print(
                      //                   ".................insurance........................... $insuranceFileName");
                      //             } else {
                      //               print("File selection canceled");
                      //             }
                      //           },
                      //           child: Text(
                      //             insuranceFile == null
                      //                 ? "Upload Insurance"
                      //                 : insuranceFileName ?? '',
                      //             softWrap: true,
                      //             maxLines: 2,
                      //             textAlign: TextAlign.center,
                      //             // Centers text horizontally if wrapping occurs
                      //             overflow: TextOverflow.ellipsis,
                      //             style: Theme.of(context)
                      //                 .textTheme
                      //                 .titleMedium
                      //                 ?.copyWith(
                      //                     color: insuranceFile == null
                      //                         ? primaryColor
                      //                             .withOpacity(0.3)
                      //                         : primaryColor),
                      //           ),
                      //         )),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Container(
                      //         padding: EdgeInsets.all(10),
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.zero,
                      //             border: Border.all(
                      //               color:
                      //                   primaryColor.withOpacity(0.3),
                      //               // Default border color
                      //               width: 1.0,
                      //             )),
                      //         child: GestureDetector(
                      //           onTap: () async {
                      //             FilePickerResult? result =
                      //                 await FilePicker.platform
                      //                     .pickFiles(
                      //               type: FileType.custom,
                      //               allowedExtensions: ['pdf', 'doc'],
                      //             );
                      //
                      //             if (result != null &&
                      //                 result.files.single.path !=
                      //                     null) {
                      //               setState(() {
                      //                 regFile = File(result.files.single.path!);
                      //                 regFileName = result.files.single.name;
                      //               });
                      //             } else {
                      //               print("File selection canceled");
                      //             }
                      //           },
                      //           child: Text(
                      //             regFile == null
                      //                 ? "Upload Registration"
                      //                 : regFileName ?? '',
                      //             softWrap: true,
                      //             textAlign: TextAlign.center,
                      //             // Centers text horizontally if wrapping occurs
                      //             overflow: TextOverflow.ellipsis,
                      //             maxLines: 2,
                      //             style: Theme.of(context)
                      //                 .textTheme
                      //                 .titleMedium
                      //                 ?.copyWith(
                      //                     color: regFile == null
                      //                         ? primaryColor
                      //                             .withOpacity(0.3)
                      //                         : primaryColor),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    yearController.clear();
                    nameController.clear();
                    modelController.clear();
                    vinController.clear();
                    regNumberController.clear();
                    ownerController.clear();
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
      },
    );
  }

  Future<void> addVehicle(
      {Vehicle? vehicle, File? insurance, File? registrationFile}) async {
    bool success = await Provider.of<VehicleProvider>(context, listen: false)
        .addVehicle(
            vehicle: vehicle!,
            insuranceFile: insurance,
            registrationFile: registrationFile);
    if (success) {
      yearController.clear();
      nameController.clear();
      modelController.clear();
      vinController.clear();
      regNumberController.clear();
      ownerController.clear();
      await Provider.of<VehicleProvider>(context, listen: false)
          .fetchVehicleList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("${vehicle.registrationNumber} added successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add ${vehicle.registrationNumber}")),
      );
    }
  }

  Future<void> updateVehicle(
      {Vehicle? vehicle, File? insurance, File? registrationFile}) async {
    bool success = await Provider.of<VehicleProvider>(context, listen: false)
        .updateVan(vehicle: vehicle!);
    if (success) {
      await Provider.of<VehicleProvider>(context, listen: false)
          .fetchVehicleList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${vehicle.vehicleName} updated successfully!")),
      );
      yearController.clear();
      nameController.clear();
      modelController.clear();
      vinController.clear();
      regNumberController.clear();
      ownerController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update ${vehicle.vehicleName}")),
      );
    }
  }

  Future<void> deleteVehicle({required Vehicle vehicle}) async {
    bool success = await Provider.of<VehicleProvider>(context, listen: false)
        .deleteVehicle(vehicle: vehicle);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${vehicle.vehicleName} deleted successfully!")),
      );
      await Provider.of<VehicleProvider>(context, listen: false)
          .fetchVehicleList();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" an error occurred.")),
      );
    }
  }
}
