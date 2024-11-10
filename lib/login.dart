import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import pour Firebase Auth
import 'main.dart';  // Pour accéder à la page d'accueil après connexion

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance de FirebaseAuth

  void _login() async {
    // Vérifie si les champs sont vides avant de continuer
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      // Afficher un message d'erreur si les champs sont vides
      print('Veuillez entrer votre adresse e-mail et votre mot de passe')
      ;
      return; // Empêche la tentative de connexion si les champs sont vides
    }

    try {
      // Authentification avec Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );

      // Si la connexion est réussie, affiche un log en console
      print('Connexion réussie: ${userCredential.user?.email}');
      print('UID de l\'utilisateur: ${userCredential.user?.uid}'); // Log du UID de l'utilisateur

      // Redirige vers la page principale après la connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Log en console si la connexion échoue
      if (e.code == 'user-not-found') {
        print('Erreur: Utilisateur non trouvé');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Utilisateur non trouvé')),
        );
      } else if (e.code == 'wrong-password') {
        print('Erreur: Mot de passe incorrect');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Mot de passe incorrect')),
        );
      } else {
        print('Erreur: Connexion échouée!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Connexion échouée!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Vinted Miage'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Champ de texte pour l'adresse e-mail
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Adresse e-mail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Champ de texte pour le mot de passe
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            // Bouton de connexion
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFFD2B48C), // Couleur marron clair pour le bouton
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
