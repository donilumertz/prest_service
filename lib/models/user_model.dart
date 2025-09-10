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
    this.avaliacao = 0.0,
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
      'categorias': categorias ?? [],
      'avaliacao': avaliacao,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      telefone: map['telefone'] as String,
      cidade: map['cidade'] as String,
      endereco: map['endereco'] as String,
      tipoUsuario: map['tipoUsuario'] as String,
      profissao: map['profissao'] as String?,
      descricao: map['descricao'] as String?,
      categorias: map['categorias'] != null ? List<String>.from(map['categorias']) : [],
      avaliacao: (map['avaliacao'] ?? 0).toDouble(),
    );
  }
}
