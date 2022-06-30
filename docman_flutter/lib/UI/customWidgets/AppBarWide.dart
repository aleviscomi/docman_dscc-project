import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/Model.dart';
import '../pages/Settings.dart';

class AppBarWide extends StatefulWidget {
  Function setTileAndBody;
  int selectedTile;

  AppBarWide(this.setTileAndBody, this.selectedTile, {Key key}) : super(key: key);

  @override
  State<AppBarWide> createState() => _AppBarWideState();
}

class _AppBarWideState extends State<AppBarWide> {
  Color _color1;
  Color _color2;
  Color _color3;
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
    switch(widget.selectedTile) {
      case 1: {
        _color1 = const Color(0x00000002);
        _color2 = null;
        _color3 = null;
        break;
      }
      case 2: {
        _color1 = null;
        _color2 = const Color(0x00000002);
        _color3 = null;
        break;
      }
      case 3: {
        _color1 = null;
        _color2 = null;
        _color3 = const Color(0x00000002);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      leadingWidth: 60,
      leading: const Image(
        image: AssetImage("images/logo_white.png"),
      ),
      title: Row(
        children: [
          MaterialButton(
            height: 80,
            color: _color1,
            onPressed: () => _btnAppBar(1),
            child: Text(AppLocalizations.of(context).mydocs, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
          MaterialButton(
            height: 80,
            color: _color2,
            onPressed: () => _btnAppBar(2),
            child: Text(AppLocalizations.of(context).shareddocs, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
          MaterialButton(
            height: 80,
            color: _color3,
            onPressed: () => _btnAppBar(3),
            child: Text(AppLocalizations.of(context).trash, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),

        ],
      ),
      actions: [
        PopupMenuButton(
          tooltip: "Menù",
          offset: const Offset(0, 70),
          onSelected: (result) async {
            switch(result) {
              case 0: {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings()));
                break;
              } //Navigator.pushNamed(context, '/settings'); break;
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
                    Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text(AppLocalizations.of(context).settings),)
                  ],
                )
            ),
            PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.black,),
                    Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text(AppLocalizations.of(context).logout),)
                  ],
                )
            ),
          ],
          child: Row(
            children: [
              Text(email, style: TextStyle(color: Colors.white, fontSize: 18)),
              Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  void _btnAppBar(int btn) {
    setState(() {
      switch(btn) {
        case 1: {
          _color1 = const Color(0x00000002);
          _color2 = null;
          _color3 = null;
          widget.setTileAndBody(1);
          break;
        }
        case 2: {
          _color1 = null;
          _color2 = const Color(0x00000002);
          _color3 = null;
          widget.setTileAndBody(2);
          break;
        }
        case 3: {
          _color1 = null;
          _color2 = null;
          _color3 = const Color(0x00000002);
          widget.setTileAndBody(3);
          break;
        }
      }
    });
  }
}
