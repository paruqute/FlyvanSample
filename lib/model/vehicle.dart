import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String? vinNumber;
  final String? owner;
  final String? vehicleName;
  final String? model;
  final String? registrationNumber;
  final String? year;
  final String? registrationFileUrl;
  final String? insuranceFileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isAvailable;
  final int? usage;

  Vehicle({
     this.vinNumber,
    this.owner,
    this.vehicleName,
     this.model,
     this.registrationNumber,
     this.year,
    this.registrationFileUrl,
    this.insuranceFileUrl,
    this.isAvailable,
    this.usage,
    DateTime? createdAt,
    this.updatedAt,
  })  : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'VinNumber': vinNumber,
      'Owner': owner,
      'VehicleName': vehicleName,
      'Model': model,
      'RegistrationNumber': registrationNumber,
      'Year': year,
      'RegistrationFileUrl': registrationFileUrl,
      'InsuranceFileUrl': insuranceFileUrl,
      'IsAvailable': isAvailable,
      'Usage': usage,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    };
  }

  // Factory to create from Firestore
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vinNumber: json['VinNumber'],
      owner: json['Owner'],
      vehicleName: json['VehicleName'],
      model: json['Model'],
      registrationNumber: json['RegistrationNumber'],
      year: json['Year'],
      registrationFileUrl: json['RegistrationFileUrl'],
      insuranceFileUrl: json['InsuranceFileUrl'],
      isAvailable: json['IsAvailable'],
      usage: json['Usage'],
      createdAt: json['CreatedAt'] != null
          ? (json['CreatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['UpdatedAt'] != null
          ? (json['UpdatedAt'] as Timestamp).toDate()
          : null, // Allow null for updatedAt
    );
  }
}
