import 'package:flutter/material.dart';
import 'package:docman_flutter/UI/pages/LoginRegister.dart';
import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/UI/pages/HomePage.dart';

class Initial extends StatefulWidget {
  const Initial({Key key}) : super(key: key);

  @override
  _InitialState createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Model.sharedInstance.hasToken(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if (snapshot.data) { //if(snapshot.data) restituisce true se hasToken() dà true
            /** questo in modo che, se sono loggato, e ricarico la pagina e di conseguenza perdo il
             * periodic del refresh, lo rieseguo (con shared preferences non perdo il refresh token)
             */
            Model.sharedInstance.refreshAndDoPeriodic();

            return HomePage();
          }
          return LoginRegister();
        }
        return CircularProgressIndicator();
      },
    );

  }
}
