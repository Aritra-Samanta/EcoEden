import 'package:ecoeden/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:ecoeden/redux/app_state.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ecoeden/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_routes.dart';

const URL = 'https://api.ecoeden.xyz/auth/';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //String _email;
  //String _password;
  bool _isLoading = false; // flag to denote if loading
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getState();
  }

  void getState() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString('user')!=null)
      global_store.dispatch(new NavigatePushAction(AppRoutes.home));
  }


  @override
  Widget build(BuildContext context) {
    // Loading indicator
    Widget showCircularProgress() {
      if (_isLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }

    Widget showLogo() {
      return Hero(
        tag: 'hero',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 80.0,
            child: Image.asset('assets/EcoEden-Logo.png'),
          ),
        ),
      );
    }

    Widget showUserNameInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
        child: TextFormField(
          controller: _usernameController,
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Username',
            icon: Icon(
              Icons.account_circle,
              color: Colors.grey,
            ),
          ),
          validator: (value) =>
          value.isEmpty
              ? 'Email cant\'t be empty.'
              : null,
          //onSaved: (value) => _email = value.trim(),
        ),
      );
    }

    Widget showPasswordInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: TextFormField(
          controller: _passwordController,
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Password',
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            ),
          ),
          validator: (value) =>
          value.isEmpty
              ? 'Password can\'t be empty'
              : null,
          //onSaved: (value) => _password = value.trim(),
        ),
      );
    }

    Widget showPrimaryButton(_ViewModel vm) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          width: 30.0,
          height: 50.0,
          child: RaisedButton(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              child: Text(
                'Log in',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              onPressed: () async {
                vm.login(_usernameController.text, _passwordController.text,context);
              }),
        ),
      );
    }

    Widget showSecondaryButton(BuildContext context) {
      return FlatButton(
        child: Text(
          'Create a new account',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
        ),
        onPressed: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => RegisterPage()),
//          );
          StoreProvider.of<AppState>(context).dispatch(NavigatePushAction(AppRoutes.signup));
//            store.dispatch(NavigatePushAction(AppRoutes.signup));
        },
      );
    }

    // User login form
    Widget showForm(BuildContext c , _ViewModel vm) {
      return LoadingOverlay(
        isLoading: global_store.state.isLoading,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            //key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                showLogo(),
                showUserNameInput(),
                showPasswordInput(),
                showPrimaryButton(vm),
                showSecondaryButton(c),
              ],
            ),
          ),
        ),
      );
    }


    return Scaffold(

      appBar: AppBar(
        title: Text('Register'),
      ),

      body: StoreConnector<AppState, _ViewModel>(

        converter: (store) => _ViewModel.create(store),
        builder: (context, _ViewModel vm) =>
            Stack(
              children: <Widget>[
                showForm(context, vm),
              ],
            ),
      ),
    );
  }
}


class _ViewModel{
  final Function(String, String,BuildContext) login;
  _ViewModel({
    this.login
  });
  factory _ViewModel.create(Store<AppState> store){
    _login(String username, String password,BuildContext context){
      store.dispatch(new LoadingStartAction());
      store.dispatch(new LoginAction(username: username, password: password,context: context).login());
    }
    return _ViewModel(
        login: _login
    );
  }
}