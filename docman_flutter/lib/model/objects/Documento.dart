import 'Tag.dart';
import 'Utente.dart';

class Documento{
  int id;
  String titolo;
  String formato;
  DateTime data;
  String descrizione;
  int dimensione;
  String unitaDimensione;
  bool cestino;
  Utente proprietario;
  List<Tag> tags;
  List<Utente> condivisi;

  Documento({this.id, this.titolo, this.formato, this.data, this.descrizione, this.dimensione, this.unitaDimensione, this.cestino, this.proprietario, this.tags, this.condivisi});

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'],
      titolo: json['titolo'],
      formato: json['formato'],
      data: DateTime.parse(json['data']),
      descrizione: json['descrizione'],
      dimensione: json['dimensione'],
      unitaDimensione: json['unita_dimensione'],
      cestino: json['cestino'],
      proprietario: Utente.fromJson(json['proprietario']),
      tags: List<Tag>.from(json['tags'].map((i) => Tag.fromJson(i)).toList()),
      condivisi: List<Utente>.from(json['utenti'].map((i) => Utente.fromJson(i)).toList()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titolo': titolo,
    'formato': formato,
    'data': data,
    'descrizione': descrizione,
    'dimensione': dimensione,
    'unita_dimensione': unitaDimensione,
    'cestino': cestino,
    'proprietario': proprietario,
    'tags': tags,
    'utenti': condivisi,
  };
}