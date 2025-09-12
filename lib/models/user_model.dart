class UserModel {
  final String uid;
  final String nome;
  final String email;
  final String telefone;
  final String cidade;
  final String endereco;
  final String tipoUsuario;
  final String? profissao;
  final String? descricao;
  final List<String>? categorias;
  final double avaliacao;
  final String? fotoBase64; // 🔹 foto convertida para texto

  UserModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cidade,
    required this.endereco,
    required this.tipoUsuario,
    this.profissao,
    this.descricao,
    this.categorias,
    required this.avaliacao,
    this.fotoBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cidade': cidade,
      'endereco': endereco,
      'tipoUsuario': tipoUsuario,
      'profissao': profissao,
      'descricao': descricao,
      'categorias': categorias,
      'avaliacao': avaliacao,
      'fotoBase64': fotoBase64,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      nome: map['nome'],
      email: map['email'],
      telefone: map['telefone'],
      cidade: map['cidade'],
      endereco: map['endereco'],
      tipoUsuario: map['tipoUsuario'],
      profissao: map['profissao'],
      descricao: map['descricao'],
      categorias: List<String>.from(map['categorias'] ?? []),
      avaliacao: (map['avaliacao'] ?? 0).toDouble(),
      fotoBase64: map['fotoBase64'],
    );
  }
}
