import 'package:docman_flutter/UI/customWidgets/InputField.dart';
import 'package:docman_flutter/model/objects/Documento.dart';
import 'package:docman_flutter/supports/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../model/Model.dart';
import '../customWidgets/DataSource.dart';

class MyDocs extends StatefulWidget {
  const MyDocs({Key key}) : super(key: key);

  @override
  _MyDocsState createState() => _MyDocsState();
}

class _MyDocsState extends State<MyDocs> {
  String nome = "";
  List<Documento> _docs = [];

  @override
  void initState() {
    super.initState();
    Model.sharedInstance.getDataFromToken().then((result) {
      setState(() {
        nome = result["given_name"];
      });
    });

    Model.sharedInstance.getMyDocuments().then((result) {
      setState(() {
        _docs = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          InputField(
            hint: AppLocalizations.of(context).search,
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {  },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: PaginatedDataTable(
              showCheckboxColumn: true,
              header: Text("${AppLocalizations.of(context).docsof} $nome"),
              rowsPerPage: 5,
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
              source: DataSource(context, _docs),
            ),
          ),
        ],
      ),
    );
  }
}
