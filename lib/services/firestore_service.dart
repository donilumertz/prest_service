import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> salvarUsuario(UserModel usuario) async {
    await _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
  }

  Future<List<String>> getCategorias() async {
    final snapshot = await _db.collection('categorias').get();
    return snapshot.docs.map((doc) => doc['nome'].toString()).toList();
  }

  Future<List<UserModel>> getProfissionaisPorCategoria(String categoria) async {
    final snapshot =
        await _db
            .collection('usuarios')
            .where('tipoUsuario', isEqualTo: 'Prestador')
            .where('categorias', arrayContains: categoria)
            .get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  Future<void> atualizarAvaliacao(String uid, double novaAvaliacao) async {
    await _db.collection('usuarios').doc(uid).update({
      'avaliacao': novaAvaliacao,
    });
  }

  Future<void> salvarComentario(String uid, String comentario) async {
    await _db.collection('usuarios').doc(uid).collection('comentarios').add({
      'comentario': comentario,
      'data': DateTime.now(),
    });
  }

  Stream<QuerySnapshot> streamComentarios(String uid) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('comentarios')
        .orderBy('data', descending: true)
        .snapshots();
  }

  Future<void> salvarAvaliacaoUsuario({
    required String uidUsuario,
    required String uidProfissional,
    required double nota,
  }) async {
    await _db.collection('avaliacoes').add({
      'uidUsuario': uidUsuario,
      'uidProfissional': uidProfissional,
      'nota': nota,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<double> calcularMediaAvaliacao(String uidProfissional) async {
    final snapshot =
        await _db
            .collection('avaliacoes')
            .where('uidProfissional', isEqualTo: uidProfissional)
            .get();

    if (snapshot.docs.isEmpty) return 0;

    double soma = 0;
    for (var doc in snapshot.docs) {
      soma += (doc['nota'] as num).toDouble();
    }

    return soma / snapshot.docs.length;
  }
}
