class UserModel {
  final String uid;
  final String nome;
  final String? email;
  final String? cidade;
  final String? endereco;
  final String? profissao;
  final String? descricao;
  final String? fotoBase64;
  final String? telefone;
  final String tipoUsuario;
  final List<String> categorias;
  final double avaliacao;

  UserModel({
    required this.uid,
    required this.nome,
    this.email,
    this.cidade,
    this.endereco,
    this.profissao,
    this.descricao,
    this.fotoBase64,
    this.telefone,
    required this.tipoUsuario,
    required this.categorias,
    this.avaliacao = 0.0,
  });

  UserModel copyWith({
    String? uid,
    String? nome,
    String? email,
    String? cidade,
    String? endereco,
    String? profissao,
    String? descricao,
    String? fotoBase64,
    String? telefone,
    String? tipoUsuario,
    List<String>? categorias,
    double? avaliacao,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cidade: cidade ?? this.cidade,
      endereco: endereco ?? this.endereco,
      profissao: profissao ?? this.profissao,
      descricao: descricao ?? this.descricao,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
      telefone: telefone ?? this.telefone,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      categorias: categorias ?? this.categorias,
      avaliacao: avaliacao ?? this.avaliacao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'cidade': cidade,
      'endereco': endereco,
      'profissao': profissao,
      'descricao': descricao,
      'fotoBase64': fotoBase64,
      'telefone': telefone,
      'tipoUsuario': tipoUsuario,
      'categorias': categorias,
      'avaliacao': avaliacao,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'],
      cidade: map['cidade'],
      endereco: map['endereco'],
      profissao: map['profissao'],
      descricao: map['descricao'],
      fotoBase64: map['fotoBase64'],
      telefone: map['telefone'],
      tipoUsuario: map['tipoUsuario'] ?? 'Cliente',
      categorias: List<String>.from(map['categorias'] ?? []),
      avaliacao: (map['avaliacao'] is int)
          ? (map['avaliacao'] as int).toDouble()
          : (map['avaliacao'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
