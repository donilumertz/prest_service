import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _profissaoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  String? _tipoUsuario;
  bool _termosAceitos = false;
  String? _erroTermos;
  String? _erroProfissao;
  String? _erroDescricao;
  String? _erroCategorias;

  bool _isSubmitting = false;

  List<String> _categoriasSelecionadas = [];
  List<String> _categorias = [];

  File? _imagemSelecionada;
  String? _imagemBase64;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagemSelecionada = File(picked.path);
        _imagemBase64 = base64Encode(_imagemSelecionada!.readAsBytesSync());
      });
    }
  }

  void _cadastrar() async {
    final valido = _formKey.currentState?.validate() ?? false;

    _erroTermos = null;
    _erroProfissao = null;
    _erroDescricao = null;
    _erroCategorias = null;

    if (_tipoUsuario == 'Prestador') {
      if (_profissaoController.text.trim().isEmpty) {
        _erroProfissao = 'Informe a profissão';
      }
      if (_descricaoController.text.trim().isEmpty) {
        _erroDescricao = 'Descreva seus trabalhos';
      }
      if (_categoriasSelecionadas.isEmpty) {
        _erroCategorias = 'Selecione ao menos uma categoria';
      }
    }

    if (!_termosAceitos) {
      _erroTermos = 'Você deve aceitar os termos de uso';
    }

    setState(() {});

    if (!valido ||
        _erroTermos != null ||
        _erroProfissao != null ||
        _erroDescricao != null ||
        _erroCategorias != null) {
      return;
    }

    setState(() => _isSubmitting = true);

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
        tipoUsuario: _tipoUsuario ?? 'Cliente',
        profissao:
        _tipoUsuario == 'Prestador' ? _profissaoController.text.trim() : null,
        descricao:
        _tipoUsuario == 'Prestador' ? _descricaoController.text.trim() : null,
        categorias:
        _tipoUsuario == 'Prestador' ? _categoriasSelecionadas : [],
        avaliacao: 0.0,
        fotoBase64: _imagemBase64,
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
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  void _carregarCategorias() async {
    final categoriasDoBanco = await _firestoreService.getCategorias();
    setState(() {
      _categorias = categoriasDoBanco..sort((a, b) => a.compareTo(b));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: const Color(0xFF4A4A4A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _selecionarImagem,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imagemSelecionada != null
                      ? FileImage(_imagemSelecionada!)
                      : null,
                  child: _imagemSelecionada == null
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                v == null || !v.contains('@') ? 'Email inválido' : null,
              ),

              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (v) =>
                v == null || v.length < 6 ? 'Senha muito curta' : null,
              ),

              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                v == null || v.isEmpty ? 'Informe o telefone' : null,
              ),

              TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Informe a cidade' : null,
              ),

              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Informe o endereço' : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                items: const [
                  DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
                  DropdownMenuItem(value: 'Prestador', child: Text('Prestador')),
                ],
                onChanged: (value) => setState(() => _tipoUsuario = value),
                hint: const Text('Selecione uma opção'),
                validator: (v) =>
                v == null ? 'Selecione o tipo de usuário' : null,
              ),

              if (_tipoUsuario == 'Prestador') ...[
                const SizedBox(height: 16),

                TextFormField(
                  controller: _profissaoController,
                  decoration: const InputDecoration(labelText: 'Profissão'),
                ),
                if (_erroProfissao != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_erroProfissao!,
                        style: const TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                      labelText: 'Descrição dos trabalhos'),
                  minLines: 3,
                  maxLines: 6,
                ),
                if (_erroDescricao != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_erroDescricao!,
                        style: const TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Categorias',
                      style: Theme.of(context).textTheme.titleMedium),
                ),

                const SizedBox(height: 6),

                Column(
                  children: _categorias.map((categoria) {
                    final selected =
                    _categoriasSelecionadas.contains(categoria);
                    return CheckboxListTile(
                      title: Text(categoria),
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _categoriasSelecionadas.add(categoria);
                          } else {
                            _categoriasSelecionadas.remove(categoria);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_erroCategorias != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_erroCategorias!,
                        style: const TextStyle(color: Colors.red)),
                  ),
              ],

              Row(
                children: [
                  Checkbox(
                    value: _termosAceitos,
                    onChanged: (value) {
                      setState(() {
                        _termosAceitos = value ?? false;
                        if (_termosAceitos) _erroTermos = null;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text('Li e concordo com os termos de uso.'),
                  ),
                ],
              ),

              if (_erroTermos != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_erroTermos!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),

              const SizedBox(height: 16),

              _isSubmitting
                  ? const CircularProgressIndicator()
                  : Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _cadastrar,
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF6161E8)),
                    child: const Text('Cadastrar',
                        style:
                        TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const InitialScreen(),
                          ),
                        ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF4A4A4A)),
                    child: const Text('Voltar',
                        style:
                        TextStyle(color: Colors.white)),
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
