import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/model/objects/Documento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:intl/intl.dart';

import 'SharingCenter.dart';

class DataSourceDocs extends DataTableSource {
  Function deleteCallback;
  List<Documento> docs;

  DataSourceDocs(this.context, this.docs, this.deleteCallback) {
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
          DateFormat('dd-MM-yyyy  HH:mm').format(d.data),
          "${d.dimensione.toString()} ${d.unitaDimensione}"
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
        DataCell(Center(child: Text(row.data))),
        DataCell(Center(child: Text(row.dimensione))),
        DataCell(
          Center(
            child: PopupMenuButton(
              tooltip: AppLocalizations.of(context).actions,
              icon: const Icon(Icons.more_vert_outlined),
              offset: const Offset(0, 20),
              onSelected: (result) {
                switch(result) {
                  case 0: print(AppLocalizations.of(context).download); break;
                  case 1: print("Info"); break;
                  case 2: {
                    _openSharingCenter(row.documento);
                    break;
                  }
                  case 3: {
                    _deleteDoc(row.id);
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
                        const Icon(Icons.person_add_alt, color: Colors.black,),
                        Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text(AppLocalizations.of(context).share),)
                      ],
                    )
                ),
                PopupMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_outlined, color: Colors.black,),
                        Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0), child: Text(AppLocalizations.of(context).delete),)
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

  void _deleteDoc(int id) {
    Model.sharedInstance.deleteDocument(id).then((result) {
      if(result) {
        deleteCallback(id);
      }
    });
  }
  void _openSharingCenter(Documento documento) {
    showDialog(context: context, builder: (context) => SharingCenter(documento));
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
  final String data;
  final String dimensione;

  _Row(this.documento, this.id, this.nome, this.data, this.dimensione,);

  bool selected = false;
}