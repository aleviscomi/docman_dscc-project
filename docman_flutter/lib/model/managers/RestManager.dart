import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TypeHeader {
  json,
  urlencoded
}


class RestManager {
  Future<String> _makeRequest(String serverAddress, String servicePath, String method, TypeHeader type, {Map<String, String> value, dynamic body}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Uri uri = Uri.http(serverAddress, servicePath, value);
    while ( true ) {
      try {
        var response;
        // setting content type
        String contentType;
        dynamic formattedBody;
        if ( type == TypeHeader.json ) {
          contentType = "application/json;charset=utf-8";
          formattedBody = json.encode(body);
        }
        else if ( type == TypeHeader.urlencoded ) {
          contentType = "application/x-www-form-urlencoded";
          formattedBody = body.keys.map((key) => "$key=${body[key]}").join("&");
        }
        // setting headers
        Map<String, String> headers = Map();
        headers[HttpHeaders.contentTypeHeader] = contentType;
        if ( preferences.getString('token') != null ) {
          headers[HttpHeaders.authorizationHeader] = 'bearer ${preferences.getString("token")}';
        }
        // making request
        switch ( method ) {
          case "post":
            response = await post(uri, headers: headers, body: formattedBody,);
            break;
          case "get":
            response = await get(uri, headers: headers,);
            break;
          case "put":
            response = await put(uri, headers: headers, body: formattedBody,);
            break;
          case "delete":
            response = await delete(uri, headers: headers,);
            break;
        }
        return response.body;
      } catch(err) {
        print(err);
        await Future.delayed(const Duration(seconds: 5), () => null); // not the best solution
      }
    }
  }

  Future<String> makePostRequest(String serverAddress, String servicePath, {Map<String, String> value, dynamic body, TypeHeader type = TypeHeader.json}) async {
    return _makeRequest(serverAddress, servicePath, "post", type, value: value, body: body);
  }

  Future<String> makeGetRequest(String serverAddress, String servicePath, [Map<String, String> value, TypeHeader type]) async {
    return _makeRequest(serverAddress, servicePath, "get", type, value: value);
  }

  Future<String> makePutRequest(String serverAddress, String servicePath, {Map<String, String> value, dynamic body, TypeHeader type = TypeHeader.json}) async {
    return _makeRequest(serverAddress, servicePath, "put", type, value: value, body: body);
  }

  Future<String> makeDeleteRequest(String serverAddress, String servicePath, [Map<String, String> value, TypeHeader type = TypeHeader.json]) async {
    return _makeRequest(serverAddress, servicePath, "delete", type, value: value);
  }


}
