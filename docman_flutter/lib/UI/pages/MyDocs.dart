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
import '../customWidgets/DataSourceDocs.dart';
import '../customWidgets/UploadDialog.dart';

class MyDocs extends StatefulWidget {
  const MyDocs({Key key}) : super(key: key);

  @override
  _MyDocsState createState() => _MyDocsState();
}

class _MyDocsState extends State<MyDocs> {
  String nome = "";
  List<Documento> _docs = [];
  List<Documento> _searchedDocs = [];
  List<Documento> _filteredDocs = [];
  bool docsUploaded = false;
  TextEditingController _controllerSearch = TextEditingController();
  Icon iconFilter;

  List<Tag> tagsList = [];
  List<String> typesList = [];
  List<Tag> selectedTags = [];
  List<String> selectedTypes = [];

  bool isDownloading = false;
  bool isDeleting = false;

  int _rowPerPage = 5;
  final _keyPaginatedTable = GlobalKey<PaginatedDataTableState>();

  @override
  void initState() {
    super.initState();
    iconFilter = Icon(Icons.tune_rounded);
    Model.sharedInstance.getDataFromToken().then((result) {
      if(mounted) {
        setState(() {
          nome = result["given_name"];
        });
      }
    });

    Model.sharedInstance.getMyDocuments().then((result) {
      if(mounted) {
        setState(() {
          _docs = result;
          docsUploaded = true;
        });
      }
    });


    Model.sharedInstance.getTagsByUser().then((result) {
      if(mounted) {
        setState(() {
          tagsList = result;
        });
      }
    });
    Model.sharedInstance.getTypesByUser().then((result) {
      if(mounted) {
        setState(() {
          typesList = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InputField(
                  controller: _controllerSearch,
                  hint: AppLocalizations.of(context).search,
                  onSubmit: (value) => _search(),
                  onChanged: (value) => _search(),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: IconButton(
                      icon: const Icon(Icons.search, size: 22),
                      onPressed: () {
                        _search();
                      },
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 20, 0),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)), color: Theme.of(context).primaryColor),
                child: IconButton(
                  icon: Icon(Icons.tune_rounded, color: Colors.white,),
                  iconSize: 26,
                  tooltip: AppLocalizations.of(context).advancedFilters,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FilterChipDisplay(tagsList: tagsList, selectedTags: selectedTags, typesList: typesList, selectedTypes: selectedTypes, selectTag: selectTag, deselectTag: deselectTag, deselectAllTags: deselectAllTags, selectType: selectType, deselectType: deselectType, deselectAllTypes: deselectAllTypes, applyFilters: applyFilters,)),);
                  },
                ),
              ),
            ],
          ),
          if(isDownloading || isDeleting)
            const LinearProgressIndicator(),
          Container(
            width: MediaQuery.of(context).size.width,
            child: !docsUploaded ? Center(child: SizedBox(child: CircularProgressIndicator(), height: 100, width: 100,)) :
            PaginatedDataTable(
              key: _keyPaginatedTable,
              showCheckboxColumn: true,
              header: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Text("${AppLocalizations.of(context).docsof} $nome"),
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      tooltip: AppLocalizations.of(context).uploadDoc,
                      onPressed: () { _showUploadDialog(); },
                      icon: Icon(Icons.add),
                      color: Colors.white,
                    ),
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
              source: (_searchedDocs.isNotEmpty || _controllerSearch.text.isNotEmpty) && (selectedTypes.isNotEmpty || selectedTags.isNotEmpty) ?
              DataSourceDocs(context, _searchedDocs.toSet().intersection(_filteredDocs.toSet()).toList(), delete, download) :
              _searchedDocs.isNotEmpty || _controllerSearch.text.isNotEmpty ?
              DataSourceDocs(context, _searchedDocs, delete, download) :
              selectedTypes.isNotEmpty || selectedTags.isNotEmpty ?
              DataSourceDocs(context, _filteredDocs, delete, download) :
              DataSourceDocs(context, _docs, delete, download),
            ),
          ),
        ],
      ),
    );
  }

  void download(bool start) {
    if(mounted) {
      setState(() {
        isDownloading = start;
      });
    }
  }

  void delete(int idDoc) {
    if(mounted) {
      setState(() {
        if(idDoc == -1) {
          isDeleting = true;
        } else {
          _docs.removeWhere((documento) => idDoc == documento.id);
          _filteredDocs.removeWhere((documento) => idDoc == documento.id);
          isDeleting = false;
        }
      });
    }
  }

  void selectTag(Tag tag) {
    selectedTags.add(tag);
  }

  void deselectTag(Tag tag) {
    selectedTags.remove(tag);
  }

  void deselectAllTags() {
    selectedTags.clear();
  }

  void selectType(String type) {
    selectedTypes.add(type);
  }

  void deselectType(String type) {
    selectedTypes.remove(type);
  }

  void deselectAllTypes() {
    selectedTypes.clear();
  }

  void applyFilters() {
    setState(() {
      List<Documento> byTags = _docs.where((document) {
        for (Tag t in selectedTags) {
          if (document.tags.contains(t)) return true;
        }
        return false;
      }).toList();
      List<Documento> byTypes = _docs.where((document) {
        for (String t in selectedTypes) {
          if (t == document.formato) return true;
        }
        return false;
      }).toList();

      if(byTypes.isEmpty && byTags.isEmpty) {
        _filteredDocs = [];
      }
      else if(byTypes.isEmpty) {
        _filteredDocs = byTags;
      } else if(byTags.isEmpty) {
        _filteredDocs = byTypes;
      } else {
        _filteredDocs = byTags.toSet().intersection(byTypes.toSet()).toList();
      }
      _keyPaginatedTable.currentState.pageTo(0);
    });
  }

  void _showUploadDialog() {
    showDialog(context: context, builder: (context) => const UploadDialog());
  }

  void _search() {
    setState(() {
      _searchedDocs = _docs.where((element) => element.titolo.toLowerCase().contains(_controllerSearch.text.toLowerCase())).toList();
      _keyPaginatedTable.currentState.pageTo(0);
    });
  }
}
