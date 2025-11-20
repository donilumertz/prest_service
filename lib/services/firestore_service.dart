import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> salvarUsuario(UserModel usuario) async {
    await _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
  }

  Future<List<String>> getCategorias() async {
    final snapshot = await _db.collection('categorias').get();
    return snapshot.docs.map((d) => d['nome'].toString()).toList();
  }

  Future<List<UserModel>> getProfissionaisPorCategoria(String categoria) async {
    final snap = await _db
        .collection('usuarios')
        .where('tipoUsuario', isEqualTo: 'Prestador')
        .where('categorias', arrayContains: categoria)
        .get();

    return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  Future<void> salvarComentario(
      String uidProfissional,
      String comentario,
      String uidUsuario,
      ) async {
    await _db
        .collection('usuarios')
        .doc(uidProfissional)
        .collection('comentarios')
        .add({
      'comentario': comentario,
      'uidUsuario': uidUsuario,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamComentarios(String uidProfissional) {
    return _db
        .collection('usuarios')
        .doc(uidProfissional)
        .collection('comentarios')
        .orderBy('data', descending: true)
        .snapshots();
  }

  Future<void> salvarAvaliacaoUsuario({
    required String uidUsuario,
    required String uidProfissional,
    required double nota,
  }) async {
    final col = _db.collection('avaliacoes');

    final existing = await col
        .where('uidUsuario', isEqualTo: uidUsuario)
        .where('uidProfissional', isEqualTo: uidProfissional)
        .get();

    if (existing.docs.isNotEmpty) {
      await col.doc(existing.docs.first.id).update({
        'nota': nota,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return;
    }

    await col.add({
      'uidUsuario': uidUsuario,
      'uidProfissional': uidProfissional,
      'nota': nota,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletarUsuario(String uid) async {
    await _db.collection('usuarios').doc(uid).delete();
  }

  Future<void> atualizarUsuario(Map<String, dynamic> dados, String uid) async {
    await _db.collection('usuarios').doc(uid).update(dados);
  }

  Future<double> calcularMediaAvaliacao(String uidProfissional) async {
    final snap = await _db
        .collection('avaliacoes')
        .where('uidProfissional', isEqualTo: uidProfissional)
        .get();

    if (snap.docs.isEmpty) return 0;

    double soma = 0;
    for (var doc in snap.docs) {
      soma += (doc['nota'] as num).toDouble();
    }

    return soma / snap.docs.length;
  }
}
