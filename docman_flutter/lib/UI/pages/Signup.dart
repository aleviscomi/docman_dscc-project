import 'package:flutter/material.dart';
import 'package:docman_flutter/UI/customWidgets/InputField.dart';
import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/model/objects/Utente.dart';
import 'package:docman_flutter/supports/Constants.dart';
import 'package:docman_flutter/supports/SignUpResult.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Signup extends StatefulWidget {
  const Signup({Key key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _repeatPasswordController = TextEditingController();

  bool _isPassword = true;
  Icon _icon = Icon(Icons.visibility_outlined);
  bool _isRepeatPassword = true;
  Icon _iconRepeat = Icon(Icons.visibility_outlined);
  String _errorNameOrUnknown = "";
  String _errorEmail = "";
  String _errorPassword = "";

  bool _doingSignup = false;

  void _showPassword() {
    setState(() {
      _isPassword = !_isPassword;
      _icon = _isPassword ? Icon(Icons.visibility_outlined) : Icon(Icons.visibility_off_outlined);
    });
  }

  void _showRepeatPassword() {
    setState(() {
      _isRepeatPassword = !_isRepeatPassword;
      _iconRepeat = _isRepeatPassword ? Icon(Icons.visibility_outlined) : Icon(Icons.visibility_off_outlined);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _doingSignup ?
      Center(child: SizedBox(child: CircularProgressIndicator(), height: 100, width: 100,)) :
      Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildHeader(),

              if(_errorNameOrUnknown.isNotEmpty)
                Text(_errorNameOrUnknown, style: TextStyle(fontSize: 12, letterSpacing: 0.6, color: Colors.red)),

              buildName(),

              if(_errorEmail.isNotEmpty)
                Text(_errorEmail, style: TextStyle(fontSize: 12, letterSpacing: 0.6, color: Colors.red)),

              buildEmail(),

              if(_errorPassword.isNotEmpty)
                Text(_errorPassword, style: TextStyle(fontSize: 12, letterSpacing: 0.6, color: Colors.red)),

              buildPassword(),
              buildRepeatPassword(),
              buildSubmit(),
            ],
          ),
        ),
      );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Text("- ${AppLocalizations.of(context).createAccount} -", style: TextStyle(fontSize: 32, letterSpacing: 0.6)),
        Container(
          width: 425,
          child: Divider(),
        ),
      ],
    );
  }

  Widget buildName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children : [
        Icon(Icons.person_outline, color: Colors.grey, size: 42),
        Container(
          height: 75,
          width: 200,
          child: InputField(
            onSubmit: (value) { _register(); },
            labelText: AppLocalizations.of(context).name,
            controller: _nameController,
          ),
        ),
        Container(
          height: 75,
          width: 200,
          child: InputField(
            onSubmit: (value) { _register(); },
            labelText: AppLocalizations.of(context).surname,
            controller: _surnameController,
          ),
        ),
      ]
    );
  }

  Widget buildEmail() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children : [
          Icon(Icons.email, color: Colors.grey, size: 42),
          Container(
            height: 75,
            width: 400,
            child: InputField(
              onSubmit: (value) { _register(); },
              labelText: AppLocalizations.of(context).email,
              controller: _emailController,
            ),
          ),
        ]
    );
  }

  Widget buildPassword() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children : [
          Icon(Icons.lock_outline, color: Colors.grey, size: 42),
          Container(
            height: 75,
            width: 400,
            child: InputField(
              onSubmit: (value) { _register(); },
              isPassword: _isPassword,
              labelText: AppLocalizations.of(context).password,
              controller: _passwordController,
              suffixIcon: IconButton(icon: _icon, hoverColor: Colors.transparent, splashColor: Colors.transparent, focusColor: Colors.transparent, onPressed: _showPassword),
            ),
          ),
        ]
    );
  }

  Widget buildRepeatPassword() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children : [
          Icon(Icons.vpn_key_outlined, color: Colors.grey, size: 42),
          Container(
            height: 75,
            width: 400,
            child: InputField(
              onSubmit: (value) { _register(); },
              isPassword: _isRepeatPassword,
              labelText: AppLocalizations.of(context).repeatPassword,
              controller: _repeatPasswordController,
              suffixIcon: IconButton(icon: _iconRepeat, hoverColor: Colors.transparent, splashColor: Colors.transparent, focusColor: Colors.transparent, onPressed: _showRepeatPassword),
            ),
          ),
        ]
    );
  }

  Widget buildSubmit() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: MaterialButton(
        height: 40,
        minWidth: 430,
        onPressed: () { _register(); },
        elevation: 10.0,
        color: Theme.of(context).primaryColor,
        child: Text(AppLocalizations.of(context).signup, style: TextStyle(color: Colors.white, fontSize: 16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _register() async {
    // Controlli iniziali
    if(_nameController.text.isEmpty || _surnameController.text.isEmpty) {
      setState(() {
        _errorNameOrUnknown = AppLocalizations.of(context).nameOrSurnameEmpty;
      });
    } else {
      setState(() {
        _errorNameOrUnknown = "";
      });
    }
    if(_emailController.text.isEmpty) {
      setState(() {
        _errorEmail = AppLocalizations.of(context).emailEmpty;
      });
    } else {
      setState(() {
        _errorEmail = "";
      });
    }
    if(_passwordController.text.length < 8) {
      setState(() {
        _errorPassword = AppLocalizations.of(context).passwordNot8;
      });
    } else {
      setState(() {
        _errorPassword = "";
      });
    }

    // Registrazione
    if(!(_nameController.text.isEmpty || _surnameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.length < 8)) {
      if(_passwordController.text != _repeatPasswordController.text) {
        setState(() {
          _errorPassword = AppLocalizations.of(context).passwordsNotMatch;
        });
        return;
      }

      setState(() {
        _doingSignup = true;
      });

      Utente utente = Utente(nome: _nameController.text, cognome: _surnameController.text, email: _emailController.text);
      SignUpResult status = await Model.sharedInstance.addUser(utente, _passwordController.text);
      switch(status) {
        case SignUpResult.mail_already_exists:
          setState(() {
            _doingSignup = false;
            _errorEmail = AppLocalizations.of(context).emailAlreadyExists;
          });
          return;
        case SignUpResult.unknown_error:
          setState(() {
            _doingSignup = false;
            _errorNameOrUnknown = AppLocalizations.of(context).unknownError;
          });
          return;
      }

      // Login dopo registrazione
      await Model.sharedInstance.logIn(_emailController.text, _passwordController.text);

      Navigator.pushReplacementNamed(context, '/');
    }
  }
}
