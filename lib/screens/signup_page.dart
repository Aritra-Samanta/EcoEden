import 'package:ecoeden/main.dart';
import 'package:ecoeden/models/user.dart';
import 'package:ecoeden/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:ecoeden/redux/app_state.dart';
import 'package:loading_overlay/loading_overlay.dart';

class RegisterPage extends StatelessWidget {
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    EdgeInsets contentPadding = EdgeInsets.fromLTRB(0, 0, 0, 0);

    Widget showBackButton() {
      return Container(
        child: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            color: Color.fromRGBO(90, 203, 146, 1),
            icon: Icon(Icons.arrow_back, size: 25),
            onPressed: () => {Navigator.pop(context)},
          ),
        ),
      );
    }

    Widget showLogo() {
      return Container(
        child: Align(
          child: Image.asset('assets/EcoEden-Logo.png'),
        ),
      );
    }

    Widget showLogoBack() {
      return Container(
        height: height * 0.25,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              child: showBackButton(),
            ),
            Positioned.fill(
              child: showLogo(),
            )
          ],
        ),
      );
    }

    Widget showNameInput() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Container(
              padding: EdgeInsets.fromLTRB(25, 15, 10, 0),
              child: TextFormField(
                controller: firstName,
                maxLines: 1,
                autofocus: false,
                style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  contentPadding: contentPadding,
                  hintText: 'First Name',
                  labelText: 'First Name',
                  labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
                  suffixIcon: Container(
                    height: 0,
                    width: 0,
                  ),
                ),
                validator: (value) =>
                    value.isEmpty ? 'First Name can\'t be empty.' : null,
              ),
            ),
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.fromLTRB(25, 15, 10, 0),
              child: TextFormField(
                controller: lastName,
                maxLines: 1,
                autofocus: false,
                style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  contentPadding: contentPadding,
                  hintText: 'Last Name',
                  labelText: 'Last Name',
                  labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
                  suffixIcon: Container(
                    height: 0,
                    width: 0,
                  ),
                ),
                validator: (value) =>
                    value.isEmpty ? 'Last Name can\'t be empty.' : null,
              ),
            ),
          ),
        ],
      );
    }

    Widget showUserNameInput() {
      return Container(
        padding: EdgeInsets.fromLTRB(25, 5, 25, 0),
        child: TextFormField(
          controller: userName,
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: contentPadding,
            hintText: 'Username',
            labelText: 'Username',
            labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
            suffixIcon: Container(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ImageIcon(
                  AssetImage('assets/profile-pic-icon.png'),
                ),
              ),
            ),
          ),
          validator: (value) =>
              value.isEmpty ? 'Username can\'t be empty.' : null,
        ),
      );
    }

    Widget showMobileNumberInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
        child: TextFormField(
          controller: mobile,
          maxLines: 1,
          keyboardType: TextInputType.phone,
          style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
          autofocus: false,
          decoration: InputDecoration(
            contentPadding: contentPadding,
            hintText: 'Phone number',
            labelText: 'Phone Number',
            labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
            suffixIcon: Container(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ImageIcon(
                  AssetImage('assets/phone-icon.png'),
                ),
              ),
            ),
          ),
          validator: (value) =>
              value.isEmpty ? 'Mobile number can\'t be empty.' : null,
          //onSaved: (value) => mobile = value.trim(),
        ),
      );
    }

    Widget showEmailInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
        child: TextFormField(
          controller: email,
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: contentPadding,
            hintText: 'Email Address',
            labelText: 'Email Address',
            labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
            suffixIcon: Container(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ImageIcon(
                  AssetImage('assets/email-icon.png'),
                ),
              ),
            ),
          ),
          validator: (value) =>
              value.isEmpty ? 'Email can\'t be empty.' : null,
          //onSaved: (value) => email = value.trim(),
        ),
      );
    }

    Widget showPasswordInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
        child: TextFormField(
          controller: password,
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: contentPadding,
            hintText: 'Password',
            labelText: 'Password',
            labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
            suffixIcon: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ImageIcon(
                  AssetImage('assets/lock-icon.png'),
                ),
              ),
            ),
          ),
          validator: (value) =>
          value.isEmpty ? 'Password can\'t be empty.' : null,
          //onSaved: (value) => email = value.trim(),
        ),
      );
    }

    Widget showConfirmPasswordInput() {
      return Padding(
        padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
        child: TextFormField(
          controller: confirmPassword,
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          style: TextStyle(fontSize: 20, fontFamily: "SegoeUI", fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: contentPadding,
            hintText: 'Confirm Password',
            labelText: 'Confirm Password',
            labelStyle: TextStyle(fontFamily: "SegoeUI", fontSize: 18),
            suffixIcon: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ImageIcon(
                  AssetImage('assets/lock-icon.png'),
                ),
              ),
            ),
          ),
          validator: (value) =>
          value.isEmpty ? 'Password can\'t be empty.' : null,
          //onSaved: (value) => email = value.trim(),
        ),
      );
    }


    Widget showPrimaryButton(_ViewModel vm) {
      return Container(
        padding: EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 0),
        width: width,
        height: 80.0,
        child: RaisedButton(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Color.fromRGBO(98, 203, 146, 1),
          child: Text(
            'REGISTER',
            style: TextStyle(color: Colors.black,
                fontSize: 22.0,
                fontFamily: "SegoeUI",
                fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            User nuser = new User(
              firstName: firstName.text,
              lastName: lastName.text,
              email: email.text,
              userName: userName.text,
              mobile: mobile.text,
              password: confirmPassword.text,
            );
            vm.signup(nuser, context);
          },
        ),
      );
    }

    Widget showSecondaryButton(BuildContext context) {
      return FlatButton(
        child: Text(
          'Have an account? Sign in.',
          style: TextStyle(fontSize: 20.0,
              fontFamily: "SegoeUI",
              fontWeight: FontWeight.w300),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    Widget showForm(BuildContext c, _ViewModel vm) {
      return LoadingOverlay(
        opacity: 0.5,
        isLoading: global_store.state.isLoading,
        progressIndicator: CircularProgressIndicator(),
        child: Container(
          height: height,
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                showLogoBack(),
                showNameInput(),
                showUserNameInput(),
                showEmailInput(),
                showMobileNumberInput(),
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
      body: StoreConnector<AppState, _ViewModel>(
        converter: (store) => _ViewModel.create(store),
        builder: (context, _ViewModel vm) => Stack(
          children: <Widget>[
            showForm(context, vm),
          ],
        ),
      ),
    );
  }
}

class _ViewModel {
  final Function(User, BuildContext) signup;
  _ViewModel({
    this.signup,
  });
  factory _ViewModel.create(Store<AppState> store) {
    _signup(User user, BuildContext context) {
      store.dispatch(new LoadingStartAction());
      store.dispatch(new SignupAction(user: user, context: context).signup());
    }

    return _ViewModel(signup: _signup);
  }
}
