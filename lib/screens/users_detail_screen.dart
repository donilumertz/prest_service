import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;
  final String uidUsuarioAtual;

  const UserDetailScreen({
    super.key,
    required this.user,
    required this.uidUsuarioAtual,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _comentarioController = TextEditingController();
  double _avaliacaoLocal = 0;
  double _mediaAvaliacao = 0;

  @override
  void initState() {
    super.initState();
    _buscarAvaliacao();
    _buscarMedia();
  }

  Future<void> _buscarMedia() async {
    final response = await _firestoreService.calcularMediaAvaliacao(widget.user.uid);
    setState(() {
      _mediaAvaliacao = response.toDouble();
    });
  }

  void _buscarAvaliacao() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('avaliacoes')
        .where('uidUsuario', isEqualTo: widget.uidUsuarioAtual)
        .where('uidProfissional', isEqualTo: widget.user.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _avaliacaoLocal = (snapshot.docs.first.data()['nota'] as num).toDouble();
      });
    }

    _buscarMedia();
  }

  void _atualizarAvaliacao(double novaAvaliacao) {
    setState(() {
      _avaliacaoLocal = novaAvaliacao;
    });

    _firestoreService.salvarAvaliacaoUsuario(
      uidUsuario: widget.uidUsuarioAtual,
      uidProfissional: widget.user.uid,
      nota: novaAvaliacao,
    );

    _buscarMedia();
  }

  void _salvarComentario() {
    final comentario = _comentarioController.text.trim();
    if (comentario.isEmpty) return;

    _firestoreService.salvarComentario(
      widget.user.uid,
      comentario,
      widget.uidUsuarioAtual,
    );

    _comentarioController.clear();
  }

  Widget _buildStars(double rating, {bool editable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int star = index + 1;
        return IconButton(
          iconSize: 28,
          padding: EdgeInsets.zero,
          onPressed: editable ? () => _atualizarAvaliacao(star.toDouble()) : null,
          icon: Icon(
            star <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }

  Widget _buildCommentTile({
    required String nome,
    String? fotoBase64,
    required String comentario,
    DateTime? dataFormatada,
  }) {
    final dateText = dataFormatada != null
        ? "${dataFormatada.day}/${dataFormatada.month}/${dataFormatada.year}"
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: fotoBase64 != null
                ? MemoryImage(base64Decode(fotoBase64))
                : const AssetImage('assets/user_placeholder.png') as ImageProvider,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFF004D4A)),
                    ),
                    const Spacer(),
                    Text(
                      dateText,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comentario,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006C67),
        title: Text(widget.user.nome),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.user.fotoBase64 != null)
              CircleAvatar(
                radius: 55,
                backgroundImage: MemoryImage(base64Decode(widget.user.fotoBase64!)),
              ),
            const SizedBox(height: 8),
            _buildStars(_mediaAvaliacao, editable: false),
            const SizedBox(height: 8),
            Text(widget.user.nome,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D4A))),
            Text(widget.user.cidade ?? '', style: const TextStyle(color: Colors.black87)),
            Text(widget.user.profissao ?? '', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.user.descricao ?? '',
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006C67),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Text("Contratar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7DB9B6),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: () {},
                  child: const Text("Mensagem"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    "Deixe Sua Avaliação...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF004D4A)),
                  ),
                  _buildStars(_avaliacaoLocal, editable: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _comentarioController,
                    decoration: InputDecoration(
                      hintText: "Digite aqui...",
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF006C67)),
                        onPressed: _salvarComentario,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.streamComentarios(widget.user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Nenhum comentário ainda.'),
                  );
                }

                final comentarios = snapshot.data!.docs;

                return Column(
                  children: comentarios.map((c) {
                    final data = (c.data() as Map<String, dynamic>?) ?? {};
                    final comentarioText = (data['comentario'] as String?) ?? '';
                    final uidComentador = (data['uidUsuario'] as String?);
                    final timestamp = data['data'] as Timestamp?;
                    final dataFormatada = timestamp?.toDate();

                    if (uidComentador == null || uidComentador.isEmpty) {
                      return _buildCommentTile(
                        nome: 'Usuário',
                        fotoBase64: null,
                        comentario: comentarioText,
                        dataFormatada: dataFormatada,
                      );
                    }

                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance.collection('usuarios').doc(uidComentador).get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }

                        if (!userSnapshot.hasData || userSnapshot.data == null || !userSnapshot.data!.exists) {
                          return _buildCommentTile(
                            nome: 'Usuário',
                            fotoBase64: null,
                            comentario: comentarioText,
                            dataFormatada: dataFormatada,
                          );
                        }

                        final userMap = userSnapshot.data!.data() ?? {};
                        final nome = (userMap['nome'] as String?) ?? 'Usuário';
                        final foto = (userMap['fotoBase64'] as String?);

                        return _buildCommentTile(
                          nome: nome,
                          fotoBase64: foto,
                          comentario: comentarioText,
                          dataFormatada: dataFormatada,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
