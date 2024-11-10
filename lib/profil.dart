import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:projet_flutter/ajout_vetement.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String? _login;
  String? _password;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Chargement des données de l'utilisateur
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      _login = user.email;
      _passwordController.text = '*******'; // Placeholder pour mot de passe offusqué

      // Récupération des données Firestore
      DocumentSnapshot userDoc = await _firestore.collection('utilisateur').doc(_userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _birthdayController.text = userData['date_anniversaire'] ?? '';
          _addressController.text = userData['adresse'] ?? '';
          _postalCodeController.text = userData['code_postal'] ?? '';
          _cityController.text = userData['ville'] ?? '';
        });
      }
    }
  }

  // Sauvegarde des données utilisateur
  Future<void> _saveUserData() async {
    if (_userId != null) {
      await _firestore.collection('utilisateur').doc(_userId).update({
        'date_anniversaire': _birthdayController.text,
        'adresse': _addressController.text,
        'code_postal': _postalCodeController.text,
        'ville': _cityController.text,
      });

      // Mettre à jour le mot de passe si nécessaire
      if (_passwordController.text != '*******') {
        await _updatePassword(_passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour')),
      );
    }
  }

  // Mise à jour du mot de passe
  Future<void> _updatePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe mis à jour')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour du mot de passe')),
        );
      }
    }
  }

  // Déconnexion
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    print('Utilisateur déconnecté');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Profil Utilisateur'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Se déconnecter',
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Login en lecture seule
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.brown),
                title: Text(
                  _login ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Login'),
              ),
            ),
            const SizedBox(height: 10),

            // Mot de passe en mode offusqué
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.brown),
                title: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Anniversaire
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.cake, color: Colors.brown),
                title: TextField(
                  controller: _birthdayController,
                  decoration: const InputDecoration(labelText: 'Anniversaire'),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Adresse
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.home, color: Colors.brown),
                title: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Code postal avec clavier numérique
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.brown),
                title: TextField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(labelText: 'Code postal'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // N'accepte que les chiffres
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Ville
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_city, color: Colors.brown),
                title: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Ville'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton pour sauvegarder les changements
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF8B4513), // Couleur marron pour le bouton
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Valider'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>  AjoutVetement()),
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF8B4513), // Couleur marron pour le bouton
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un vêtement'),
      ),
    );
  }
}