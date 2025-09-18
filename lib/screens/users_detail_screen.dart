import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _comentarioController = TextEditingController();
  double _avaliacaoLocal = 0;

  @override
  void initState() {
    super.initState();
    _avaliacaoLocal = widget.user.avaliacao;
  }

  void _salvarComentario() {
    String comentario = _comentarioController.text.trim();
    if (comentario.isEmpty) return;
    _firestoreService.salvarComentario(widget.user.uid, comentario);
    _comentarioController.clear();
  }

  void _atualizarAvaliacao(double novaAvaliacao) {
    setState(() {
      _avaliacaoLocal = novaAvaliacao;
    });
    _firestoreService.atualizarAvaliacao(widget.user.uid, novaAvaliacao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.nome),
        backgroundColor: const Color(0xFF006C67),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.user.fotoBase64 != null)
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: MemoryImage(base64Decode(widget.user.fotoBase64!)),
                ),
              ),
            const SizedBox(height: 16),
            Text(widget.user.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.user.profissao ?? '', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Avaliação: ', style: TextStyle(fontSize: 18)),
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                      i <= _avaliacaoLocal ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => _atualizarAvaliacao(i.toDouble()),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Comentários', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder(
              stream: _firestoreService.streamComentarios(widget.user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('Carregando comentários...');
                final comentarios = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    final c = comentarios[index];
                    return ListTile(
                      title: Text(c['comentario']),
                      subtitle: Text(c['data'].toDate().toString()),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Adicionar comentário',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _salvarComentario,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C67)),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
