import 'package:docman_flutter/model/objects/Utente.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/Model.dart';
import '../../supports/ModifyChoice.dart';
import '../customWidgets/ModifyDialog.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Utente utente = Utente();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    Model.sharedInstance.getLoggedUser().then((result) {
      if(mounted) {
        setState(() {
          utente = result;
          _loading = false;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings,),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white,),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        toolbarHeight: 70,
      ),

      body: _loading ? const Center(child: SizedBox(child: CircularProgressIndicator(), height: 100, width: 100,)) :
      SingleChildScrollView(
        child: Container(
          height: 500,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildNameSurname(),
              buildEmail(),
              buildPassword(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNameSurname() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Row(
      children: [
        Expanded(
          flex: 7,
          child: ListTile(
            title: Text('${AppLocalizations.of(context).name} - ${AppLocalizations.of(context).surname}', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text('${utente.nome} ${utente.cognome}'),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: MaterialButton(
            height: 40,
            onPressed: () async {
              Utente u = await showDialog(
                context: context,
                builder: (context) {
                  return ModifyDialog(modifyChoice: ModifyChoice.NAME, utente: utente,);
                }
              );
              if(u != null) { //nel caso in cui si preme la x per chiudere il dialog
                setState(() {
                  utente = u;
                });
              }
            },
            elevation: 6.0,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(AppLocalizations.of(context).modify, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    ),
  );

  Widget buildEmail() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Row(
      children: [
        Expanded(
          flex: 7,
          child: ListTile(
            title: Text(AppLocalizations.of(context).email, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text(utente.email),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: MaterialButton(
            height: 40,
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return ModifyDialog(modifyChoice: ModifyChoice.EMAIL, utente: utente,);
                }
              );
            },
            elevation: 6.0,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(AppLocalizations.of(context).modify, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    ),
  );

  Widget buildPassword() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Row(
      children: [
        Expanded(
          flex: 7,
          child: ListTile(
            title: Text(AppLocalizations.of(context).password, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Text("********"),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: MaterialButton(
            height: 40,
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return ModifyDialog(modifyChoice: ModifyChoice.PASSWORD, utente: utente,);
                }
              );
            },
            elevation: 6.0,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(AppLocalizations.of(context).modify, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    ),
  );
}
