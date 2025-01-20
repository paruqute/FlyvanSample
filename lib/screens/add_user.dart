import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/appbar_widget.dart';
import '../custom_widgets/confirm_dialog.dart';
import '../custom_widgets/cutom_text_field.dart';
import '../custom_widgets/table_column_name.dart';
import '../provider/login.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';
class AddUser extends StatefulWidget {
  static const routeName = "/user-screen";
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formGlobalKey = GlobalKey<FormState>();
  late TextEditingController userController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  String? role;

  @override
  void initState() {
    // TODO: implement initState
    userController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<LoginProvider>(builder: (context, user, child) {
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
              child: user.usersList.isNotEmpty
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
                            columnTitle: "User",
                          ),
                          headingRowAlignment: MainAxisAlignment.start),
                      DataColumn(
                          label: TableColumnName(
                            columnTitle: "email",
                          ),
                          headingRowAlignment: MainAxisAlignment.start),
                      DataColumn(
                          label: TableColumnName(
                            columnTitle: "role",
                          ),
                          headingRowAlignment: MainAxisAlignment.start),
                      DataColumn(
                          label: TableColumnName(
                            columnTitle: "Password",
                          ),
                          headingRowAlignment: MainAxisAlignment.start),

                      // DataColumn(
                      //     label: TableColumnName(columnTitle: "")),
                    ],
                    rows: [
                      ...user.usersList.map((appUser) {
                        return DataRow(cells: [
                          DataCell(TableRowText(
                              title: appUser.userName ?? '')),
                          DataCell(SizedBox(
                            width:85,
                            child: TableRowText(
                                title: appUser.email ?? ''),
                          )),
                          DataCell(TableRowText(title: appUser.role ?? '')),
                          DataCell(TableRowText(title: appUser.password ?? '')),
                          // DataCell(
                          //
                          //   GestureDetector(
                          //       child: Icon(
                          //         Icons.delete,
                          //         size: 18,
                          //         color: primaryColor,
                          //       ),
                          //       onTap: () async {
                          //         showDialog(
                          //           barrierDismissible: false,
                          //           context: context,
                          //           builder: (context) {
                          //             return ConfirmDialog(
                          //               name: "Delete ${appUser.userName}",
                          //               onPressed: () {
                          //                 // deleteEmployee(
                          //                 //     employee: driver);
                          //                 // delete employee
                          //               },
                          //             );
                          //           },
                          //         );
                          //       }),
                          // ),
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
                                "${user.usersList.length}",
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
                            // DataCell(
                            //   Text(""),
                            // ),
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
              buttonTitle: "Create",
              title:  "Create User",
              onPressed: () async {
                // add driver to firestore
                if (_formGlobalKey.currentState!.validate() && role !=null) {
                  final bool isValidEmail = EmailValidator.validate(emailController.text);
                  if(isValidEmail){
                    await createUser();
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Enter a valid email")),
                    );
                  }

                }  else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Missed one Field")),
                  );
                }
              },
            );
          },
          tooltip: "Add User", // Call function to show dialog
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    },);
  }

  Future<void> createUser() async {


    bool success = await Provider.of<LoginProvider>(context, listen: false)
        .registerUser(email: emailController.text, password: passwordController.text, name: userController.text, role: role??'');

    if (success) {
      await Provider.of<LoginProvider>(context, listen: false)
          .fetchAppUsers();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("user created successfully!")),
      );
      userController.clear();
      emailController.clear();
      passwordController.clear();
      role = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("user already exists or an error occurred.")),
      );
      Navigator.of(context).pop();
    }
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
          content:StatefulBuilder(builder: (context, setState) {
            return  Form(
              key: _formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    textFieldController: userController,
                    labelText: "username",
                  ),

                  CustomTextField(
                    textFieldController: emailController,
                    labelText: "email",
                  ),

                  CustomTextField(
                    textFieldController: passwordController,
                    labelText: "password",
                    helperText: "Password should be at least 6 characters",
                  ),
                  Text(
                    "Choose Role: ",
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: primaryColor),
                  ),
                  Row(
                     mainAxisSize: MainAxisSize.min,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // Van Radio Button
                      Expanded(
                        child: RadioListTile(
                          activeColor: primaryColor,
                          title: Text('admin',  style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: primaryColor),
                          ),
                          value: 'admin',
                          groupValue: role,
                          onChanged: (value) {
                            setState(() {
                              role = value.toString();
                            });
                          },
                        ),
                      ),

                      // Cargo Radio Button
                      Expanded(
                        child: RadioListTile(
                          activeColor: primaryColor,
                          title: Text('supervisor',style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: primaryColor),),
                          value: 'supervisor',
                          groupValue: role,
                          onChanged: (value) {
                            setState(() {
                              role = value.toString();
                            });
                          },
                        ),
                      ),


                    ],
                  )
                ],
              ),
            );
          },),
          actions: [
            TextButton(
              onPressed: (){
               userController.clear();
               emailController.clear();
               passwordController.clear();
               role = null;
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
}
