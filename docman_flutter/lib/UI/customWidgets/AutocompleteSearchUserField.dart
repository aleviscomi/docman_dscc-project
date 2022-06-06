import 'package:docman_flutter/model/Model.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/objects/Documento.dart';
import '../../model/objects/Utente.dart';
import 'SharingCenter.dart';

class AutocompleteShareUserField extends StatefulWidget {
  Documento documento;

  AutocompleteShareUserField(this.documento, {Key key}) : super(key: key);

  @override
  State<AutocompleteShareUserField> createState() => _AutocompleteShareUserFieldState();
}

class _AutocompleteShareUserFieldState extends State<AutocompleteShareUserField> {
  List<Utente> usersList = [];
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    Model.sharedInstance.getSharedUsers(widget.documento.id).then((result) {
      setState(() {
        usersList = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return Autocomplete<Utente>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return usersList.where((Utente option) {
                return option.email.toLowerCase().contains(textEditingValue.text.toLowerCase()) || "${option.nome.toLowerCase()} ${option.cognome.toLowerCase()}".contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (Utente utente) {
              _controller.text = "";
              Model.sharedInstance.shareDocument(widget.documento.id, utente.id).then((result) {
                if(result) {
                  Navigator.pop(context);
                  showDialog(context: context, builder: (context) => SharingCenter(widget.documento));
                }
              });
            },
            optionsViewBuilder: (context, Function(Utente) onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.0)),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    height: 65.0 * options.length,
                    width: constraints.biggest.width,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);

                        return ListTile(
                          // title: Text(option.toString()),
                          title: SubstringHighlight(
                            text: "${option.nome} ${option.cognome}",
                            term: _controller.text,
                            textStyleHighlight: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: SubstringHighlight(
                            text: option.email,
                            term: _controller.text,
                            textStyle: TextStyle(color: Colors.black54),
                          ),
                          trailing: Icon(Icons.person_add_alt, color: Colors.blueGrey,),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                      itemCount: options.length,
                    ),
                  ),
                ),
              );
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              _controller = controller;

              return TextField(
                controller: controller,
                focusNode: focusNode,
                onEditingComplete: onEditingComplete,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  labelText: AppLocalizations.of(context).shareWith,
                ),
              );
            },
          );
        }
    );
  }
}