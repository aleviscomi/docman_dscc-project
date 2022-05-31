import 'dart:async';
import 'dart:convert';

import 'package:docman_flutter/model/objects/Documento.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../supports/Constants.dart';
import '../supports/LogInResult.dart';
import 'managers/RestManager.dart';
import 'objects/AuthenticationData.dart';

class Model {
  static Model sharedInstance = Model();

  RestManager _restManager = RestManager();
  AuthenticationData _authenticationData;

  Future<bool> hasToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('token') != null;
  }

  Future<Map> getDataFromToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return Jwt.parseJwt(preferences.getString('token'));
  }

  Future<LogInResult> logIn(String email, String password) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      Map<String, String> params = Map();
      params["grant_type"] = "password";
      params["client_id"] = Constants.CLIENT_ID;
      params["username"] = email;
      params["password"] = password;

      String result = await _restManager.makePostRequest(
          Constants.ADDRESS_AUTHENTICATION_SERVER, Constants.REQUEST_LOGIN,
          params, type: TypeHeader.urlencoded);


      _authenticationData = AuthenticationData.fromJson(jsonDecode(result));
      if (_authenticationData.hasError()) {
        if (_authenticationData.error == "Invalid user credentials") {
          return LogInResult.error_wrong_credentials;
        }
        else if (_authenticationData.error == "Account is not fully set up") {
          return LogInResult.error_not_fully_setupped;
        }
        else {
          return LogInResult.error_unknown;
        }
      }

      preferences.setString('token', _authenticationData.accessToken);
      preferences.setString('refreshToken', _authenticationData.refreshToken);
      preferences.setInt('tokenExpiresIn', _authenticationData.expiresIn);

      return LogInResult.logged;
    }
    catch (e) {
      return LogInResult.error_unknown;
    }
  }

  Future<void> refreshAndDoPeriodic() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _refreshToken();
    Timer.periodic(Duration(seconds: (preferences.getInt('tokenExpiresIn') - 50)), (Timer t) {
      _refreshToken();
    });
  }

  Future<bool> _refreshToken() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      Map<String, String> params = Map();
      params["grant_type"] = "refresh_token";
      params["client_id"] = Constants.CLIENT_ID;
      params["refresh_token"] = preferences.getString('refreshToken');
      String result = await _restManager.makePostRequest(Constants.ADDRESS_AUTHENTICATION_SERVER, Constants.REQUEST_LOGIN, params, type: TypeHeader.urlencoded);
      _authenticationData = AuthenticationData.fromJson(jsonDecode(result));
      if ( _authenticationData.hasError() ) {
        return false;
      }

      preferences.setString('token', _authenticationData.accessToken);
      preferences.setString('refreshToken', _authenticationData.refreshToken);
      preferences.setInt('tokenExpiresIn', _authenticationData.expiresIn);

      return true;
    }
    catch (e) {
      return false;
    }
  }

  Future<bool> logOut() async {
    try{
      SharedPreferences preferences = await SharedPreferences.getInstance();

      Map<String, String> params = Map();
      params["client_id"] = Constants.CLIENT_ID;
      params["refresh_token"] = preferences.getString('refreshToken');

      preferences.remove('token');
      preferences.remove('tokenExpiresIn');
      preferences.remove('refreshToken');
      await _restManager.makePostRequest(Constants.ADDRESS_AUTHENTICATION_SERVER, Constants.REQUEST_LOGOUT, params, type: TypeHeader.urlencoded);
      return true;
    }
    catch (e) {
      return false;
    }
  }

  Future<List<Documento>> getMyDocuments() async {
    try {
      String rawResult = await _restManager.makeGetRequest(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_MY_DOCS);
      if (rawResult.contains(Constants.RESPONSE_ERROR_USER_NOT_EXISTS)) {
        return [];
      }
      return List<Documento>.from(json.decode(rawResult).map((i) => Documento.fromJson(i)).toList());
    } catch(e) {
      print(e);
      return null;
    }
  }
}