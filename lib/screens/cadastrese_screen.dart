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

  final TextEditingController _profissaoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  String? _tipoUsuario;
  bool _termosAceitos = false;
  bool _isSubmitting = false;

  List<String> _categoriasSelecionadas = [];
  List<String> _categorias = [];

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  void _cadastrar() async {
    final formValid = _formKey.currentState?.validate() ?? false;

    if (_tipoUsuario == 'Prestador') {
      if (_profissaoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe a profissão')));
        return;
      }
      if (_descricaoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe a descrição dos trabalhos')));
        return;
      }
      if (_categoriasSelecionadas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione ao menos uma categoria')));
        return;
      }
    }

    if (!formValid) return;
    if (!_termosAceitos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aceite os termos de uso')));
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
        profissao: _tipoUsuario == 'Prestador' ? _profissaoController.text.trim() : null,
        descricao: _tipoUsuario == 'Prestador' ? _descricaoController.text.trim() : null,
        categorias: _tipoUsuario == 'Prestador' ? _categoriasSelecionadas : [],
        avaliacao: 0.0,
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
    final categoriasDoBanco = await _firestoreService.buscarCategorias();
    setState(() {
      _categorias = categoriasDoBanco..sort((a, b) => a.compareTo(b));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: const Color(0xFF006C67),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@') ? 'Email inválido' : null,
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Senha muito curta' : null,
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Informe o telefone' : null,
              ),
              TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
                validator: (value) => value == null || value.isEmpty ? 'Informe a cidade' : null,
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(labelText: 'Endereço'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o endereço' : null,
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
                validator: (value) => value == null ? 'Selecione o tipo de usuário' : null,
              ),
              if (_tipoUsuario == 'Prestador') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _profissaoController,
                  decoration: const InputDecoration(labelText: 'Profissão'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição dos trabalhos'),
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Categorias', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 6),
                Column(
                  children: _categorias.map((categoria) {
                    final selected = _categoriasSelecionadas.contains(categoria);
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
              ],
              Row(
                children: [
                  Checkbox(
                    value: _termosAceitos,
                    onChanged: (value) => setState(() => _termosAceitos = value ?? false),
                  ),
                  const Expanded(child: Text('Li e concordo com os termos de uso.')),
                ],
              ),
              const SizedBox(height: 16),
              if (_isSubmitting) const CircularProgressIndicator(),
              if (!_isSubmitting)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _cadastrar,
                      child: const Text('Cadastrar'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006C67)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const InitialScreen()),
                      ),
                      child: const Text('Voltar'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF92C9C3)),
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
