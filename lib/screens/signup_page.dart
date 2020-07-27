import 'package:ecoeden/main.dart';
import 'package:ecoeden/models/user.dart';
import 'package:ecoeden/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:ecoeden/redux/app_state.dart';
import 'package:loading_overlay/loading_overlay.dart';




class RegisterPage extends StatelessWidget{

  final _formKey = new GlobalKey<FormState>();

  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final mobile = TextEditingController();
  final userName = TextEditingController();


  @override
  Widget build(BuildContext context) {


    Widget showNameInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: TextFormField(
                controller: firstName,
                maxLines: 1,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'First Name',
                  icon: Icon(
                    Icons.face,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.only(top: 0.0, bottom: 10.0),
                  isDense: true,
                ),
                validator: (value) => value.isEmpty ? 'First Name cant\'t be empty.' : null,
                //onSaved: (value) => firstName = value.trim(),
              ),
            ),
            SizedBox(width: 16.0,),
            Flexible(
              child: TextFormField(
                controller: lastName,
                maxLines: 1,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  contentPadding: EdgeInsets.only(top: 0.0, bottom: 10.0),
                  isDense: true,
                ),
                validator: (value) => value.isEmpty ? 'Last Name cant\'t be empty.' : null,
                //onSaved: (value) => lastName = value.trim(),
              ),
            ),
            SizedBox(width: 16.0,),
          ],
        ),
      );
    }


    Widget showLogo() {
      return Hero(
        tag: 'hero',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 8.0),
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
        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
        child: TextFormField(
          controller: userName,
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Username',
            icon: Icon(
              Icons.account_circle,
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.only(top: 11.0, bottom: 10.0),
            isDense: true,
          ),
          validator: (value) => value.isEmpty ? 'Email cant\'t be empty.' : null,
          //onSaved: (value) => userName = value.trim(),
        ),
      );
    }

    Widget showMobileNumberInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
        child: TextFormField(
          controller: mobile,
          maxLines: 1,
          keyboardType: TextInputType.phone,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Phone number',
            icon: Icon(
              Icons.phone,
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.only(top: 11.0, bottom: 10.0),
            isDense: true,
          ),
          validator: (value) => value.isEmpty ? 'Email cant\'t be empty.' : null,
          //onSaved: (value) => mobile = value.trim(),
        ),
      );
    }

    Widget showEmailInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
        child: TextFormField(
          controller: email,
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Email',
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.only(top: 11.0, bottom: 10.0),
            isDense: true,
          ),
          validator: (value) => value.isEmpty ? 'Email cant\'t be empty.' : null,
          //onSaved: (value) => email = value.trim(),
        ),
      );
    }

    Widget showPasswordInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
        child: TextFormField(
          controller: password,
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Password',
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.only(top: 11.0, bottom: 10.0),
            isDense: true,
          ),
          validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
          //onSaved: (value) => password = value.trim(),
        ),
      );
    }

    Widget showConfirmPasswordInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
        child: TextFormField(
          controller: confirmPassword,
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.only(top: 11.0, bottom: 10.0),
            isDense: true,
          ),
          validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
          //onSaved: (value) => confirmPassword = value.trim(),
        ),
      );
    }

    Widget showPrimaryButton(_ViewModel vm) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
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
              'Register',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            onPressed: () {

              User nuser = new User(
                firstName: firstName.text,
                lastName:  lastName.text,
                email:     email.text,
                userName:  userName.text,
                mobile:    mobile.text,
                password : confirmPassword.text,

              );
              vm.signup(nuser,context);


            },
          ),
        ),
      );
    }

    Widget showSecondaryButton(BuildContext context) {
      return FlatButton(
        child: Text(
          'Have an account? Sign in.',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
        ),
        onPressed: () {
          StoreProvider.of<AppState>(context).dispatch(NavigatePopAction());
        },
      );
    }

    Widget showForm(BuildContext c , _ViewModel vm) {
      return LoadingOverlay(
        opacity: 0.5,
        isLoading: global_store.state.isLoading,
        progressIndicator: CircularProgressIndicator(),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                showLogo(),
                showNameInput(),
                showUserNameInput(),
                showMobileNumberInput(),
                showEmailInput(),
                showPasswordInput(),
                showConfirmPasswordInput(),
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

      body: StoreConnector<AppState ,_ViewModel> (

        converter:(store) => _ViewModel.create(store),
        builder: ( context ,_ViewModel vm ) =>
            Stack(
              children: <Widget>[
                showForm(context , vm),
              ],
            ),
      ),
    );


  }
}


class _ViewModel{
  final Function(User,BuildContext) signup;
  _ViewModel({
    this.signup,
  });
  factory _ViewModel.create(Store<AppState> store){
    _signup(User user,BuildContext context){
      store.dispatch(new LoadingStartAction());
      store.dispatch(new SignupAction(user: user,context: context).signup());
    }
    return _ViewModel(
        signup: _signup
    );
  }
}
