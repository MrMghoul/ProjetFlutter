import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Panier extends StatelessWidget {
  const Panier({super.key});

  Future<void> supprimerVetementPanier(String vetementId, BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
      return;
    }

    try {
      DocumentReference userPanier = FirebaseFirestore.instance.collection('paniers').doc(user.uid);
      await userPanier.collection('vetements').doc(vetementId).delete();

      DocumentSnapshot docSnapshot = await userPanier.get();
      Map<String, dynamic> panierData = docSnapshot.data() as Map<String, dynamic>;
      double total = panierData['total'] ?? 0.0;

      CollectionReference vetements = userPanier.collection('vetements');
      QuerySnapshot vetementsSnapshot = await vetements.get();
      double nouveauTotal = vetementsSnapshot.docs.fold(0, (previousValue, element) {
        Map<String, dynamic> vetementData = element.data() as Map<String, dynamic>;
        return previousValue + (vetementData['prix'] ?? 0.0);
      });

      await userPanier.update({'total': nouveauTotal});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vêtement retiré du panier')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression du vêtement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Utilisateur non connecté'));
    }

    CollectionReference panier = FirebaseFirestore.instance.collection('paniers').doc(user.uid).collection('vetements');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre Panier'),
        backgroundColor: Colors.brown[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: panier.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement du panier'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Votre panier est vide'));
          }

          List<DocumentSnapshot> vetements = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: vetements.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> vetementData = vetements[index].data() as Map<String, dynamic>;
                    String vetementId = vetements[index].id;
                    return Card(
                      elevation: 5.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            vetementData['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          vetementData['titre'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Taille: ${vetementData['taille']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Prix: ${vetementData['prix']} €',
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            supprimerVetementPanier(vetementId, context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('paniers').doc(user.uid).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> totalSnapshot) {
                  if (totalSnapshot.hasError || !totalSnapshot.hasData || !totalSnapshot.data!.exists) {
                    return const Text('Total: 0.0 €');
                  }

                  Map<String, dynamic> panierData = totalSnapshot.data!.data() as Map<String, dynamic>;
                  double total = panierData['total'] ?? 0.0;

                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$total €',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Action pour valider le panier
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Valider le panier', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
