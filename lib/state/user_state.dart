import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grodudes/helper/WooCommerceAPI.dart';
import '../secrets.dart';

enum logInStates { loggedIn, loggedOut, pending, logInFailed }

class UserManager with ChangeNotifier {
  Map<String, dynamic> wcUserInfo;
  Map<String, dynamic> wpUserInfo;
  FlutterSecureStorage _secureStorage;
  var _logInStatus;
  WooCommerceAPI _wooCommApi;

  UserManager() {
    this.wcUserInfo = {};
    this.wpUserInfo = {};
    this._secureStorage = FlutterSecureStorage();
    this._logInStatus = logInStates.loggedOut;
    this._wooCommApi = WooCommerceAPI(
      url: 'https://www.grodudes.com',
      consumerKey: secret['consumerKey'],
      consumerSecret: secret['consumerSecret'],
    );
  }

  bool isLoggedIn() => this._logInStatus == logInStates.loggedIn;
  getLogInStatus() => this._logInStatus;

  initializeUser(
      Map<String, dynamic> wpUserInfo, Map<String, dynamic> wcUserInfo) {
    if (wcUserInfo == null || wcUserInfo['id'] == null) return;
    if (this.wcUserInfo != null && this.wcUserInfo['id'] != null) return;
    this.wpUserInfo = wpUserInfo;
    this.wcUserInfo = wcUserInfo;
    this._logInStatus = logInStates.loggedIn;
  }

  Future logInToWordpress(String username, String password) async {
    if (isLoggedIn()) return;
    if (this._logInStatus != logInStates.pending) {
      this._logInStatus = logInStates.pending;
      notifyListeners();
    }
    //authorize user through wordpress
    Map<String, dynamic> message;
    try {
      message = await this._wooCommApi.getAuthToken(username, password);
      if (message == null || message['token'] == null) {
        _createLoginErrorResponse(message ?? {'code': 'token_error'});
        this._logInStatus = logInStates.logInFailed;
        notifyListeners();
        return;
      }
    } catch (err) {
      _createLoginErrorResponse({'code': 'token_error'});
      this._logInStatus = logInStates.logInFailed;
      notifyListeners();
      print('error logging in to wordpress: $err');
      return;
    }
    this.wpUserInfo = message;
    String token = this.wpUserInfo['token'];
    bool success = await _fetchLoggedInUserData(token);
    if (success != null && success) {
      this._logInStatus = logInStates.loggedIn;
      await _storeUserDataLocally().catchError((err) => print(err));
    } else {
      this._logInStatus = logInStates.logInFailed;
      _createLoginErrorResponse({});
    }
    notifyListeners();
    return success;
  }

  Future _storeUserDataLocally() async {
    try {
      await this._secureStorage.write(
            key: 'grodudes_login_status',
            value: 'true',
          );
      await this._secureStorage.write(
            key: 'grodudes_wp_info',
            value: json.encode(this.wpUserInfo),
          );
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> _fetchLoggedInUserData(String token) async {
    try {
      int id = await this._wooCommApi.getLoggedInUserId(token);
      if (id == null) return false;
      var response = await this._wooCommApi.getAsync('customers/$id');
      this.wcUserInfo = response;
      return true;
    } catch (err) {
      print('_fetchLoggedInUserData: $err');
      return false;
    }
  }

  Future registerNewUser(String username, String email, String password) async {
    this._logInStatus = logInStates.pending;
    notifyListeners();

    Map<String, String> payload = {
      'username': username,
      'password': password,
      'email': email,
      'roles': 'customer'
    };

    try {
      var response = await _wooCommApi.postAsync('customers', payload);
      if (response == null || response['id'] == null) {
        this._logInStatus = logInStates.logInFailed;
        _createRegistrationErrorResponse(response);
        notifyListeners();
        return;
      }
      this.wcUserInfo = response;
      this.wpUserInfo = {
        'user_email': email,
        'user_display_name': username,
      };

      this._logInStatus = logInStates.loggedIn;
      notifyListeners();
      completeAuthOnRegistration(username, password);
    } catch (err) {
      this._logInStatus = logInStates.logInFailed;
      _createRegistrationErrorResponse({'code': 'registration_failed'});
      notifyListeners();
    }
  }

  Future completeAuthOnRegistration(String username, String password) async {
    try {
      var response = await this._wooCommApi.getAuthToken(username, password);
      if (response != null && response['token'] != null) {
        this.wpUserInfo = response;
        this._logInStatus = logInStates.loggedIn;
        notifyListeners();
      }
      await _storeUserDataLocally();
    } catch (err) {
      print(err);
    }
  }

  logOut() async {
    this.wpUserInfo = null;
    this.wcUserInfo = null;
    this._logInStatus = logInStates.loggedOut;
    notifyListeners();
    await this
        ._secureStorage
        .write(key: 'grodudes_login_status', value: 'false');
  }

  Future getOrders(int page) async {
    int customerId = this.wcUserInfo['id'];
    if (customerId == null) return false;
    try {
      List<dynamic> orders = await this
          ._wooCommApi
          .getAsync('orders?customer=$customerId&&per_page=10&&page=$page');
      return orders;
    } catch (err) {
      print('orders not found $err');
      return false;
    }
  }

  Future<String> updateUser(Map<String, dynamic> user) async {
    try {
      var response = await this._wooCommApi.putAsync(
        'customers/${this.wcUserInfo['id']}',
        user,
        userHeaders: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
      if (response['id'] != null) {
        this.wcUserInfo = response;
        notifyListeners();
        return "Updated";
      }
      Map<String, dynamic> errorMap = response['data']['params'];
      if (errorMap == null) return 'Update Failed';
      String errorMsg = errorMap.values.elementAt(0);
      return errorMsg != null ? 'Update Failed: $errorMsg' : 'Update Failed';
    } catch (err) {
      print('could not get wcomm details $err');
      return 'Update Failed';
    }
  }

  Future cancelOrder(int id) async {
    Map<String, dynamic> body = {
      'id': id,
      'status': 'cancel-request',
    };
    var response = await this._wooCommApi.putAsync(
      'orders/$id',
      body,
      userHeaders: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    if (response['id'] != null)
      return response;
    else
      return false;
  }

  _createLoginErrorResponse(Map<String, dynamic> response) {
    final code = response['code'];

    if (code == '[jwt_auth] invalid_username') {
      this.wpUserInfo = {
        'code': 'Invalid Username',
        'errMsg': 'Unknown username. Check again or try your email address.'
      };
    } else if (code == '[jwt_auth] incorrect_password') {
      this.wpUserInfo = {
        'code': 'Wrong Password',
        'errMsg': 'Please retry with the correct password'
      };
    } else if (code == 'token_error') {
      this.wpUserInfo = {
        'code': 'Authorization Problem',
        'errMsg': 'Could not get authorization token'
      };
    } else {
      this.wpUserInfo = {
        'code': 'Unknown Error',
        'errMsg': 'An Error Occured while trying to login'
      };
    }
    this.wcUserInfo = this.wpUserInfo;
  }

  _createRegistrationErrorResponse(Map<String, dynamic> response) {
    final code = response['code'];

    if (code == 'registration_failed') {
      this.wpUserInfo = {
        'code': code,
        'errMsg': 'Failed to create User! Please try again.',
      };
    }
    this.wpUserInfo = {
      'code': response['code'] ?? 'registration_failed',
      'errMsg': response['message'] ?? 'Registration Failed',
    };
    this.wcUserInfo = this.wpUserInfo;
  }
}
