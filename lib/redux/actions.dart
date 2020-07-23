import 'package:ecoeden/app_routes.dart';
import 'package:ecoeden/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import '../app_routes.dart';
import 'app_state.dart';
import 'package:redux/redux.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:ecoeden/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const URL = 'https://api.ecoeden.xyz/auth/';

final CREATE_POST_URL = 'https://api.ecoeden.xyz/users/';

class NavigateReplaceAction {
  final String routeName;

  NavigateReplaceAction(this.routeName);

  @override
  String toString() {
    return 'MainMenuNavigateAction{routeName: $routeName}';
  }
}

class NavigatePushAction {
  final String routeName;

  NavigatePushAction(this.routeName);

  @override
  String toString() {
    return 'NavigatePushAction{routeName: $routeName}';
  }
}

class NavigatePopAction {

  @override
  String toString() {
    return 'NavigatePopAction';
  }
}

class NavigateClearAction {

  @override
  String toString() {
    return 'NavigateClearAction{}';
  }
}

class LoadingStartAction{
  @override
  String toString() {
    return 'LoadingStartAction';
  }
}

class LoadingEndAction{


  @override
  String toString() {
    return 'LoadingEndAction';
  }
}

class LatAction{

  final String lat;
  LatAction(this.lat);

  @override
  String toString() {
    return 'LatAction';
  }
}

class LngAction{

  final String lng;

  LngAction(this.lng);

  @override
  String toString() {
    return 'LngAction';
  }
}

class LogoutAction{
  @override
  String toString() {
    return 'LogoutAction';
  }


  ThunkAction<AppState> logout() {
    print('Inside logout');
    return (Store<AppState> store) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(prefs.getString('user'));
      if (prefs.getString('user') != null) {
        prefs.remove('user');
      }
      print(prefs.getString('user'));
      print(store.state.route.toString());
      store.dispatch(NavigatePushAction(AppRoutes.login));
      print(store.state.route.toString());
    };
  }
}

class userAction{
  final User user;

  userAction(this.user);

  @override
  String toString() {
    return 'userAction';
  }

}


class SignupAction{
  final User user;
  final BuildContext context;

  SignupAction({
    @required this.user,
    @required this.context
  });


  ThunkAction<AppState> signup( ){
    return (Store<AppState> store) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if ( prefs.getString('user') != null ){
        store.dispatch(NavigatePushAction(AppRoutes.home));
      }

      createUser( CREATE_POST_URL , body: user.toMap() ).then((user) => {
        store.dispatch(LoadingEndAction()),
        if (user.userName == null) {
          Toast.show("Username exists or Wrong Credentials!!!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM),
        }else {
          store.dispatch(NavigatePushAction(AppRoutes.login)),
        }
      }).catchError((e){
        print(e);
      });
    };
  }




  @override
  String toString(){
    return "SignupAction";
  }
}


class LoginAction{
  final String username;
  final String password;
  final BuildContext context;

  LoginAction({
    @required this.username,
    @required this.password,
    @required this.context
  });


  ThunkAction<AppState> login( ){
    return (Store<AppState> store) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if ( prefs.getString('user') != null){
        store.dispatch(NavigatePushAction(AppRoutes.home));
      }

      await attemptLogIn(username, password).then((String jwt) => {
        store.dispatch(LoadingEndAction()),
        if (jwt == null) {
          Toast.show("Incorrect username or password!!!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM),
        }else{
          prefs.setString('user', jwt),
          store.dispatch(NavigatePushAction(AppRoutes.home)),
        }
      }).catchError((e){
        print(e);
      });
    };
  }


  @override
  String toString(){
    return "LoginAction";
  }
}


Future<User> createUser(String url, {Map body}) async {

  return http.post(url, body: body).then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode == 201) {
      print("Success");
    }else{
      throw new Exception("Error while fetching data");
    }
    return User.fromJson(json.decode(response.body));
  });
}

Future<String> attemptLogIn(String username, String password) async {
  //lp.setLoader();

  print(username);
  print(password);
  var res = await http.post(
      URL,
      body: {
        "username": username,
        "password": password
      }
  );
  print(res.statusCode);
  print(json.decode(res.body)['token']);
  if (res.statusCode == 200) return json.decode(res.body)["token"];
  return null;
}


