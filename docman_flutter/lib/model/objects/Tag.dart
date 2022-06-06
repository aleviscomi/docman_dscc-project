class Tag{
  int id;
  String nome;

  Tag({this.id, this.nome});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      nome: json['nome']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome
  };

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;
    if(other.runtimeType != runtimeType) return false;

    return other is Tag && other.id == id;
  }
}