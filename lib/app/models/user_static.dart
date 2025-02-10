import 'package:madeira/app/models/login_model.dart';

class UserStatic {
  static UserModel? user;

  static void setUser(UserModel user) {
    UserStatic.user = user;
  }

  static UserModel? getUser() {
    return UserStatic.user;
  }

  static void clearUser() {
    UserStatic.user = null;
  }
}
