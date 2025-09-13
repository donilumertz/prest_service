import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const UserCard({super.key, required this.user, this.onTap});

  Color _corAleatoria(String seed) {
    final rand = Random(seed.hashCode);
    return Color.fromARGB(
      255,
      rand.nextInt(156) + 100,
      rand.nextInt(156) + 100,
      rand.nextInt(156) + 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _corAleatoria(user.nome);

    return Card(
      color: const Color(0xFF92C9C3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: user.fotoBase64 != null && user.fotoBase64!.isNotEmpty
            ? CircleAvatar(
          radius: 28,
          backgroundImage: MemoryImage(base64Decode(user.fotoBase64!)),
        )
            : CircleAvatar(
          radius: 28,
          backgroundColor: avatarColor,
          child: Text(
            user.nome.isNotEmpty ? user.nome[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        title: Text(
          user.nome,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.profissao != null) Text(user.profissao!, style: const TextStyle(color: Colors.black87)),
            if (user.descricao != null) Text(user.descricao!, style: const TextStyle(color: Colors.black54)),
            Text('Cidade: ${user.cidade}', style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 4),
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < user.avaliacao.round() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }
}
