class Info {
  String descrizione;
  List<String> tags;

  Info({this.descrizione, this.tags});

  Map<String, dynamic> toJson() => {
    'descrizione': descrizione,
    'tags': tags,
  };
}