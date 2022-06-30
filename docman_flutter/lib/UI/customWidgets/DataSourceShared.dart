import 'dart:io';

import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/model/objects/Documento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:intl/intl.dart';

import 'InfoDialog.dart';
import 'SharingCenter.dart';

class DataSourceShared extends DataTableSource {
  Function unshareCallback;
  Function downloadCallback;
  List<Documento> docs;

  DataSourceShared(this.context, this.docs, this.unshareCallback, this.downloadCallback) {
    _rows = <_Row>[
      for(Documento d in docs)
        _Row(
          d,
          d.id,
          Row(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: setIcon(d.formato),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
              child: d.formato == "" ? Text(d.titolo, overflow: TextOverflow.ellipsis,) : Text("${d.titolo}.${d.formato}", overflow: TextOverflow.ellipsis,)
            ),
          ]),
          d.proprietario.email,
        ),
    ];
  }

  final BuildContext context;
  List<_Row> _rows;
  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _rows.length) return null;
    final row = _rows[index];
    return DataRow.byIndex(
      index: index,
      selected: row.selected,
      cells: [
        DataCell(row.nome),
        DataCell(Center(child: Text(row.proprietario))),
        DataCell(
          Center(
            child: PopupMenuButton(
              tooltip: AppLocalizations.of(context).actions,
              icon: const Icon(Icons.more_vert_outlined),
              offset: const Offset(0, 20),
              onSelected: (result) {
                switch(result) {
                  case 0: {
                    _downloadDoc(row.documento);
                    break;
                  }
                  case 1: {
                    _openInfoDialog(row.documento);
                    break;
                  }
                  case 2: {
                    showConfirm(row.id);
                    break;
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.download_outlined, color: Colors.black,),
                        Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text(AppLocalizations.of(context).download),)
                      ],
                    )
                ),
                PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline_rounded, color: Colors.black,),
                        Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text("Info"),)
                      ],
                    )
                ),
                PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_outlined, color: Colors.black,),
                        Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text(AppLocalizations.of(context).unshare),)
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => _rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _downloadDoc(Documento doc) {
    downloadCallback(true);
    String filename = doc.titolo;
    if(doc.formato.isNotEmpty) {
      filename += ".${doc.formato}";
    }
    Model.sharedInstance.downloadDocument(doc.id, filename).then((result) {
      downloadCallback(false);
      if(!result) {
        _showError();
      }
    });
  }

  void showConfirm(int idDoc) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.delete, size: 30,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(AppLocalizations.of(context).confirmUnshare),
                ),
              ],
            ),
            actions: [
              MaterialButton(
                height: 40,
                minWidth: 100,
                onPressed: () {
                  _unshareDoc(idDoc);
                  Navigator.pop(context);
                },
                elevation: 6.0,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text(AppLocalizations.of(context).yes, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
              MaterialButton(
                height: 40,
                minWidth: 100,
                onPressed: () { Navigator.pop(context); },
                elevation: 6.0,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text(AppLocalizations.of(context).no, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          );
        }
    );
  }

  Future<void> _unshareDoc(int id) async {
    Map tokenData = await Model.sharedInstance.getDataFromToken();
    int idUtente = int.parse(tokenData['id']);
    unshareCallback(-1); //attiva l'indicator
    Model.sharedInstance.unshareDocument(id, idUtente).then((result) {
      if(result) {
        unshareCallback(id); //blocca l'indicator
      }
    });
  }

  void _openInfoDialog(Documento documento) {
    showDialog(context: context, builder: (context) => InfoDialog(mydocs: false, documento: documento));
  }

  void _showError() {
    showDialog(
        context: context,
        builder: (context)
        {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 30,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(AppLocalizations.of(context).downloadError),
                ),
              ],
            ),
            actions: [
              MaterialButton(
                height: 40,
                minWidth: 100,
                onPressed: () { Navigator.pop(context); },
                elevation: 6.0,
                color: Theme.of(context).primaryColor,
                child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 16)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ],
          );
        }
    );
  }

  Icon setIcon(String formato) {
    switch(formato) {
      case "pdf": return const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDE0000),);
      case "docx": return const Icon(FontAwesome5.file_word, color: Color(0xFF1868C7),);
      case "doc": return const Icon(FontAwesome5.file_word, color: Color(0xFF1868C7),);
      case "xlsx": return const Icon(FontAwesome5.file_excel, color: Color(0xFF048948),);
      case "xls": return const Icon(FontAwesome5.file_excel, color: Color(0xFF048948),);
      case "pptx": return const Icon(FontAwesome5.file_powerpoint, color: Color(0xFFD0440F),);
      case "ppt": return const Icon(FontAwesome5.file_powerpoint, color: Color(0xFFD0440F),);
      case "txt": return const Icon(FontAwesome5.file_alt, color: Color(0xFF3B3B3B),);
      case "jpeg": return const Icon(FontAwesome5.file_image, color: Color(0xFFFFB162),);
      case "jpg": return const Icon(FontAwesome5.file_image, color: Color(0xFFFFB162),);
      case "png": return const Icon(FontAwesome5.file_image, color: Color(0xFFFFB162),);
      case "gif": return const Icon(FontAwesome5.file_image, color: Color(0xFFFFB162),);
      case "mp4": return const Icon(FontAwesome5.file_video, color: Color(0xFFFF1868),);
      case "mov": return const Icon(FontAwesome5.file_video, color: Color(0xFFFF1868),);
      case "wmv": return const Icon(FontAwesome5.file_video, color: Color(0xFFFF1868),);
      case "avi": return const Icon(FontAwesome5.file_video, color: Color(0xFFFF1868),);
      case "mkv": return const Icon(FontAwesome5.file_video, color: Color(0xFFFF1868),);
      case "mp3": return const Icon(FontAwesome5.file_audio, color: Color(0xFF74B3FF),);
      case "aac": return const Icon(FontAwesome5.file_audio, color: Color(0xFF74B3FF),);
      case "wma": return const Icon(FontAwesome5.file_audio, color: Color(0xFF74B3FF),);
      case "wav": return const Icon(FontAwesome5.file_audio, color: Color(0xFF74B3FF),);
      case "csv": return const Icon(FontAwesome5.file_csv, color: Color(0xFF03FF07),);
      case "html": return const Icon(FontAwesome5.file_code, color: Color(0xFF001746),);
      case "java": return const Icon(FontAwesome5.file_code, color: Color(0xFF001746),);
      case "bat": return const Icon(FontAwesome5.file_code, color: Color(0xFF001746),);
      case "c": return const Icon(FontAwesome5.file_code, color: Color(0xFF001746),);
      case "cpp": return const Icon(FontAwesome5.file_code, color: Color(0xFF001746),);
      case "py": return const Icon(FontAwesome5.file_code, color: Color(0xFF001746),);
      default: return const Icon(FontAwesome5.file, color: Color(0xFFBDB38C),);
    }
  }
}

class _Row {
  final Documento documento;
  final int id;
  final Row nome;
  final String proprietario;

  _Row(this.documento, this.id, this.nome, this.proprietario,);

  bool selected = false;
}