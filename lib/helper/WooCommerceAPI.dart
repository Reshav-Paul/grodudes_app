import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WooCommerceAPI {
  String url;
  String consumerKey;
  String consumerSecret;

  WooCommerceAPI(
      {@required this.url,
      @required this.consumerKey,
      @required this.consumerSecret});

  String _getUrl(String endpoint, {String apiVersion = 'v2'}) {
    String type = endpoint.contains('users') ? 'wp' : 'wc';
    String wcApiBase = this.url + '/wp-json/$type/$apiVersion/' + endpoint;
    if (endpoint.contains('?')) {
      return wcApiBase +
          '&consumer_key=${this.consumerKey}&consumer_secret=${this.consumerSecret}';
    } else {
      return wcApiBase +
          '?consumer_key=${this.consumerKey}&consumer_secret=${this.consumerSecret}';
    }
  }

  Future<dynamic> getAsync(String endPoint, {String apiVersion = 'v2'}) async {
    String reqUrl = this._getUrl(endPoint, apiVersion: apiVersion);

    try {
      final http.Response response = await http.get(reqUrl);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    }
  }

  Future<dynamic> postAsync(String endPoint, Map data,
      {Map<String, String> userHeaders, String apiVersion: 'v2'}) async {
    String reqUrl = this._getUrl(endPoint, apiVersion: apiVersion);
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    if (userHeaders != null) headers = {...headers, ...userHeaders};
    var response = await http.post(
      reqUrl,
      headers: headers,
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
    );

    var dataResponse = await json.decode(response.body);
    return dataResponse;
  }

  Future<dynamic> putAsync(String endPoint, Map data,
      {Map<String, String> userHeaders, String apiVersion: 'v2'}) async {
    String reqUrl = this._getUrl(endPoint, apiVersion: apiVersion);
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    if (userHeaders != null) headers = {...headers, ...userHeaders};
    var response = await http.put(
      reqUrl,
      headers: headers,
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
    );

    var dataResponse = await json.decode(response.body);
    return dataResponse;
  }

  Future<dynamic> getAuthToken(String username, String password) async {
    final body = {
      'username': username,
      'password': password,
    };
    final response = await http.post(
      '${this.url}/wp-json/jwt-auth/v1/token',
      body: body,
    );
    return json.decode(response.body);
  }

  Future<int> getLoggedInUserId(String token) async {
    final response = await http.post(
      '${this.url}/wp-json/wp/v2/users/me',
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    return json.decode(response.body)['id'];
  }
}
