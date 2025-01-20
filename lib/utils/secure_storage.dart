import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import '../model/user.dart';

class SecureStorage{
  final FlutterSecureStorage storage = FlutterSecureStorage();



  Future<void> saveLoginSession(
      {required String userId, required String email, required String role, required String password}) async {
    await storage.write(key: 'userId', value: userId);
    await storage.write(key: 'email', value: email);
    await storage.write(key: 'password', value: password);
    await storage.write(key: 'role', value: role);
  }

  Future<UserModel?> getLoginSession() async {
    final userId = await storage.read(key: 'userId');
    final email = await storage.read(key: 'email');
    final password = await storage.read(key: 'password');
    final role = await storage.read(key: 'role');

    return UserModel(userId: userId, password: password, email: email,  role: role);
  }

  Future<void> clearLoginSession() async {
    await storage.deleteAll();
  }

}