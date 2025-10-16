import 'package:flutter/material.dart';
import 'package:prest_service/screens/users_detail_screen.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'dart:typed_data';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  const UserCard({super.key, required this.user, this.onTap});

  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoBytes = _decodeImage(user.fotoBase64);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailScreen(
              user: user,
              uidUsuarioAtual: '',
            ),
          ),
        );
        if (onTap != null) onTap!();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: fotoBytes != null ? MemoryImage(fotoBytes) : null,
              child: fotoBytes == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nome,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.profissao ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (user.descricao != null && user.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.descricao!,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < user.avaliacao.round()
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
