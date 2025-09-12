import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prest_service/screens/services_screen.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/initial_screen.dart';
import 'screens/perfil_screen.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<UserModel?> getCurrentUserModel(User user) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as UserModel?;

    switch (settings.name) {
      case '/home':
        if (args != null) return MaterialPageRoute(builder: (_) => HomeScreen(currentUser: args));
        break;
      case '/perfil':
        if (args != null) return MaterialPageRoute(builder: (_) => PerfilScreen(currentUser: args));
        break;
      case '/servicos':
        if (args != null) return MaterialPageRoute(builder: (_) => ServicesScreen(currentUser: args));
        break;
    }
    return MaterialPageRoute(builder: (_) => const InitialScreen());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData) {
            return FutureBuilder<UserModel?>(
              future: getCurrentUserModel(snapshot.data!),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                final currentUser = userSnapshot.data!;
                return HomeScreen(currentUser: currentUser);
              },
            );
          } else {
            return const InitialScreen();
          }
        },
      ),
    );
  }
}
