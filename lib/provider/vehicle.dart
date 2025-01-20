import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../model/vehicle.dart';

class VehicleProvider with ChangeNotifier{

List<Vehicle>? vehicleList;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Add vehicle and upload files
  Future<bool> addVehicle({
    required Vehicle vehicle,
    File? registrationFile,
    File? insuranceFile,
  }) async {
    try {
      // Reference to Firestore document (use registration number as ID)
      DocumentReference vehicleRef = firestore
          .collection('Vehicles')
          .doc(vehicle.registrationNumber);
      // Check if the vehicle already exists
      DocumentSnapshot existingVehicle = await vehicleRef.get();
      if (existingVehicle.exists) {
        print("Vehicle with registration number ${vehicle.registrationNumber} already exists.");
        return false;
      }
      // Upload Registration File
      // String? registrationUrl;
      // if (registrationFile != null) {
      //   registrationUrl = await _uploadFile(
      //     file: registrationFile,
      //     path: 'vehicles/${vehicle.registrationNumber}/registration.pdf',
      //   );
      // }
      //
      // // Upload Insurance File
      // String? insuranceUrl;
      // if (insuranceFile != null) {
      //   insuranceUrl = await _uploadFile(
      //     file: insuranceFile,
      //     path: 'vehicles/${vehicle.registrationNumber}/insurance.pdf',
      //   );
      // }

      // Add Vehicle to Firestore
      Vehicle newVehicle = Vehicle(
        vinNumber: vehicle.vinNumber,
        model: vehicle.model,
        registrationNumber: vehicle.registrationNumber,
        year: vehicle.year,
        // isAvailable: false,
        vehicleName: vehicle.vehicleName,
        owner: vehicle.owner,
        // registrationFileUrl: registrationUrl,
        // insuranceFileUrl: insuranceUrl,
      );

      await vehicleRef.set(newVehicle.toJson());
      print("Vehicle added successfully!");
      return true;
    } catch (e) {
      print("Error adding vehicle: $e");
      return false;
    }
  }


  // Upload files to Firebase Storage
  Future<String> _uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      Reference ref = storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      throw e;
    }
  }



// update van details

  Future<bool> updateVan({required Vehicle vehicle}) async {
    try {
      DocumentReference vehicleRef =
      firestore.collection('Vehicles').doc(vehicle.registrationNumber);

      // Update only the specified fields
   await vehicleRef.update(vehicle.toJson());
    //  await vehicleRef.set(vehicle.toJson(), SetOptions(merge: true));
      print("vehicle ${vehicle.vehicleName} updated successfully!");
      return true;
    } catch (e) {
      print("Error updating vehicle: $e");
      return false;
    }
  }


  // fetch van list


  Future<List<Vehicle>?> fetchVehicleList() async {
    try {
      // Fetch all employee documents
      QuerySnapshot stationSnapshot =
      await firestore.collection('Vehicles').get();

      // Map Firestore documents to Employee model
      vehicleList = stationSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // return Employee.fromJson(doc.data() as Map<String, dynamic>,);
        // Use the document ID as employeeID and pass to the model
        Vehicle vehicle = Vehicle.fromJson(data);

        return vehicle;
      }).toList();
      print("Vehicles...............................${vehicleList?.length}");
      notifyListeners();
      return vehicleList;
    } catch (e) {
      print("Error fetching vehicles: $e");
      return [];
    }
  }

  // delete vehicle

Future<bool> deleteVehicle({required Vehicle vehicle}) async {
  try {
    DocumentReference vehicleRef =
    firestore.collection('Vehicles').doc(vehicle.registrationNumber);


    // Step 2: Now delete the employee document itself
    DocumentSnapshot snapshot = await vehicleRef.get();
    if (snapshot.exists) {
      await vehicleRef.delete();
      print("vehicle ${vehicle.vehicleName} deleted successfully.");
    } else {
      print("vehicle ${vehicle.vehicleName} already deleted.");
    }

    return true;
  } catch (e) {
    print("Error deleting vehicle: $e");
    return false;
  }
}



// van usage
}