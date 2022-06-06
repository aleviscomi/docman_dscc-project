import 'package:auto_size_text/auto_size_text.dart';
import 'package:docman_flutter/UI/customWidgets/AutocompleteSearchUserField.dart';
import 'package:docman_flutter/UI/customWidgets/InputField.dart';
import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/model/objects/Utente.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/objects/Documento.dart';

class SharingCenter extends StatefulWidget {
  Documento documento;

  SharingCenter(this.documento, {Key key}) : super(key: key);

  @override
  State<SharingCenter> createState() => _SharingCenterState();
}

class _SharingCenterState extends State<SharingCenter> {
  List<Utente> giaCondivisi = [];

  @override
  void initState() {
    super.initState();
    Model.sharedInstance.getAlreadySharedUsers(widget.documento.id).then((result) {
      setState(() {
        giaCondivisi = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          buildHeader(),
          Divider(),
        ],
      ),
      content: Container(
        width: 500,
        height: 400,
        child: Column(
          children: [
            AutocompleteShareUserField(widget.documento),
            _buildSharedList(),
          ],
        )
      ),
    );
  }

  Widget buildHeader() => ListTile(
    title: Center(child: Container(constraints: BoxConstraints(maxWidth: 400), child: Text("${widget.documento.titolo}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis,))),
    trailing: IconButton(
      icon: Icon(Icons.close),
      onPressed: () { Navigator.pop(context); },
    ),
  );

  Widget _buildSharedList() => Column(
    children: [
      Container(
        constraints: BoxConstraints.expand(height: 30, width: 450),
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: AutoSizeText("${AppLocalizations.of(context).alreadyShared}: ", style: TextStyle(fontWeight: FontWeight.w600,), overflow: TextOverflow.ellipsis),
      ),
      SingleChildScrollView(
        child: Container(
          height: 270,
          child: ListView.separated(
            itemCount: giaCondivisi.length,
            itemBuilder: (context, index) => ListTile(
              leading: Container(width: 40, height: 40, child: Icon(Icons.person, color: Colors.blueGrey,), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), border: Border.all(color: Colors.blueGrey)),),
              title: Text("${giaCondivisi[index].nome} ${giaCondivisi[index].cognome}"),
              subtitle: Text("${giaCondivisi[index].email}"),
              trailing: IconButton(
                icon: Icon(Icons.person_remove_alt_1_outlined),
                onPressed: () {
                  Model.sharedInstance.removeAccessDocument(widget.documento.id, giaCondivisi[index].id).then((result) {
                    if(result) {
                      Navigator.pop(context);
                      showDialog(context: context, builder: (context) => SharingCenter(widget.documento));
                    }
                  });
                },
              ),
            ),
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ),
    ],
  );

}
