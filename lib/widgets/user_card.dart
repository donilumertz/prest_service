import 'package:flutter/material.dart';
import 'package:prest_service/screens/users_detail_screen.dart';
import '../models/user_model.dart';
import 'dart:convert';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  const UserCard({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailScreen(user: user, uidUsuarioAtual: '',)),
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
            user.fotoBase64 != null
                ? CircleAvatar(
              radius: 30,
              backgroundImage: MemoryImage(base64Decode(user.fotoBase64!)),
            )
                : const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.profissao ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < user.avaliacao.round() ? Icons.star : Icons.star_border,
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
