import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/model/objects/Documento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:docman_flutter/UI/customWidgets/ChipTagsInput.dart';
import 'package:docman_flutter/UI/customWidgets/InputField.dart';

import '../../model/objects/Info.dart';
import '../../model/objects/Tag.dart';

class InfoDialog extends StatefulWidget {
  bool mydocs; //indica se è l'info dialog dei miei documenti (true) o di quelli condivisi (false)
  Documento documento;

  InfoDialog({Key key, this.documento, this.mydocs}) : super(key: key);

  @override
  _InfoDialogState createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  TextEditingController _controllerDescrizione = TextEditingController();
  List<String> _initialTags = [];
  ChipTagsInput _chipTagsInput;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controllerDescrizione.text = widget.documento.descrizione;
    if(mounted) {
      setState(() {
        for(Tag t in widget.documento.tags) {
          _initialTags.add(t.nome);
        }
        _chipTagsInput = ChipTagsInput(mydocs: widget.mydocs, initialTags: _initialTags,);
      });
    }
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
      content: SizedBox(
          width: 500,
          height: (widget.mydocs) ? 350 : 250,
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildDescription(),
                buildModifyTags(),

                if(widget.mydocs)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: buildSubmit(),
                  ),

                if(isUpdating)
                  const LinearProgressIndicator()
              ],
            ),
          )
      ),
    );
  }

  Widget buildHeader() => ListTile(
    title: Center(child: Text("Info: ${widget.documento.titolo}", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18), overflow: TextOverflow.ellipsis,)),
    trailing: IconButton(
      icon: Icon(Icons.close),
      onPressed: () { Navigator.pop(context); },
    ),
  );

  Widget buildDescription() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text("${AppLocalizations.of(context).description}:", style: TextStyle(fontWeight: FontWeight.w800,),),
      ),
      InputField(
        enabled: widget.mydocs,
        maxlines: 2,
        maxLength: 250,
        controller: _controllerDescrizione,
      )
    ],
  );

  Widget buildModifyTags() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text("${AppLocalizations.of(context).tags}:", style: TextStyle(fontWeight: FontWeight.w800,),),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20),
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
      onPressed: () { _updateInfo(); },
      elevation: 10.0,
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.update_outlined, color: Colors.white,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(AppLocalizations.of(context).updateInfo, style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    ),
  );

  Future<void> _updateInfo() async {
    if(mounted) {
      setState(() {
        isUpdating = true;
      });
    }
    Info info = Info(descrizione: _controllerDescrizione.text, tags: _chipTagsInput.controllerTags.getTags);
    Model.sharedInstance.modifyDocumentInfo(info, widget.documento.id).then((result){
      Navigator.pushReplacementNamed(context, '/');
      isUpdating = false;
    });
  }
}
