import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsVetement extends StatelessWidget {
  final String titre;
  final String taille;
  final double prix;
  final String image;
  final String categorie;
  final String marque;

  const DetailsVetement({
    super.key,
    required this.titre,
    required this.taille,
    required this.prix,
    required this.image,
    required this.categorie,
    required this.marque,
  });

  // Fonction pour ajouter le vêtement au panier
  Future<void> ajouterAuPanier(BuildContext context) async {
    try {
      // Récupérer l'UID de l'utilisateur connecté
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Si l'utilisateur n'est pas connecté, afficher un message ou rediriger
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non connecté')),
        );
        return;
      }

      // Référencer la collection 'paniers' et le document de l'utilisateur
      CollectionReference panier = FirebaseFirestore.instance.collection('paniers');
      DocumentReference userPanier = panier.doc(user.uid);

      // Vérifier si le document du panier existe déjà
      DocumentSnapshot docSnapshot = await userPanier.get();

      // Si le document n'existe pas ou que les données sont nulles, initialise le panier
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        // Si le panier n'existe pas, créer un nouveau document pour l'utilisateur
        await userPanier.set({
          'total': 0.0, // Initialiser le total à 0
        });
      }

      // Récupérer les données actuelles du document après initialisation
      docSnapshot = await userPanier.get(); // Récupérer à nouveau le snapshot

      // Assurez-vous que les données du document sont bien sous forme de Map
      Map<String, dynamic> panierData = docSnapshot.data() as Map<String, dynamic>;

      // Ajouter le vêtement à la sous-collection 'vetements'
      CollectionReference vetements = userPanier.collection('vetements');

      // Ajouter le vêtement au panier
      await vetements.add({
        'titre': titre,
        'taille': taille,
        'prix': prix,
        'image': image,
        'categorie': categorie,
        'marque': marque,
        'quantité': 1, // Quantité initialisée à 1
      });

      // Mettre à jour le total dans le panier
      double total = panierData['total'] ?? 0.0; // Si 'total' est null, le mettre à 0
      total += prix; // Ajouter le prix du vêtement au total
      await userPanier.update({'total': total});

      // Affiche un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajouté au panier')),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'ajout au panier')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affiche l'image du vêtement
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error); // Si l'image échoue à se charger
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.style, color: Colors.brown),
                      title: Text(
                        'Catégorie : $categorie',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.straighten, color: Colors.brown),
                      title: Text(
                        'Taille : $taille',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.label, color: Colors.brown),
                      title: Text(
                        'Marque : $marque',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_money, color: Colors.brown),
                      title: Text(
                        'Prix : $prix €',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Retourner à la liste des vêtements
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF8B4513), // Couleur marron pour le bouton
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Retour'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Ajouter le vêtement au panier
                    await ajouterAuPanier(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF8B4513), // Couleur marron pour le bouton
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Ajouter au panier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
