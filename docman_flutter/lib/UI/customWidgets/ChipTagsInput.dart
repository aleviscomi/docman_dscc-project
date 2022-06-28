import 'package:docman_flutter/model/Model.dart';
import 'package:docman_flutter/model/objects/Tag.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

class ChipTagsInput extends StatefulWidget {
  bool mydocs; //per i miei documenti (true) deve essere abilitato l'input, altrimenti per i condivisi (false) no
  TextfieldTagsController controllerTags;
  List<String> initialTags = [];

  ChipTagsInput({Key key, this.initialTags, this.mydocs}) : super(key: key);

  @override
  _ChipTagsInputState createState() => _ChipTagsInputState();
}

class _ChipTagsInputState extends State<ChipTagsInput> {
  List<Tag> _suggestTags;

  @override
  void initState() {
    super.initState();
    widget.controllerTags = TextfieldTagsController();
    Model.sharedInstance.getTagsByUser().then((result) {
      setState(() {
        _suggestTags = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<Tag>(
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.0)),
                        ),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          height: 50.0 * options.length,
                          width: constraints.biggest.width,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final dynamic option = options.elementAt(index);
                              return TextButton(
                                onPressed: () {
                                  onSelected(option);
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                    child: Text(
                                      '#${option.nome}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    // if (textEditingValue.text == '') {
                    //   return const Iterable<String>.empty();
                    // }
                    return _suggestTags.where((Tag option) {
                      return option.nome.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (Tag selectedTag) {
                    widget.controllerTags.addTag = selectedTag.nome;
                  },
                  fieldViewBuilder: (context, textEditingController, textFocusNode, onFieldSubmitted) {
                    return TextFieldTags(
                      initialTags: widget.initialTags,
                      textEditingController: textEditingController,
                      focusNode: textFocusNode,
                      textfieldTagsController: widget.controllerTags,
                      textSeparators: const [' ', ','],
                      letterCase: LetterCase.normal,
                      validator: (String tag) {
                        if (widget.controllerTags.getTags.contains(tag)) {
                          return 'You already entered that';
                        }
                        return null;
                      },
                      inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
                        return ((context, sc, tags, onTagDelete) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Scrollbar(
                              controller: sc,
                              thumbVisibility: true,
                              child: TextField(
                                enabled: widget.mydocs,
                                controller: tec,
                                focusNode: fn,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  // hintText: _controllerTags.hasTags ? '' : AppLocalizations.of(context).enterTags,
                                  // errorText: error,
                                  prefixIconConstraints: BoxConstraints(
                                    maxWidth: (widget.mydocs) ? MediaQuery.of(context).size.width * 0.2 : constraints.maxWidth,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SingleChildScrollView(
                                      controller: sc,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: tags.map((String tag) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            margin: const EdgeInsets.symmetric(horizontal: 5),
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                InkWell(
                                                  child: Text(
                                                    '#$tag',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  onTap: () {
                                                    //print("$tag selected");
                                                  },
                                                ),
                                                const SizedBox(width: 4.0),
                                                InkWell(
                                                  child: const Icon(
                                                    Icons.cancel,
                                                    size: 14.0,
                                                    color: Color.fromARGB(
                                                        255, 233, 233, 233),
                                                  ),
                                                  onTap: () {
                                                    onTagDelete(tag);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList()
                                      ),
                                    ),
                                  ),
                                ),
                                onChanged: onChanged,
                                onSubmitted: onSubmitted,
                              ),
                            ),
                          );
                        });
                      },
                    );
                  },
                );
              }
          ),
        ),
        // ElevatedButton(
        //   style: ButtonStyle(
        //     backgroundColor: MaterialStateProperty.all<Color>(
        //       Theme.of(context).primaryColor,
        //     ),
        //   ),
        //   onPressed: () {
        //     _controllerTags.clearTags();
        //   },
        //   child: const Text('CLEAR'),
        // ),
      ],
    );
  }
}
