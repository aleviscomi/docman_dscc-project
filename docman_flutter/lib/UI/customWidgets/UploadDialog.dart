import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:docman_flutter/UI/customWidgets/ChipTagsInput.dart';
import 'package:docman_flutter/UI/customWidgets/InputField.dart';
import 'package:docman_flutter/model/Model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';

class UploadDialog extends StatefulWidget {

  const UploadDialog({Key key}) : super(key: key);

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  TextEditingController _controllerTitolo = TextEditingController();
  TextEditingController _controllerDescrizione = TextEditingController();
  final ChipTagsInput _chipTagsInput = ChipTagsInput(mydocs: true,);

  String _filenameUploaded = "";
  PlatformFile _fileUploaded;
  bool _enabledUpload = false;
  bool isUploading = false;

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
      content: SizedBox(
        width: 500,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildSelectFile(),
              buildTitle(),
              buildDescription(),
              buildAddTags(),
              buildSubmit(),
              if(isUploading)
                const LinearProgressIndicator()
            ],
          ),
        )
      ),
    );
  }

  Widget buildHeader() => ListTile(
    title: Center(child: Text(AppLocalizations.of(context).uploadDoc, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18), overflow: TextOverflow.ellipsis,)),
    trailing: IconButton(
      icon: Icon(Icons.close),
      onPressed: () { Navigator.pop(context); },
    ),
  );

  Widget buildSelectFile() => Column(
    children: [
      MaterialButton(
        height: 40,
        minWidth: 100,
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles();
          if(result == null) return;

          _fileUploaded = result.files.first;
          setState(() {
            _filenameUploaded = _fileUploaded.name;
            int dotIndex = _fileUploaded.name.lastIndexOf(".");
            if(dotIndex == -1) {
              dotIndex = _fileUploaded.name.length;
            }
            _controllerTitolo.text = _fileUploaded.name.substring(0, dotIndex);
            _enabledUpload = true;
          });
        },
        elevation: 10.0,
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_file_rounded, color: Colors.white,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(AppLocalizations.of(context).selectFile, style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: RichText(
                text: const TextSpan(
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    children:  [
                      TextSpan(text: "* ", style: TextStyle(color: Colors.red)),
                      TextSpan(text: "File:")
                    ]
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: AutoSizeText(_filenameUploaded, style: TextStyle(color: Colors.blueGrey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    ],
  );

  Widget buildTitle() => Row(
    children: [
      Expanded(
          flex: 1,
          child: RichText(
            text: TextSpan(
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                children:  [
                  const TextSpan(text: "* ", style: TextStyle(color: Colors.red)),
                  TextSpan(text: "${AppLocalizations.of(context).title}:")
                ]
            ),
          ),
      ),
      Expanded(
        flex: 4,
        child: InputField(
          onChanged: (value) {
            setState(() {
              if(_fileUploaded != null && value != "") {
                _enabledUpload = true;
              }
              else {
                _enabledUpload = false;
              }
            });
          },
          controller: _controllerTitolo,
        ),
      )
    ],
  );

  Widget buildDescription() => Row(
    children: [
      Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text("${AppLocalizations.of(context).description}:", style: TextStyle(fontWeight: FontWeight.w800,)),
          )
      ),
      Expanded(
        flex: 4,
        child: InputField(
          maxlines: 2,
          maxLength: 250,
          controller: _controllerDescrizione,
        ),
      )
    ],
  );

  Widget buildAddTags() => Row(
    children: [
      Expanded(
          flex: 1,
          child: Text("${AppLocalizations.of(context).tags}:", style: TextStyle(fontWeight: FontWeight.w800,))
      ),
      Expanded(
        flex: 4,
        child: _chipTagsInput,
      )
    ],
  );

  Widget buildSubmit() => Padding(
    padding: const EdgeInsets.fromLTRB(0, 30, 0, 8),
    child: MaterialButton(
      disabledColor: Colors.blueGrey,
      height: 40,
      minWidth: 500,
      onPressed: _enabledUpload ? () { _uploadDoc(); } : null,
      elevation: 10.0,
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, color: Colors.white,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(AppLocalizations.of(context).uploadDoc, style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    ),
  );

  Future<void> _uploadDoc() async {
    setState(() {
      isUploading = true;
    });
    Response result = await Model.sharedInstance.uploadDocument(_controllerTitolo.text, _controllerDescrizione.text, _fileUploaded);
    if (result.statusCode == 200) {
      List<String> tags = _chipTagsInput.controllerTags.getTags;
      int idDoc = json.decode(result.body)["id"];
      Model.sharedInstance.addTagsDocument(tags, idDoc).then((value) {
        if(value) {
          Navigator.pushReplacementNamed(context, '/');
        }
        else {
          Navigator.pop(context);
          _showError();
        }
      });
    } else {
      Navigator.pop(context);
      _showError();
    }
    isUploading=false;
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
                child: Text(AppLocalizations.of(context).uploadError),
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
}
