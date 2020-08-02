import 'package:ecoeden/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:ecoeden/redux/app_state.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ecoeden/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_routes.dart';
import 'signup_page.dart';

const URL = 'https://api.ecoeden.xyz/auth/';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getState();
  }

  void getState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null)
      global_store.dispatch(new NavigatePushAction(AppRoutes.home));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Widget showLogo() {
      return Container(
        height: height * 0.42,
        width: width,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              width: width / 2,
              height: height * 0.5,
              child: Image.asset('assets/EcoEden-Logo.png')),
        ),
      );
    }

    Widget showUserNameInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: TextFormField(
          controller: _usernameController,
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Username',
            labelText: 'Username',
            labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
            suffixIcon: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: ImageIcon(
                AssetImage('assets/profile-pic-icon.png'),
              ),
            ),
          ),
          validator: (value) =>
          value.isEmpty ? 'Email cant\'t be empty.' : null,
        ),
      );
    }

    Widget showPasswordInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: TextFormField(
          controller: _passwordController,
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Password',
            labelText: 'Password',
            labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
            suffixIcon: Container(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
              child: ImageIcon(
                AssetImage('assets/lock-icon.png'),
              ),
            ),
          ),
          validator: (value) =>
          value.isEmpty ? 'Password can\'t be empty' : null,
        ),
      );
    }

    Widget showForgotButton() {
      return Container(
        height: 40,
        padding: EdgeInsets.fromLTRB(0, 8, 12, 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            child: Text(
              'Forgot Password?',
              style: TextStyle(fontSize: 16.0,
                  fontFamily: "SegoeUI",
                  fontWeight: FontWeight.w400),
            ),
            onPressed: () {
            },
          ),
        ),
      );
    }

    Widget showPrimaryButton(_ViewModel vm) {
      return Container(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
        width: width,
        height: 60.0,
        child: RaisedButton(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Color.fromRGBO(98, 203, 146, 1),
            child: Text(
              'LOGIN',
              style: TextStyle(color: Colors.black,
                  fontSize: 22.0,
                  fontFamily: "SegoeUI",
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () async {
              vm.login(_usernameController.text, _passwordController.text,
                  context);
            }),
      );
    }

    Widget showSecondaryButton(BuildContext context) {
      return FlatButton(
        child: Text(
          'Create a new account',
          style: TextStyle(fontSize: 20.0,
              fontFamily: "SegoeUI",
              fontWeight: FontWeight.w300),
        ),
        onPressed: () {
          StoreProvider.of<AppState>(context).dispatch(NavigatePushAction(AppRoutes.signup));
        },
      );
    }

    Widget showTernaryButton(_ViewModel vm) {
      return Container(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
        width: width / 1.9,
        height: 50.0,
        child: RaisedButton(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.blueGrey[100],
            child: Text(
              'Upload as Anonymous',
              style: TextStyle(color: Colors.black,
                  fontSize: 14.0,
                  fontFamily: "SegoeUI",
                  fontWeight: FontWeight.w400),
            ),
            onPressed: () async {
              vm.login("anonymous","anonymous2020",
                  context);
            }),
      );
    }

    // User login form
    Widget showForm(BuildContext c, _ViewModel vm) {
      return Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              showUserNameInput(),
              showPasswordInput(),
              showForgotButton(),
              showPrimaryButton(vm),
              showSecondaryButton(c),
              showTernaryButton(vm)
            ],
          ),
        ),
      );
    }



    return Scaffold(
      body: StoreConnector<AppState, _ViewModel>(
        converter: (store) => _ViewModel.create(store),
        builder: (context, _ViewModel vm) => LoadingOverlay(
          isLoading: global_store.state.isLoading,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          child: ListView(
            children: <Widget>[
              showLogo(),
              showForm(context, vm)
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModel {
  final Function(String, String, BuildContext) login;
  _ViewModel({this.login});
  factory _ViewModel.create(Store<AppState> store) {
    _login(String username, String password, BuildContext context) {
      store.dispatch(new LoadingStartAction());
      if(username=="anonymous" && password== "anonymous2020")
        store.dispatch(new LoginAction(
            username: username, password: password, context: context)
            .login(true));
      else
        store.dispatch(new LoginAction(
            username: username, password: password, context: context)
            .login(false));
    }

    return _ViewModel(login: _login);
  }
}
