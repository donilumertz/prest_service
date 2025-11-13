import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../screens/users_detail_screen.dart';

class UserCard extends StatefulWidget {
  final UserModel user;
  final String uidUsuarioAtual;

  const UserCard({
    super.key,
    required this.user,
    required this.uidUsuarioAtual,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  final FirestoreService _firestore = FirestoreService();
  double media = 0.0;

  @override
  void initState() {
    super.initState();
    _buscarMedia();
  }

  void _buscarMedia() async {
    final m = await _firestore.calcularMediaAvaliacao(widget.user.uid);
    setState(() {
      media = m;
    });
  }

  Uint8List? _decode(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoBytes = _decode(widget.user.fotoBase64);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailScreen(
              user: widget.user,
              uidUsuarioAtual: widget.uidUsuarioAtual,
            ),
          ),
        ).then((_) => _buscarMedia());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: fotoBytes != null ? MemoryImage(fotoBytes) : null,
              child: fotoBytes == null ? const Icon(Icons.person, size: 30) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.user.profissao != null)
                    Text(
                      widget.user.profissao!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < media.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
