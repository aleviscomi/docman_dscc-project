import 'package:docman_flutter/UI/customWidgets/FilterChipDisplay.dart';
import 'package:docman_flutter/UI/customWidgets/InputField.dart';
import 'package:docman_flutter/model/objects/Documento.dart';
import 'package:docman_flutter/supports/Constants.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import '../../model/Model.dart';
import '../../model/objects/Tag.dart';
import '../customWidgets/DataSourceTrashed.dart';
import '../customWidgets/UploadDialog.dart';

class Trash extends StatefulWidget {
  const Trash({Key key}) : super(key: key);

  @override
  _TrashState createState() => _TrashState();
}

class _TrashState extends State<Trash> {
  String nome = "";
  List<Documento> _trashedDocs = [];
  bool docsUploaded = false;

  int _rowPerPage = 5;

  @override
  void initState() {
    super.initState();
    Model.sharedInstance.getMyTrashedDocuments().then((result) {
      setState(() {
        _trashedDocs = result;
        docsUploaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: !docsUploaded ? const Center(child: SizedBox(height: 100, width: 100,child: CircularProgressIndicator(),)) :
        PaginatedDataTable(
          showCheckboxColumn: true,
          header: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(AppLocalizations.of(context).trash),
              )
            ],
          ),
          onRowsPerPageChanged: (r) {
            setState(() {
              _rowPerPage = r;
            });
          },
          availableRowsPerPage: const [5, 10, 15, 20],
          rowsPerPage: _rowPerPage,
          showFirstLastButtons: true,
          columns: [
            DataColumn(
              label: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(AppLocalizations.of(context).name),
              ),
            ),
            DataColumn(
              label: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.1,
                child: Text(AppLocalizations.of(context).date),
              ),
            ),
            DataColumn(
              label: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.1,
                child: Text(AppLocalizations.of(context).file_size),
              ),
            ),
            DataColumn(
              label: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.1,
                child: Text(AppLocalizations.of(context).actions),
              ),
            ),
          ],
          source: DataSourceTrashed(context, _trashedDocs, restore, permanentlyDelete),
        ),
      ),
    );
  }

  void restore(int idDoc) {
    setState(() {
      _trashedDocs.removeWhere((documento) => idDoc == documento.id);
    });
  }

  void permanentlyDelete(int idDoc) {
    setState(() {
      _trashedDocs.removeWhere((documento) => idDoc == documento.id);
    });
  }

}
