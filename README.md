# Application de Gestion de Vêtements

## Description

Cette application dans le cadre d'un projet universitaire aà pour but de reproduire une version de "Vinted réduite". Les utilisateurs peuvent ajouter, modifier et supprimer des vêtements, ainsi que consulter les détails de chaque vêtement. L'application inclut également une fonctionnalité de prédiction de catégorie basée sur une image téléchargée.

## Fonctionnalités

- **Authentification** : Les utilisateurs peuvent se connecter et se déconnecter.
- **Ajout de Vêtements** : Les utilisateurs peuvent ajouter de nouveaux vêtements en fournissant des informations telles que le titre, la taille, la marque, le prix et une image.
- **Prédiction de Catégorie** : L'application utilise une API Flask pour prédire la catégorie(999 catégories) d'un vêtement basé sur une image téléchargée.
- **Consultation des Détails** : Les utilisateurs peuvent consulter les détails de chaque vêtement.
- **Gestion du Panier** : Les utilisateurs peuvent ajouter des vêtements à leur panier, consulter le total et supprimer des articles du panier.
- **Profil Utilisateur** : Les utilisateurs peuvent consulter et mettre à jour leurs informations de profil.

## Outils

- **Backend** : Un serveur Flask pour la prédiction de catégorie.
- **Firebase** : Utilisé pour l'authentification et la base de données Firestore.
- **Flutter** : Framework utilisé pour développer l'application mobile.

## Installation

### Backend

L'API Flask se trouve en local  dans le projet APIProjetFlutter sur mon compte github il sufit de run le fichier app.py.
(https://github.com/MrMghoul/ApiProjetFlutter)

python app.py


Le modéle est un modele pré-entrainer de ResNet18 comportant 999 catégories. (modéle par default)
J'ai également fait un model from skratch un peu moin performant qui comporte 3 catégories. (Haut, Bas, Chaussures)

Le choix de l'API Local a été fait car lors du deploiement le model mais trop de temps et cela fait echouer la requete. J'ai egalement tester l'hebergement avec mon modele pourtant moins lours mais cela ne marche pas non plus.
(voir fichier ajouter_vetement.dart ligne 34-35) 


## Émulateur Utilisé

Emulateur utiliser est chrome(web-javascript) en utilsant la forme mobile.

## Informations de Connexion

Utilisateur 1
Email : toto@gmail.com
Mot de passe : azerty
Utilisateur 2
Email : toto2@gmail.com
Mot de passe : azerty
