import 'package:docman_flutter/UI/customWidgets/FilterChipDisplay.dart';
import 'package:docman_flutter/UI/customWidgets/InputField.dart';
import 'package:docman_flutter/model/objects/Documento.dart';
import 'package:docman_flutter/supports/Constants.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import '../../model/Model.dart';
import '../../model/objects/Tag.dart';
import '../customWidgets/DataSourceShared.dart';
import '../customWidgets/UploadDialog.dart';

class Shared extends StatefulWidget {
  const Shared({Key key}) : super(key: key);

  @override
  _SharedState createState() => _SharedState();
}

class _SharedState extends State<Shared> {
  String nome = "";
  List<Documento> _sharedDocs = [];
  bool docsUploaded = false;
  bool isDownloading = false;
  bool isUnsharing = false;

  int _rowPerPage = 5;

  @override
  void initState() {
    super.initState();
    Model.sharedInstance.getSharedWithMeDocuments().then((result) {
      if(mounted) {
        setState(() {
          _sharedDocs = result;
          docsUploaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: !docsUploaded ? const Center(child: SizedBox(height: 100, width: 100,child: CircularProgressIndicator(),)) :
        Column(
          children: [
            if(isDownloading || isUnsharing)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: LinearProgressIndicator(),
              ),
            PaginatedDataTable(
              showCheckboxColumn: true,
              header: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Text(AppLocalizations.of(context).shareddocs),
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
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Text(AppLocalizations.of(context).name),
                  ),
                ),
                DataColumn(
                  label: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Text(AppLocalizations.of(context).sharedby),
                  ),
                ),
                DataColumn(
                  label: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Text(AppLocalizations.of(context).actions),
                  ),
                ),
              ],
              source: DataSourceShared(context, _sharedDocs, unshare, download),
            ),
          ],
        ),
      ),
    );
  }

  void download(bool start) {
    setState(() {
      isDownloading = start;
    });
  }

  void unshare(int idDoc) {
    setState(() {
      if(idDoc == -1) {
        isUnsharing = true;
      }
      else {
        isUnsharing = false;
        _sharedDocs.removeWhere((documento) => idDoc == documento.id);
      }
    });
  }

}
