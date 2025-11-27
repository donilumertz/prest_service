import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_card.dart';

class ServicesScreen extends StatefulWidget {
  final UserModel currentUser;
  const ServicesScreen({super.key, required this.currentUser});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<String> categorias = [];
  String? selectedCategoria;
  List<UserModel> profissionais = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    carregarCategorias();
  }

  Future<void> carregarCategorias() async {
    final snapshot = await _db.collection('categorias').get();
    categorias = snapshot.docs.map((d) => d['nome'].toString()).toList();
    categorias.sort((a, b) => a.compareTo(b));

    if (categorias.isNotEmpty) {
      selectedCategoria = categorias.first;
      await carregarProfissionais(selectedCategoria!);
    }

    setState(() {});
  }

  Future<double> _mediaAvaliacao(String uidProfissional) async {
    final snap = await _db
        .collection('avaliacoes')
        .where('uidProfissional', isEqualTo: uidProfissional)
        .get();

    if (snap.docs.isEmpty) return 0;

    double soma = 0;
    for (var d in snap.docs) {
      soma += (d['nota'] as num).toDouble();
    }

    return soma / snap.docs.length;
  }

  Future<void> carregarProfissionais(String categoria) async {
    final snapshot = await _db
        .collection('usuarios')
        .where('tipoUsuario', isEqualTo: 'Prestador')
        .where('categorias', arrayContains: categoria)
        .get();

    List<UserModel> lista =
    snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();

    List<UserModel> result = [];

    for (final p in lista) {
      if (p.uid == widget.currentUser.uid) continue;

      final media = await _mediaAvaliacao(p.uid);

      result.add(p.copyWith(avaliacao: media));
    }

    setState(() {
      profissionais = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        backgroundColor: const Color(0xFF4A4A4A),
      ),
      drawer: AppDrawer(currentUser: widget.currentUser),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final cat = categorias[index];
                final selected = selectedCategoria == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      selected ? const Color(0xFF4A4A4A) : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() => selectedCategoria = cat);
                      carregarProfissionais(cat);
                    },
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: profissionais.isEmpty
                ? const Center(child: Text('Nenhum profissional encontrado'))
                : ListView.builder(
              itemCount: profissionais.length,
              itemBuilder: (context, index) {
                return UserCard(
                  user: profissionais[index],
                  uidUsuarioAtual: widget.currentUser.uid,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
