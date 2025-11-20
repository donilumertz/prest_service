import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    nome = TextEditingController(text: widget.user.nome);
    telefone = TextEditingController(text: widget.user.telefone ?? "");
    cidade = TextEditingController(text: widget.user.cidade ?? "");
    profissao = TextEditingController(text: widget.user.profissao ?? "");
    descricao = TextEditingController(text: widget.user.descricao ?? "");
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

    await firestore.atualizarUsuario(dadosAtualizados, widget.user.uid);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: const Color(0xFF006C67),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C67)),
                child: const Text("Salvar Alterações"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
