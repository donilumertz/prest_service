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
    final snapshot = await _db
        .collection('usuarios')
        .where('tipoUsuario', isEqualTo: 'Prestador')
        .where('categorias', arrayContains: categoria)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  Future<void> atualizarAvaliacao(String uid, double novaAvaliacao) async {
    await _db.collection('usuarios').doc(uid).update({'avaliacao': novaAvaliacao});
  }
}
