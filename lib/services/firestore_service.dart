import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> salvarUsuario(UserModel usuario) async {
    await _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
  }

  Future<List<String>> buscarCategorias() async {
    final snapshot = await _db.collection('categorias').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final nome = data['nome'];
      if (nome != null) {
        return nome.toString();
      } else {
        return '';
      }
    }).where((s) => s.isNotEmpty).toList();
  }

  Future<void> atualizarAvaliacao(String uid, double novaAvaliacao) async {
    await _db.collection('usuarios').doc(uid).update({'avaliacao': novaAvaliacao});
  }
}
