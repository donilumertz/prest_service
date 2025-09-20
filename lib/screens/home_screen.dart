import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_card.dart';

class HomeScreen extends StatefulWidget {
  final UserModel currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<UserModel> prestadores = [];

  @override
  void initState() {
    super.initState();
    carregarPrestadoresComMedia();
  }

  Future<void> carregarPrestadoresComMedia() async {
    final snapshot = await _db
        .collection('usuarios')
        .where('tipoUsuario', isEqualTo: 'Prestador')
        .get();

    List<UserModel> lista = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    for (int i = 0; i < lista.length; i++) {
      final avaliacoesSnapshot = await _db
          .collection('avaliacoes')
          .where('uidProfissional', isEqualTo: lista[i].uid)
          .get();

      if (avaliacoesSnapshot.docs.isNotEmpty) {
        double soma = 0;
        for (var doc in avaliacoesSnapshot.docs) {
          soma += (doc['nota'] as num).toDouble();
        }
        double media = soma / avaliacoesSnapshot.docs.length;
        lista[i] = UserModel(
          uid: lista[i].uid,
          nome: lista[i].nome,
          email: lista[i].email,
          telefone: lista[i].telefone,
          cidade: lista[i].cidade,
          endereco: lista[i].endereco,
          tipoUsuario: lista[i].tipoUsuario,
          profissao: lista[i].profissao,
          descricao: lista[i].descricao,
          categorias: lista[i].categorias,
          fotoBase64: lista[i].fotoBase64,
          avaliacao: media,
        );
      }
    }

    setState(() {
      prestadores = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text('Profissionais'), backgroundColor: const Color(0xFF006C67)),
      drawer: AppDrawer(currentUser: widget.currentUser),
      body: prestadores.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prestadores.length,
        itemBuilder: (context, index) => UserCard(user: prestadores[index]),
      ),
    );
  }
}
