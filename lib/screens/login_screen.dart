import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'initial_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  String? _erroEmail;
  String? _erroSenha;

  bool _loading = false;

  void _login() async {
    setState(() {
      _erroEmail = null;
      _erroSenha = null;
    });

    if (emailController.text.trim().isEmpty) {
      _erroEmail = "Informe o email";
    } else if (!emailController.text.contains("@")) {
      _erroEmail = "Email inválido";
    }

    if (passwordController.text.trim().isEmpty) {
      _erroSenha = "Informe a senha";
    }

    setState(() {});

    if (_erroEmail != null || _erroSenha != null) {
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(credential.user!.uid)
          .get();

      final currentUser = UserModel.fromMap(doc.data()!);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(currentUser: currentUser),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: ${e.toString()}")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.topLeft,
              child: Text(
                "PS",
                style: GoogleFonts.pacifico(
                  color: const Color(0xFF4A4A4A),
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF4A4A4A),
                child: Text(
                  "PS",
                  style: GoogleFonts.pacifico(fontSize: 36, color: Colors.white),
                ),
              ),
            ),
            Text(
              "PrestService",
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF4A4A4A)),
            ),
            const SizedBox(height: 4),
            Text(
              "Faça seu login",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // EMAIL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  if (_erroEmail != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _erroEmail!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),

            // SENHA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  if (_erroSenha != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _erroSenha!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BOTÃO LOGIN
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: 180,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4A4A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: _login,
                child: const Text(
                  "Entrar",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÃO VOLTAR
            SizedBox(
              width: 180,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4A4A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const InitialScreen()),
                  );
                },
                child: const Text("Voltar", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 40),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/400x150.png?text=Banner"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
