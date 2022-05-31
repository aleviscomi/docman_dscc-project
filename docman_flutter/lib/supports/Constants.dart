import 'package:flutter/material.dart';

class Constants {
  //color
  static const PRIMARY_COLOR = Color(0xFF60A2F5);
  static const SECONDARY_COLOR = Color(0xFF8AEDF6);
  static const TERTIARY_COLOR = Colors.white;
  static const BG_COLOR = Color(0xFFEDEDEA);

  //app info
  static const APP_VERSION = "0.0.1";
  static const APP_NAME = "Doc-Man";

  // addresses
  static const String ADDRESS_BACKEND_SERVER = "localhost:8080";
  static const String ADDRESS_AUTHENTICATION_SERVER = "localhost:8081";

  // authentication
  static const String REALM = "docman";
  static const String CLIENT_ID = "docman-flutter";
  static const String REQUEST_LOGIN = "/auth/realms/" + REALM + "/protocol/openid-connect/token";
  static const String REQUEST_LOGOUT = "/auth/realms/" + REALM + "/protocol/openid-connect/logout";

  //registration
  static const String CLIENT_ID_MASTER = "admin-cli";
  static const String REQUEST_LOGIN_MASTER = "/auth/realms/master/protocol/openid-connect/token";
  static const String REQUEST_LOGOUT_MASTER = "/auth/realms/master/protocol/openid-connect/logout";
  static const String USERNAME_MASTER = "visc";
  static const String PASSWORD_MASTER = "visc";
  static const String REQUEST_SIGNUP = "/auth/admin/realms/" + REALM + "/users";

  //requests
  static const String REQUEST_MY_DOCS = "/documenti/miei";

  //responses
  static const String RESPONSE_ERROR_USER_NOT_EXISTS = "Utente inesistente!";
}