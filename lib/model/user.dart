class UserModel {
  final String? userId; // Document ID
  final String? password;
  final String? userName;
  final String? email;
  final bool? isPermitted;
  final String? role;

  UserModel({
    required this.userId,
    this.userName,
    required this.password,
    required this.email,
     this.isPermitted = false,
    required this.role,
  });

  // Factory method to create a UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
      userId: json['userID'],
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      password: json['password'] ?? '',
      isPermitted: json['isPermitted'] ?? false,
      role: json['role'] ?? 'viewer', // Default to 'viewer' if not specified
    );
  }

  // Convert UserModel to JSON for storing in Firestore
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'userName': userName,
      'email': email,
      'isPermitted': isPermitted,
      'role': role,
    };
  }
}
