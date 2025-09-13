import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../widgets/user_card.dart';
import '../widgets/app_drawer.dart';

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

  @override
  void initState() {
    super.initState();
    carregarCategorias();
  }

  Future<void> carregarCategorias() async {
    categorias = await FirestoreService().getCategorias();
    categorias.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    if (categorias.isNotEmpty) {
      selectedCategoria = categorias.first;
      await carregarProfissionais(selectedCategoria!);
    }

    setState(() {});
  }

  Future<void> carregarProfissionais(String categoria) async {
    profissionais = await FirestoreService().getProfissionaisPorCategoria(categoria);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
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
                final isSelected = selectedCategoria == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() => selectedCategoria = cat);
                      carregarProfissionais(cat);
                    },
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                  onTap: () {
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
