import 'package:bcrypt/bcrypt.dart';
import 'package:cashbook/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashbook/db/database.dart';

class AuthenticationService {
  final HiveDatabaseHelper _databaseHelper;

  AuthenticationService(this._databaseHelper);

  Future<bool> login(String username, String password) async {
    final user = await _databaseHelper.getUser(username);

    if (user != null && BCrypt.checkpw(password, user.password)) {
      await _storeUserLoginStatus(true, user.username);
      return true;
    }

    return false;
  }

  Future<User?> getCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final isLoggedIn = preferences.getBool('cashbook.isLoggedIn') ?? false;
    if (isLoggedIn) {
      final username = preferences.getString('cashbook.username') ?? '';
      final user = await _databaseHelper.getUser(username);
      return user;
    }
    return null;
  }

  Future<bool> checkUserPassword(String username, String password) async {
    final user = await _databaseHelper.getUser(username);
    if (user != null && BCrypt.checkpw(password, user.password)) {
      return true;
    }
    return false;
  }

  Future<bool> changePassword(String username, String password) async {
    final String passwordHashed = BCrypt.hashpw(password, BCrypt.gensalt());
    if (await _databaseHelper.updateUserPassword(username, passwordHashed)) {
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _storeUserLoginStatus(false, '');
  }

  Future<void> _storeUserLoginStatus(bool isLoggedIn, String username) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('cashbook.isLoggedIn', isLoggedIn);
    if (isLoggedIn) {
      await preferences.setString('cashbook.username', username);
    }
  }

  Future<bool> isUserLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    final isLoggedIn = preferences.getBool('cashbook.isLoggedIn') ?? false;
    return isLoggedIn;
  }
}
