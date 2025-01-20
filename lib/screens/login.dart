import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/cutom_text_field.dart';
import '../provider/login.dart';
import '../utils/colors.dart';
import '../utils/decoration.dart';
import 'admin_dashboard.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/loginScreen";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController userNameController;
  late TextEditingController passwordController;
  final _formGlobalKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    userNameController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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

              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                // borderRadius: BorderRadius.only(
                //   bottomRight: Radius.circular(50),
                // ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 200,
                    width: 300,
                    child: Image.asset(
                      "assets/images/flyvanlogo1.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              )),
          Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                image: logoBgDecorationImage(),
              ),
              child: Form(
                key: _formGlobalKey,
                child: Column(
                  spacing: 15.0,
                  children: [
                    Text(
                      "Login",
                      // softWrap: true,
                      // overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: primaryColor,fontSize: 24),
                    ),
                    CustomTextField(
                      textFieldController: userNameController,
                      labelText: "email",
                    ),
                    CustomTextField(
                      textFieldController: passwordController,
                      labelText: "Password",
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if(_formGlobalKey.currentState!.validate()) {
                            //login......................
                            login();
                          }
                        },
                        child: Text("Login"),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Future<void> login() async {
    bool success = await Provider.of<LoginProvider>(context, listen: false)
        .loginUser(
            email: userNameController.text, password: passwordController.text);

    if (success) {
      userNameController.clear();
      passwordController.clear();
      await Provider.of<LoginProvider>(context, listen: false).fetchUserRole();

      if (Provider.of<LoginProvider>(context, listen: false).isAdmin) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AdminDashboard.routeName,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Dashboard.routeName,
          (route) => false,
        );
      }
      await Provider.of<LoginProvider>(context, listen: false).fetchUserRole();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text("login successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Access Denied: Contact Admin")),
      );
    }
  }
}
