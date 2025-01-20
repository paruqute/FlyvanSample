import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../model/vehicle.dart';
import '../utils/secure_storage.dart';

class LoginProvider with ChangeNotifier{

  List<UserModel> usersList = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  String _role = "viewer"; // Default role
  String get role => _role;

  void setUserRole(String role) {
    _role = role;
    print("Role..............$role");
    notifyListeners();
  }

  bool get isAdmin => _role == "admin";

  Future<void> fetchUserRole() async {

    try {
      User? user = FirebaseAuth.instance.currentUser;

      DocumentSnapshot userDoc = await firestore.collection('Users').doc(user?.uid).get();

      if (userDoc.exists) {
        String role = userDoc['role'] ?? 'viewer'; // Default role is 'viewer'
        setUserRole(role);
      } else {
        print("User document not found.");
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }


  // check if the user authenticated

  Future<bool> isAuthenticated()async{
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      print("USER..........................${user.email}");
      // User is signed in, navigate to home screen
      return true;
    } else {
      // User is not signed in, navigate to login screen
      return false;
    }
  }


 // login user
  Future<bool> loginUser({required String email, required String password}) async {

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user permissions from Firestore
      DocumentSnapshot userDoc = await firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc['isPermitted'] == true) {

       await SecureStorage().saveLoginSession(userId: userCredential.user!.uid, email: email, role: userDoc['role'], password: password);
       return true;
      } else {
        // User not permitted
       return false;
      }
    } catch (e) {
     print("login error $e");
     return false;
    }
  }

  // fetch users
  Future<List<UserModel>?> fetchAppUsers() async {
    try {
      // Fetch all employee documents
      QuerySnapshot userSnapshot =
      await firestore.collection('Users').get();

      // Map Firestore documents to Employee model
      usersList = userSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // return Employee.fromJson(doc.data() as Map<String, dynamic>,);
        // Use the document ID as employeeID and pass to the model
        UserModel user = UserModel.fromJson(data);

        return user;
      }).toList();
      print("Vehicles...............................${usersList.length}");
      notifyListeners();
      return usersList;
    } catch (e) {
      print("Error fetching employees: $e");
      return [];
    }
  }

  // create user
  Future<bool> registerUser(
      {required String email, required String password, required String name, required String role }) async {
    try {

      // fetch login session
       UserModel? user = await SecureStorage().getLoginSession();


      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      DocumentReference userRef =  FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid);

      DocumentSnapshot userSnap = await userRef.get();
      if(userSnap.exists){
        return false;
      }
      // After creating the user, add their details to Firestore
      userRef.set({
        'email': email,
        'userName': name, // Example username
        'isPermitted': true, // Default to not permitted
        'role': role, // Default role
        'password': password, // Default role
      });
      // Sign out the newly created user
      await auth.signOut();

      // Reauthenticate the admin
      await auth.signInWithEmailAndPassword(
        email: user?.email??'',
        password: user?.password??'',
      );

       return true;

    } catch (e) {
      print("Error registering user: $e");
      return false;
    }
  }



//signout

  // login user
  Future<bool> logOut() async {

    try {
      await auth.signOut();
      await SecureStorage().clearLoginSession();
      return true;

    } catch (e) {
      print("login error $e");
      return false;
    }
  }


  // // check the user is admin
  // Future<bool> checkIfUserIsAdmin() async {
  //
  //   try {
  //     User? user = FirebaseAuth.instance.currentUser;
  //
  //     DocumentSnapshot userDoc = await firestore.collection('Users').doc(user?.uid).get();
  //
  //     if (userDoc.exists) {
  //       String role = userDoc['role'] ?? 'viewer'; // Default role is 'viewer'
  //       return role == "admin";
  //     } else {
  //       print("User not found.");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Error checking admin status: $e");
  //     return false;
  //   }
  // }


// van usage
}