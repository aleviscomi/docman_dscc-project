class Utente{
  int id;
  String nome;
  String cognome;
  String email;

  Utente({this.id, this.nome, this.cognome, this.email});

  factory Utente.fromJson(Map<String, dynamic> json) {
    return Utente(
      id: json['id'],
      nome: json['nome'],
      cognome: json['cognome'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'cognome': cognome,
    'email': email,
  };
}