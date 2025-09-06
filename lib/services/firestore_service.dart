import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prest_service/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> salvarUsuario(UserModel usuario) async {
    await _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
  }
}
