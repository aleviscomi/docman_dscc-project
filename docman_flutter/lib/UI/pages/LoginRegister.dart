import 'package:flutter/material.dart';
import 'package:docman_flutter/UI/customWidgets/InputField.dart';
import 'package:docman_flutter/UI/pages/Signup.dart';
import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/supports/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:docman_flutter/supports/LogInResult.dart';
import 'package:docman_flutter/UI/pages/Login.dart';

class LoginRegister extends StatefulWidget {
  LoginRegister({Key key}) : super(key: key);

  @override
  _LoginRegisterState createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.APP_NAME, style: TextStyle(fontSize: 42, fontStyle: FontStyle.italic)),
        centerTitle: true,
        toolbarHeight: 70,
        leading: Container(),
      ),
      body: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: TabBar(
              tabs: [
                Tab(text: AppLocalizations.of(context).login, icon: Icon(Icons.login_rounded)),
                Tab(text: AppLocalizations.of(context).signup, icon: Icon(Icons.supervised_user_circle))
              ],
            ),
            body: const TabBarView(
              children: [
                Login(),
                Signup(),
              ],
            ),
          ),
        ),
    );
  }
}