import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/login.dart';
import 'admin_dashboard.dart';
import 'dashboard.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    Timer(
        Duration(seconds: 1),
            () {
          navigate();
        }
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      body: Container(
        margin: EdgeInsets.only(left: 20,right: 20),
        decoration: BoxDecoration(
          image: DecorationImage(

              alignment: Alignment.center,
              image: AssetImage("assets/images/logo4.png"),
              fit: BoxFit.contain)
        ),
      ),
    );
  }
  navigate() async {

    bool userExist = await Provider.of<LoginProvider>(context, listen: false)
        .isAuthenticated();
    if(userExist){
      await Provider.of<LoginProvider>(context, listen: false).fetchUserRole();
      if(Provider.of<LoginProvider>(context,listen: false).isAdmin){
        Navigator.of(context).pushNamedAndRemoveUntil(AdminDashboard.routeName, (route) => false,);

      }
      else{
        Navigator.of(context).pushNamedAndRemoveUntil(Dashboard.routeName, (route) => false,);
      }

    }
   else{
      Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false,);
    }


  }
}
