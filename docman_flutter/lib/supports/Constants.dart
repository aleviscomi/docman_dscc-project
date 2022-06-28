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
  static const String REQUEST_ADD_USER = "/utenti/registra";
  static const String REQUEST_MY_DOCS = "/documenti/miei";
  static const String REQUEST_SHARED_WITH_ME_DOCS = "/documenti/condivisiconme";
  static const String REQUEST_MY_TRASHED_DOCS = "/documenti/cestino";
  static const String REQUEST_UPLOAD_DOC = "/documenti/carica";
  static const String REQUEST_DELETE_DOC = "/documenti/elimina";
  static const String REQUEST_PERMANENTLY_DELETE_DOC = "/documenti/eliminadefinitivamente";
  static const String REQUEST_RESTORE_DOC = "/documenti/ripristina";
  static const String REQUEST_SHARE_DOC = "/documenti/condividi";
  static const String REQUEST_REMOVE_ACCESS_DOC = "/documenti/rimuoviaccesso";
  static const String REQUEST_TYPES_BY_USER = "/documenti/formato";
  static const String REQUEST_ADD_TAGS_TO_DOC = "/documenti/aggiungitags";
  static const String REQUEST_DOCUMENT_TAGS = "/documenti/tagsDocumento";
  static const String REQUEST_MODIFY_DOCUMENT_INFO = "/documenti/modificainfo";

  static const String REQUEST_TO_SHARE = "/utenti/dacondividere";
  static const String REQUEST_SHARED_USERS = "/utenti/giacondivisi";
  static const String REQUEST_LOGGED_USER = "/utenti/loggato";
  static const String REQUEST_MODIFY_USER = "/utenti/modifica";

  static const String REQUEST_TAGS_BY_USERS = "/tags";

  //responses
  static const String RESPONSE_ERROR_USER_NOT_EXISTS = "Utente inesistente!";
  static const String RESPONSE_ERROR_DOCUMENT_NOT_EXISTS = "Documento inesistente!";
  static const String RESPONSE_ERROR_DOCUMENT_NOT_OWNED = "Questo documento non è di tua proprietà!";
  static const String RESPONSE_ERROR_DOCUMENT_ALREADY_SHARED = "Questo documento è già condiviso con l'utente specificato!";
  static const String RESPONSE_ERROR_DOCUMENT_ALREADY_OWNED = "Questo documento è già di tua proprietà! Non puoi condividere il documento con te stesso!";
  static const String RESPONSE_ERROR_MAIL_ALREADY_EXISTS = "Mail già esistente!";
}