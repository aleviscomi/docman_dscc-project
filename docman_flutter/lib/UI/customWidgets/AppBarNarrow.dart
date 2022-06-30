import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/Model.dart';
import '../pages/MyDocs.dart';
import '../pages/Settings.dart';
import '../pages/Shared.dart';
import '../pages/Trash.dart';

class AppBarNarrow extends StatefulWidget {
  Function openDrawerCallback;

  AppBarNarrow(this.openDrawerCallback, {Key key}) : super(key: key);

  @override
  State<AppBarNarrow> createState() => _AppBarNarrowState();
}

class _AppBarNarrowState extends State<AppBarNarrow> {
  String email = "";

  @override
  void initState() {
    super.initState();
    Model.sharedInstance.getDataFromToken().then((result) {
      if(mounted) {
        setState(() {
          email = result["email"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      leadingWidth: 60,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: widget.openDrawerCallback,
      ),
      actions: [
        PopupMenuButton(
          tooltip: "Menù",
          offset: const Offset(0, 70),
          onSelected: (result) async {
            switch(result) {
              case 0:
              case 0: {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                break;
              }
              case 1: {
                await Model.sharedInstance.logOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacementNamed(context, '/');
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.black,),
                    Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text(AppLocalizations.of(context).settings),)
                  ],
                )
            ),
            PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.black,),
                    Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text(AppLocalizations.of(context).logout),)
                  ],
                )
            ),
          ],
          child: Row(
            children: [
              Text(email, style: const TextStyle(color: Colors.white, fontSize: 18)),
              Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
