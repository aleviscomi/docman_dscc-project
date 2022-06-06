import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:docman_flutter/model/objects/Documento.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../supports/Constants.dart';
import '../supports/LogInResult.dart';
import 'managers/RestManager.dart';
import 'objects/AuthenticationData.dart';
import 'package:http/http.dart';

import 'objects/Tag.dart';
import 'objects/Utente.dart';

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
          body: params, type: TypeHeader.urlencoded);


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
      String result = await _restManager.makePostRequest(Constants.ADDRESS_AUTHENTICATION_SERVER, Constants.REQUEST_LOGIN, body: params, type: TypeHeader.urlencoded);
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
      await _restManager.makePostRequest(Constants.ADDRESS_AUTHENTICATION_SERVER, Constants.REQUEST_LOGOUT, body: params, type: TypeHeader.urlencoded);
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

  Future<bool> uploadDocument(String titolo, String descrizione, PlatformFile fileUploaded) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Uri uri = Uri.http(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_UPLOAD_DOC, null);
    var uploadRequest = MultipartRequest("POST", uri);

    var file = await MultipartFile.fromBytes("file", fileUploaded.bytes, filename: fileUploaded.name);
    uploadRequest.headers[HttpHeaders.authorizationHeader] = 'bearer ${preferences.getString("token")}';
    uploadRequest.fields["titolo"] = titolo;
    uploadRequest.fields["descrizione"] = descrizione;
    uploadRequest.files.add(file);

    try {
      final streamedResponse = await uploadRequest.send();
      final response = await Response.fromStream(streamedResponse);
      if(response.statusCode != 200) {
        return false;
      }
      return true;
    } catch(e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteDocument(int id) async {
    try {
      Map<String, String> params = Map();
      params['id'] = id.toString();
      String rawResult = await _restManager.makeDeleteRequest(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_DELETE_DOC, params);
      if (rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_NOT_EXISTS) || rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_NOT_OWNED)) {
        return false;
      }
      return true;
    } catch(e) {
      print(e);
      return null;
    }
  }

  Future<List<Utente>> getSharedUsers(int idDocumento) async {
    try {
      Map<String, String> params = Map();
      params['id_doc'] = idDocumento.toString();
      String rawResult = await _restManager.makeGetRequest(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_TO_SHARE, params);
      if (rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_NOT_EXISTS)) {
        return [];
      }
      return List<Utente>.from(json.decode(rawResult).map((i) => Utente.fromJson(i)).toList());
    } catch(e) {
      print(e);
      return null;
    }
  }

  Future<List<Utente>> getAlreadySharedUsers(int idDocumento) async {
    try {
      Map<String, String> params = Map();
      params['id_doc'] = idDocumento.toString();
      String rawResult = await _restManager.makeGetRequest(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_SHARED_USERS, params);
      if (rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_NOT_EXISTS)) {
        return [];
      }
      return List<Utente>.from(json.decode(rawResult).map((i) => Utente.fromJson(i)).toList());
    } catch(e) {
      print(e);
      return null;
    }
  }

  Future<bool> shareDocument(int idDocumento, int idUtente) async {
    try {
      Map<String, String> params = Map();
      params['id_doc'] = idDocumento.toString();
      params['id_utente'] = idUtente.toString();
      String rawResult = await _restManager.makePostRequest(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_SHARE_DOC, value: params);
      if (rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_NOT_EXISTS) ||
          rawResult.contains(Constants.RESPONSE_ERROR_USER_NOT_EXISTS) ||
          rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_NOT_OWNED) ||
          rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_ALREADY_SHARED) ||
          rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_ALREADY_OWNED)) {
        return false;
      }
      return true;
    } catch(e) {
      print(e);
      return null;
    }
  }

  Future<bool> removeAccessDocument(int idDocumento, int idUtente) async {
    try {
      Map<String, String> params = Map();
      params['id_doc'] = idDocumento.toString();
      params['id_utente'] = idUtente.toString();
      String rawResult = await _restManager.makeDeleteRequest(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_REMOVE_ACCESS_DOC, params);
      if (rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_NOT_EXISTS) ||
          rawResult.contains(Constants.RESPONSE_ERROR_USER_NOT_EXISTS) ||
          rawResult.contains(Constants.RESPONSE_ERROR_DOCUMENT_NOT_OWNED)) {
        return false;
      }
      return true;
    } catch(e) {
      print(e);
      return null;
    }
  }

  Future<List<Tag>> getTagsByUser() async {
    try {
      String rawResult = await _restManager.makeGetRequest(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_TAGS_BY_USERS);
      if (rawResult.contains(Constants.RESPONSE_ERROR_USER_NOT_EXISTS)) {
        return [];
      }
      return List<Tag>.from(json.decode(rawResult).map((i) => Tag.fromJson(i)).toList());
    } catch(e) {
      print(e);
      return null;
    }
  }

  Future<List<String>> getTypesByUser() async {
    try {
      String rawResult = await _restManager.makeGetRequest(Constants.ADDRESS_BACKEND_SERVER, Constants.REQUEST_TYPES_BY_USER);
      if (rawResult.contains(Constants.RESPONSE_ERROR_USER_NOT_EXISTS)) {
        return [];
      }
      return List<String>.from(json.decode(rawResult).map((i) => i).toList());
    } catch(e) {
      print(e);
      return null;
    }
  }

}