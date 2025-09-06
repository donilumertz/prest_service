import 'package:flutter/material.dart';
import 'package:prest_service/models/user_model.dart';
import 'package:prest_service/screens/initial_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  String? _tipoUsuario;
  bool _termosAceitos = false;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  void _cadastrar() async {
    if (_formKey.currentState!.validate() && _termosAceitos) {
      try {
        final cred = await _authService.registrar(
          _emailController.text.trim(),
          _senhaController.text.trim(),
        );

        final usuario = UserModel(
          uid: cred.user!.uid,
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          telefone: _telefoneController.text.trim(),
          cidade: _cidadeController.text.trim(),
          endereco: _enderecoController.text.trim(),
          tipoUsuario: _tipoUsuario!,
        );

        await _firestoreService.salvarUsuario(usuario);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InitialScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.contains('@') ? null : 'Email inválido',
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Senha muito curta' : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Informe o telefone' : null,
              ),
              TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
                validator: (value) => value!.isEmpty ? 'Informe a cidade' : null,
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
                validator: (value) => value!.isEmpty ? 'Informe o endereço' : null,
              ),
              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                items: const [
                  DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
                  DropdownMenuItem(value: 'Prestador', child: Text('Prestador')),
                ],
                onChanged: (value) => setState(() => _tipoUsuario = value),
                hint: const Text('Selecione uma opção'),
                validator: (value) => value == null ? 'Selecione o tipo de usuário' : null,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _termosAceitos,
                    onChanged: (value) => setState(() => _termosAceitos = value!),
                  ),
                  const Expanded(child: Text('Li e concordo com os termos de uso.')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _cadastrar,
                    child: const Text('Cadastrar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const InitialScreen()),
                    ),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
