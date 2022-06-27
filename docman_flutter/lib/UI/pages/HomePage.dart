import 'package:docman_flutter/UI/customWidgets/AppBarWide.dart';
import 'package:docman_flutter/UI/customWidgets/AppBarNarrow.dart';
import 'package:docman_flutter/UI/pages/MyDocs.dart';
import 'package:docman_flutter/UI/pages/Shared.dart';
import 'package:docman_flutter/UI/pages/Trash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _advancedDrawerController = AdvancedDrawerController();
  Widget _body = const MyDocs();
  bool _selectedTile1 = true;
  bool _selectedTile2 = false;
  bool _selectedTile3 = false;
  int _selectedTile = 1;

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      openScale: 1.0,
      disabledGestures: true,
      childDecoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 0.0,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 128.0,
                height: 128.0,
                margin: const EdgeInsets.only(
                  top: 24.0,
                  bottom: 64.0,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'images/logo_white.png',
                ),
              ),
              ListTile(
                selected: _selectedTile1,
                selectedTileColor: const Color(0x20000000),
                onTap: () => setTileSelectedAndBody(1),
                leading: const Icon(Icons.file_copy_outlined),
                title: Text(AppLocalizations.of(context).mydocs),
              ),
              ListTile(
                selected: _selectedTile2,
                selectedTileColor: const Color(0x20000000),
                onTap: () => setTileSelectedAndBody(2),
                leading: const Icon(Icons.people_alt_outlined),
                title: Text(AppLocalizations.of(context).shareddocs),
              ),
              ListTile(
                selected: _selectedTile3,
                selectedTileColor: const Color(0x20000000),
                onTap: () => setTileSelectedAndBody(3),
                leading: const Icon(Icons.delete_outline_outlined),
                title: Text(AppLocalizations.of(context).trash),
              ),
              const Spacer(),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: const Text('Terms of Service | Privacy Policy'),
                ),
              ),
            ],
          ),
        ),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: LayoutBuilder(
              builder: (context, constraints) {
                if(constraints.maxWidth > 800) {
                  return AppBarWide(setTileSelectedAndBody, _selectedTile);
                }
                return AppBarNarrow(handleMenuButtonPressed);
              },
          ),
        ),
        body: _body,
      ),

    );
  }

  void setTileSelectedAndBody(int selection) {
    setState(() {
      switch(selection) {
        case 1: {
          _selectedTile = 1;
          _selectedTile1 = true;
          _selectedTile2 = false;
          _selectedTile3 = false;
          _body = const MyDocs();
          break;
        }
        case 2: {
          _selectedTile = 2;
          _selectedTile1 = false;
          _selectedTile2 = true;
          _selectedTile3 = false;
          _body = const Shared();
          break;
        }
        case 3: {
          _selectedTile = 3;
          _selectedTile1 = false;
          _selectedTile2 = false;
          _selectedTile3 = true;
          _body = const Trash();
          break;
        }
      }
    });
  }

  void handleMenuButtonPressed() {
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

}


