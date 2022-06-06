import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/Model.dart';
import '../../model/objects/Tag.dart';

class FilterChipDisplay extends StatefulWidget {
  List<Tag> tagsList;
  List<Tag> selectedTags;
  List<String> typesList;
  List<String> selectedTypes;
  Function(Tag) selectTag;
  Function(Tag) deselectTag;
  Function() deselectAllTags;
  Function(String) selectType;
  Function(String) deselectType;
  Function() deselectAllTypes;
  Function() applyFilters;

  FilterChipDisplay({Key key, this.tagsList, this.selectedTags, this.typesList, this.selectedTypes, this.selectTag, this.deselectTag, this.deselectAllTags, this.selectType, this.deselectType, this.deselectAllTypes, this.applyFilters});

  @override
  _FilterChipDisplayState createState() => _FilterChipDisplayState();
}

class _FilterChipDisplayState extends State<FilterChipDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white,),
            onPressed: () {
              widget.applyFilters();
              Navigator.pop(context);
            }),
        title: Text(AppLocalizations.of(context).advancedFilters, style: TextStyle(color: Colors.white,),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _titleContainer(AppLocalizations.of(context).chooseTags),
                    Container(
                      decoration: BoxDecoration(color: Color(0xC2384F8A), borderRadius: BorderRadius.all(Radius.circular(15))),
                      margin: EdgeInsets.only(left: 30),
                      child: MaterialButton(
                        child: const Text("Reset", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            widget.deselectAllTags();
                            widget.selectedTags.clear();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    child: Wrap(
                      spacing: 100.0,
                      runSpacing: 20.0,
                      children: <Widget>[
                        for(Tag t in widget.tagsList)
                          FilterChipWidget(item: t, itemName: t.nome, selectedItems: widget.selectedTags, selectItem: widget.selectTag, deselectItem: widget.deselectTag),
                      ],
                    )
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Colors.blueGrey, height: 10.0,),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _titleContainer(AppLocalizations.of(context).chooseTypes),
                    Container(
                      decoration: BoxDecoration(color: Color(0xC2384F8A), borderRadius: BorderRadius.all(Radius.circular(15))),
                      margin: EdgeInsets.only(left: 30),
                      child: MaterialButton(
                        child: const Text("Reset", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            widget.deselectAllTypes();
                            widget.selectedTypes.clear();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Wrap(
                    spacing: 100,
                    runSpacing: 20,
                    children: <Widget>[
                      for(String t in widget.typesList)
                        FilterChipWidget(item: t, itemName: t == "" ? AppLocalizations.of(context).noExtension : t, selectedItems: widget.selectedTypes, selectItem: widget.selectType, deselectItem: widget.deselectType),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleContainer(String myTitle) {
    return Text(
      myTitle,
      style: const TextStyle(
          color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold),
    );
  }
}


class FilterChipWidget<T> extends StatefulWidget {
  final T item;
  final String itemName;
  List<T> selectedItems;
  Function selectItem;
  Function deselectItem;

  FilterChipWidget({Key key,  this.item, this.itemName, this.selectedItems, this.selectItem, this.deselectItem}) : super(key: key);

  @override
  _FilterChipWidgetState<T> createState() => _FilterChipWidgetState<T>();
}

class _FilterChipWidgetState<T> extends State<FilterChipWidget<T>> {
  bool _isSelected = false;
  Color labelColor = Colors.blueGrey;


  @override
  Widget build(BuildContext context) {
    if(widget.selectedItems.contains(widget.item)){
      setState(() {
        _isSelected = true;
        labelColor = Colors.black;
      });
    }
    else {
      setState(() {
        _isSelected = false;
        labelColor = Colors.blueGrey;
      });
    }

    return FilterChip(
      label: Text(widget.itemName),
      labelStyle: TextStyle(color: labelColor, fontSize: 16.0, fontWeight: FontWeight.bold),
      selected: _isSelected,
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),),
      backgroundColor: Color(0xffededed),
      onSelected: (isSelected) {
        setState(() {
          _isSelected = isSelected;
          if(isSelected) {
            labelColor = Colors.black;
            widget.selectItem(widget.item);
          } else {
            labelColor = Colors.blueGrey;
            widget.deselectItem(widget.item);
          }
        });
      },
      selectedColor: Theme.of(context).primaryColor,);
  }
}
