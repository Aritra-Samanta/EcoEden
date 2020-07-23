import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Resource<T> {
  String url;
  T Function(Response response) parse;

  Resource({this.url,this.parse});
}

class API_KEY extends ChangeNotifier{
  String _apikey = "";

  String get key{
    return _apikey;
  }

  void set_key(newValue){
    _apikey = newValue;
    notifyListeners();
  }
}

class Webservice {

  Future<T> load<T>(Resource<T> resource) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('user');
    final response = await http.get(resource.url, headers: {HttpHeaders.authorizationHeader : "Token " + jwt});
    if(response.statusCode == 200) {
      return resource.parse(response);
    } else {
      print("Exception !!!");
      throw Exception('Failed to load data!');
    }
  }

}