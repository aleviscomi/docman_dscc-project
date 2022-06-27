import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:docman_flutter/UI/customWidgets/InputField.dart';
import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/model/objects/Utente.dart';
import 'package:docman_flutter/supports/ModifyChoice.dart';
import 'package:docman_flutter/supports/ModifyResult.dart';

import '../../supports/ModifyChoice.dart';

class ModifyDialog extends StatefulWidget {
  final ModifyChoice modifyChoice;
  Utente utente;

  ModifyDialog({Key key, this.modifyChoice, this.utente}) : super(key: key);

  @override
  _ModifyDialogState createState() => _ModifyDialogState();
}

class _ModifyDialogState extends State<ModifyDialog> {
  TextEditingController _nameController;
  TextEditingController _surnameController;
  TextEditingController _emailController;
  TextEditingController _passwordController = TextEditingController();

  bool _nameEmpty = false;
  bool _emailEmpty = false;
  bool _passwordEmpty = false;

  bool _emailError = false;

  bool _isPassword = true;
  Icon _icon = Icon(Icons.visibility_outlined);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.utente.nome);
    _surnameController = TextEditingController(text: widget.utente.cognome);
    _emailController = TextEditingController(text: widget.utente.email);
  }

  void _showPassword() {
    setState(() {
      _isPassword = !_isPassword;
      _icon = _isPassword ? const Icon(Icons.visibility_outlined) : const Icon(Icons.visibility_off_outlined);
    });
  }

  @override
  Widget build(BuildContext context) {
    String choice;
    switch(widget.modifyChoice) {
      case ModifyChoice.NAME: choice = '${AppLocalizations.of(context).name} - ${AppLocalizations.of(context).surname}'; break;
      case ModifyChoice.EMAIL: choice = AppLocalizations.of(context).email; break;
      case ModifyChoice.PASSWORD: choice = AppLocalizations.of(context).password;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 9,
                child: Text("${AppLocalizations.of(context).modify} $choice", style: TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.center,)
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () { Navigator.pop(context); },
                )
              )
            ],
          ),
          const Divider(),

        ],
      ),
      content: Builder(
        builder: (context) {
          switch(widget.modifyChoice) {
            case ModifyChoice.NAME: return _modifyName(context); break;
            case ModifyChoice.EMAIL: return _modifyEmail(context); break;
            default: return _modifyPassword(context);
          }
        }
      ),
    );
  }


  Widget _modifyName(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 160,
      child: Column(
        children: [
          if(_nameEmpty)
            Text(AppLocalizations.of(context).nameOrSurnameEmpty, style: const TextStyle(fontSize: 16, letterSpacing: 0.6, color: Colors.red)),
          Row(
            children: [
              Expanded(
                child: InputField(
                  labelText: AppLocalizations.of(context).name,
                  controller: _nameController,
                  onSubmit: (value) { _modifyProfile(); },
                ),
              ),
              Expanded(
                child: InputField(
                  labelText: AppLocalizations.of(context).surname,
                  controller: _surnameController,
                  onSubmit: (value) { _modifyProfile(); },
                ),
              ),
            ],
          ),

          MaterialButton(
            height: 40,
            minWidth: 500,
            onPressed: () { _modifyProfile(); },
            elevation: 6.0,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(AppLocalizations.of(context).done, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _modifyEmail(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 160,
      child: Column(
        children: [
          if(_emailEmpty)
            Text(AppLocalizations.of(context).emailEmpty, style: const TextStyle(fontSize: 16, letterSpacing: 0.6, color: Colors.red)),
          if(_emailError)
            Text(AppLocalizations.of(context).emailAlreadyExists, style: const TextStyle(fontSize: 16, letterSpacing: 0.6, color: Colors.red)),
          Row(
            children: [
              Expanded(
                child: InputField(
                  labelText: AppLocalizations.of(context).email,
                  controller: _emailController,
                  onSubmit: (value) { _modifyProfile(); },
                ),
              ),
            ],
          ),

          MaterialButton(
            height: 40,
            minWidth: 500,
            onPressed: () { _modifyProfile(); },
            elevation: 6.0,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(AppLocalizations.of(context).done, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _modifyPassword(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 160,
      child: Column(
        children: [
          if(_passwordEmpty)
            Text(AppLocalizations.of(context).passwordNot8, style: const TextStyle(fontSize: 16, letterSpacing: 0.6, color: Colors.red)),
          Row(
            children: [
              Expanded(
                child: InputField(
                  isPassword: _isPassword,
                  labelText: AppLocalizations.of(context).password,
                  controller: _passwordController,
                  onSubmit: (value) {
                    if(_passwordController.text.length < 8) {
                      setState(() {
                        _passwordEmpty = true;
                      });
                    }
                    else {
                      _modifyProfile();
                    }
                  },
                  suffixIcon: IconButton(icon: _icon, hoverColor: Colors.transparent, splashColor: Colors.transparent, focusColor: Colors.transparent, onPressed: _showPassword),
                ),
              ),
            ],
          ),

          MaterialButton(
            height: 40,
            minWidth: 500,
            onPressed: () {
              if(_passwordController.text.length < 8) {
                setState(() {
                  _passwordEmpty = true;
                });
              }
              else {
                _modifyProfile();
              }
            },
            elevation: 6.0,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(AppLocalizations.of(context).done, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _modifyProfile() async {
    if(_nameController.text.isEmpty || _surnameController.text.isEmpty) {
      setState(() {
        _nameEmpty = true;
      });
      return;
    }
    if(_emailController.text.isEmpty) {
      setState(() {
        _emailError = false;
        _emailEmpty = true;
      });
      return;
    }

    Utente u = Utente(id: widget.utente.id, nome: _nameController.text, cognome: _surnameController.text, email: _emailController.text);

    ModifyResult result = await Model.sharedInstance.modifySettings(u, widget.utente.email, _passwordController.text);

    if(result == ModifyResult.modified) {
      /*
      * poiché se si cambia email si perde il token in quanto l'email registrata nel token poi differisce,
      * effettuo il logout in quanto non posso riloggarmi non potendo accedere alla password
      * (effettuo il logout anche in caso di cambio di password essendo insieme all'email un'informazione
      * di accesso)
      */
      if (_passwordController.text != "" ||
          _emailController.text != widget.utente.email) {
        Model.sharedInstance.logOut();
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/');
      }
      else {
        Navigator.pop(context, u);
      }
    }
    else if(result == ModifyResult.mail_already_exists) {
      setState(() {
        _emailEmpty = false;
        _emailError = true;
      });
    }
  }
}
