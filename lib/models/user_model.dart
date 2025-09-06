class UserModel {
  final String uid;
  final String nome;
  final String email;
  final String telefone;
  final String cidade;
  final String endereco;
  final String tipoUsuario;

  UserModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cidade,
    required this.endereco,
    required this.tipoUsuario,
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
      'criadoEm': DateTime.now(),
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
    );
  }
}
