import 'dart:convert';
import 'dart:typed_data';

class UserModel {
  final String uid;
  final String nome;
  final String email;
  final String? telefone;
  final String? cidade;
  final String? endereco;
  final String tipoUsuario;
  final String? profissao;
  final String? descricao;
  final List<String>? categorias;
  final double avaliacao; // média geral do usuário
  final String? fotoBase64;

  UserModel({
    required this.uid,
    required this.nome,
    required this.email,
    this.telefone,
    this.cidade,
    this.endereco,
    required this.tipoUsuario,
    this.profissao,
    this.descricao,
    this.categorias,
    this.avaliacao = 0.0,
    this.fotoBase64,
  });

  Uint8List? get fotoBytes => fotoBase64 != null ? base64Decode(fotoBase64!) : null;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'],
      cidade: map['cidade'],
      endereco: map['endereco'],
      tipoUsuario: map['tipoUsuario'] ?? '',
      profissao: map['profissao'],
      descricao: map['descricao'],
      categorias: map['categorias'] != null ? List<String>.from(map['categorias']) : null,
      avaliacao: (map['avaliacao'] != null) ? (map['avaliacao'] as num).toDouble() : 0.0,
      fotoBase64: map['fotoBase64'],
    );
  }

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
}
