import 'package:docman_flutter/UI/pages/HomePage.dart';
import 'package:docman_flutter/UI/pages/Initial.dart';
import 'package:docman_flutter/UI/pages/LoginRegister.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../supports/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.APP_NAME,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('it', ''),
      ],
      theme: ThemeData(
        primaryColor: Constants.PRIMARY_COLOR,
        tabBarTheme: TabBarTheme(labelColor: Colors.blue),
      ),
      routes: mainRouting(),
    );
  }

  Map<String, WidgetBuilder> mainRouting() {
    return {
      '/': (context) => const Initial(),
    };
  }
}
