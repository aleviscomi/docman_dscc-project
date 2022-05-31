import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/Model.dart';
import '../../supports/LogInResult.dart';
import '../customWidgets/InputField.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _wrongCredentials = false;
  bool _isPassword = true;
  Icon _icon = Icon(Icons.visibility_outlined);

  bool _doingLogin = false;

  @override
  Widget build(BuildContext context) {
    return  _doingLogin ? Center(child: SizedBox(child: CircularProgressIndicator(), height: 100, width: 100,)) :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context).loginString, style: TextStyle(fontSize: 32, letterSpacing: 0.6)),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Icon(Icons.account_circle_outlined, size: 96, color: Theme.of(context).primaryColor),
              ),

              if(_wrongCredentials)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(AppLocalizations.of(context).wrongCredentials, style: TextStyle(fontSize: 18, letterSpacing: 0.6, color: Colors.red)),
                ),

              buildEmail(),
              buildPassword(),
              buildSubmit(),
            ],
          ),
        ),
      );
  }

  Widget buildEmail() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children : [
      Icon(Icons.person_outline, color: Colors.grey, size: 42),
      SizedBox(
        height: 85,
        width: 300,
        child: InputField(
          labelText: AppLocalizations.of(context).email,
          controller: _emailController,
          onSubmit: (value) { _doLogin(); },
        ),
      ),
    ]
  );

  Widget buildPassword() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children : [
        Icon(Icons.lock_outline, color: Colors.grey, size: 42),
        SizedBox(
          height: 85,
          width: 300,
          child: InputField(
            keyboardType: TextInputType.visiblePassword,
            isPassword: _isPassword,
            labelText: AppLocalizations.of(context).password,
            controller: _passwordController,
            onSubmit: (value) { _doLogin(); },
            suffixIcon: IconButton(icon: _icon, hoverColor: Colors.transparent, splashColor: Colors.transparent, focusColor: Colors.transparent, onPressed: _showPassword),
          ),
        ),
      ]
  );

  Widget buildSubmit() => Padding(
    padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
    child: MaterialButton(
      height: 40,
      minWidth: 340,
      onPressed: () { _doLogin(); },
      elevation: 10.0,
      color: Theme.of(context).primaryColor,
      child: Text(AppLocalizations.of(context).login, style: TextStyle(color: Colors.white, fontSize: 16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  void _showPassword() {
    setState(() {
      _isPassword = !_isPassword;
      _icon = _isPassword ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined);
    });
  }

  void _doLogin() async {
    setState(() {
      _doingLogin = true;
    });

    LogInResult result = await Model.sharedInstance.logIn(_emailController.text, _passwordController.text);

    if(result == LogInResult.logged) {
      Navigator.pushReplacementNamed(context, '/');
    }
    else if(result == LogInResult.error_wrong_credentials) {
      setState(() {
        _doingLogin = false;
        _wrongCredentials=true;
      });
    }
  }

}
