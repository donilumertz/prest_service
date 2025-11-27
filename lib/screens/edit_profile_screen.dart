import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prest_service/models/user_model.dart';
import 'package:prest_service/services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nome;
  late TextEditingController telefone;
  late TextEditingController cidade;
  late TextEditingController profissao;
  late TextEditingController descricao;

  String? novaFotoBase64;

  @override
  void initState() {
    super.initState();
    nome = TextEditingController(text: widget.user.nome);
    telefone = TextEditingController(text: widget.user.telefone ?? "");
    cidade = TextEditingController(text: widget.user.cidade ?? "");
    profissao = TextEditingController(text: widget.user.profissao ?? "");
    descricao = TextEditingController(text: widget.user.descricao ?? "");
  }

  Future<void> selecionarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        novaFotoBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> salvar() async {
    final firestore = FirestoreService();

    final dadosAtualizados = {
      'nome': nome.text,
      'telefone': telefone.text,
      'cidade': cidade.text,
    };

    if (widget.user.tipoUsuario == "Prestador") {
      dadosAtualizados['profissao'] = profissao.text;
      dadosAtualizados['descricao'] = descricao.text;
    }

    if (novaFotoBase64 != null) {
      dadosAtualizados['fotoBase64'] = novaFotoBase64 ?? "";
    }

    await firestore.atualizarUsuario(dadosAtualizados, widget.user.uid);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: const Color(0xFF4A4A4A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage:
                      novaFotoBase64 != null
                          ? MemoryImage(base64Decode(novaFotoBase64!))
                          : widget.user.fotoBase64 != null
                          ? MemoryImage(base64Decode(widget.user.fotoBase64!))
                          : null,
                      child: (widget.user.fotoBase64 == null && novaFotoBase64 == null)
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: selecionarFoto,
                      icon: const Icon(Icons.camera_alt, color: Colors.white,),
                      label: const Text("Alterar Foto", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              TextFormField(controller: nome, decoration: const InputDecoration(labelText: "Nome")),
              TextFormField(controller: telefone, decoration: const InputDecoration(labelText: "Telefone")),
              TextFormField(controller: cidade, decoration: const InputDecoration(labelText: "Cidade")),
              if (widget.user.tipoUsuario == "Prestador") ...[
                TextFormField(controller: profissao, decoration: const InputDecoration(labelText: "Profissão")),
                TextFormField(controller: descricao, decoration: const InputDecoration(labelText: "Descrição")),
              ],
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: salvar,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(
                    0xFF4A4A4A)),
                child: const Text("Salvar Alterações",  style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
