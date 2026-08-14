# IMPLÉMENTATION — COMMUNAUTÉ BIRDSENSE AI

Tu dois implémenter une fonctionnalité complète de **Communauté / Science participative** dans l'application BirdSense AI existante.

## 1. OBJECTIF

BirdSense AI ne doit pas devenir un simple réseau social.

La communauté doit permettre aux utilisateurs de **partager, explorer et valider des observations d'oiseaux**, afin de transformer les utilisateurs en contributeurs d'un réseau de données sur la biodiversité.

Le concept central est :

**L'IA détecte → l'utilisateur observe → la communauté vérifie → les données enrichissent la connaissance collective.**

Avant de modifier le code, analyse l'architecture actuelle du projet et réutilise au maximum les composants, services, modèles, conventions et design system déjà présents.

Ne recrée pas inutilement ce qui existe déjà.

---

# 2. ESPACE COMMUNAUTÉ

Créer un espace accessible depuis la navigation principale de l'application.

L'utilisateur doit pouvoir :

* consulter les observations publiques récentes ;
* rechercher une espèce ;
* filtrer les observations ;
* ouvrir le détail d'une observation ;
* consulter le profil de l'observateur ;
* aider à identifier une observation incertaine ;
* consulter les observations sur une carte ;
* enregistrer une observation dans ses favoris ;
* signaler une observation problématique.

L'expérience doit être moderne, fluide et cohérente avec le reste de BirdSense AI.

---

# 3. FEED DES OBSERVATIONS

Créer une page principale "Communauté".

Elle doit présenter les observations sous forme de cartes riches.

Chaque observation doit afficher :

* photo ;
* espèce identifiée ;
* nombre d'individus ;
* score de confiance IA ;
* localisation approximative ;
* date ;
* heure ;
* nom ou pseudo de l'observateur ;
* statut de validation ;
* bouton favori ;
* bouton commentaire si cette fonctionnalité est activée ;
* bouton partager ;
* bouton signaler.

Exemple visuel :

OBSERVATION

Lass
📍 Zone humide — Dakar
Il y a 15 min

[PHOTO DE L'OISEAU]

🐦 Pélican gris

6 individus

Confiance IA : 96 %

🟢 Identification confirmée

Actions :

♡ like
💬 Commenter
↗ Partager
••• Signaler/telecharger

---

# 4. RECHERCHE ET FILTRES

En haut de la communauté :

Champ de recherche :

"Rechercher une espèce, une zone..."

Ajouter des filtres :

* Toutes les observations
* Récentes
* Près de moi
* Espèces rares
* À vérifier
* Plus populaires

Filtres supplémentaires :

* espèce ;
* date ;
* zone/région ;
* nombre d'individus ;
* niveau de confiance ;
* statut de validation.

L'interface des filtres doit être simple et élégante.

---

# 5. DÉTAIL D'UNE OBSERVATION

Créer un écran détaillé.

Afficher :

* image originale ;
* résultat de détection ;
* bounding boxes si disponibles ;
* espèce ;
* nombre d'individus ;
* score de confiance ;
* date ;
* heure ;
* zone géographique ;
* observateur ;
* statut de validation.

Afficher également les informations pertinentes concernant l'espèce.

Ajouter une section :

"Pourquoi cette identification ?"

Elle doit expliquer simplement que l'identification provient du modèle IA et afficher son niveau de confiance.

Ne jamais présenter une prédiction IA comme une certitude scientifique.

---

# 6. STATUT DE VALIDATION

Une observation peut avoir plusieurs statuts :

🟡 IA uniquement

🔵 Communauté confirmée

🟢 Expert confirmé

⚠️ À vérifier

Le statut doit être clairement visible.

---

# 7. VALIDATION COMMUNAUTAIRE

C'est une fonctionnalité importante.

Lorsqu'une observation présente une confiance faible ou moyenne :

Afficher :

"Cette identification nécessite peut-être une vérification."

Bouton :

"Je peux aider à identifier"

L'utilisateur peut proposer :

* une autre espèce ;
* son niveau de confiance ;
* une courte justification.

Exemple :

"Je pense qu'il s'agit plutôt d'une Aigrette garzette car la forme du bec et la silhouette correspondent davantage."

Les utilisateurs ayant un profil ou un niveau d'expertise supérieur peuvent être davantage valorisés dans le système de validation.

---

# 8. VALIDATION EXPERTE

Prévoir dans l'architecture la possibilité d'avoir des utilisateurs avec différents niveaux :

* Observateur
* Amateur
* Expert
* Chercheur / administrateur

Une observation peut évoluer :

IA

↓

Validation communautaire

↓

Validation experte

Ne pas implémenter une logique artificiellement complexe si elle n'est pas nécessaire, mais prévoir une architecture suffisamment propre pour l'évolution future.

---

# 9. CARTE COMMUNAUTAIRE

Créer une vue cartographique des observations.

Afficher :

* observations individuelles ;
* clusters ;
* zones riches en observations ;
* éventuellement heatmap.

Filtres :

* espèce ;
* période ;
* zone ;
* statut.

IMPORTANT :

Ne jamais exposer automatiquement les coordonnées GPS exactes d'une observation sensible.

Pour certaines espèces rares ou vulnérables, afficher uniquement une zone approximative.

Exemple :

❌ Latitude/longitude exacte

✅ "Zone de Dakar"

Prévoir cette logique dans le modèle de données et l'API.

---

# 10. PROFIL OBSERVATEUR

Créer une page profil publique.

Afficher :

* avatar ;
* nom/pseudo ;
* niveau ;
* nombre d'observations ;
* nombre d'espèces ;
* contributions ;
* validations ;
* badges éventuels.

Exemple :

Lass

Observateur niveau 8

124 observations

31 espèces

8 validations

Créer une présentation visuelle moderne.

---

# 11. COLLECTION PERSONNELLE

Chaque utilisateur doit pouvoir retrouver les espèces qu'il a déjà observées.

Créer une section :

"Ma collection"

Afficher :

31 / 100 espèces observées

avec les espèces sous forme de cartes.

Une espèce observée peut être "débloquée" dans la collection.

Cette fonctionnalité peut être reliée à la gamification.

---

# 12. FAVORIS

Permettre de sauvegarder des observations intéressantes.

Créer une section :

"Mes favoris"

---

# 13. PARTAGE

Permettre de partager une observation.

Créer une carte de partage élégante contenant :

BirdSense AI

Nom de l'espèce

Nombre d'individus

Score de confiance

Zone

Photo

Créer une expérience de partage simple vers les applications disponibles sur le téléphone.

---

# 14. COMMENTAIRES

Prévoir des commentaires simples sur les observations.

Ne pas transformer la fonctionnalité en réseau social complet.

Le but des commentaires est principalement :

* discuter d'une observation ;
* apporter une information ;
* aider à identifier ;
* partager une précision.

Prévoir également la possibilité de supprimer son propre commentaire et de signaler un commentaire.

---

# 15. SIGNALEMENT

Ajouter "Signaler".

Motifs :

* mauvaise identification ;
* fausse observation ;
* contenu inapproprié ;
* spam ;
* localisation sensible ;
* autre.

Le signalement doit être enregistré côté backend.

---

# 16. NOTIFICATIONS

Prévoir des notifications pour :

* quelqu'un a validé mon observation ;
* quelqu'un a proposé une autre identification ;
* mon observation a été confirmée ;
* une observation importante a été détectée ;
* nouveau badge ;
* réponse à une observation.

Ne pas envoyer trop de notifications.

---

# 17. INTÉGRATION AVEC L'ASSISTANT IA

C'est une partie ESSENTIELLE.

L'assistant BirdSense AI doit pouvoir utiliser les données communautaires lorsqu'elles sont pertinentes.

Exemples de questions :

"Quelles espèces ont été observées récemment ?"

"Y a-t-il des espèces rares observées près de moi ?"

"Pourquoi cette observation est-elle marquée comme à vérifier ?"

"Quelles sont les espèces les plus observées cette semaine ?"

L'assistant doit être capable de récupérer les données nécessaires via les API disponibles.

Mais il doit également continuer à fonctionner comme un assistant conversationnel général spécialisé dans les oiseaux et la biodiversité.

Il ne faut donc PAS obliger l'utilisateur à fournir des données pour utiliser l'assistant.

---

# 18. INTELLIGENCE CONTEXTUELLE

L'assistant doit fonctionner selon deux situations.

### Question générale

Utilisateur :

"Pourquoi les flamants roses sont-ils roses ?"

Réponse directe avec les connaissances générales de l'IA.

### Question basée sur les données

Utilisateur :

"Qu'est-ce que j'ai observé cette semaine ?"

L'assistant utilise les données BirdSense.

L'utilisateur ne doit jamais avoir à sélectionner manuellement un "mode général" ou un "mode données".

Le système doit comprendre le contexte automatiquement.

---

# 19. MODÈLE DE DONNÉES

Adapter les modèles existants plutôt que recréer la base.

Si nécessaire, prévoir des entités équivalentes à :

Observation

* id
* user
* image
* species
* detected_count
* confidence_score
* latitude
* longitude
* location_label
* observed_at
* visibility
* validation_status
* created_at
* updated_at

Comment

* id
* observation
* user
* content
* created_at

Validation

* id
* observation
* user
* proposed_species
* confidence
* comment
* created_at

Like/Favorite

* id
* observation
* user
* created_at

Report

* id
* observation
* user
* reason
* created_at
* status

Adapter ces structures au modèle actuel du projet si elles existent déjà.

---

# 20. API

Créer ou compléter les endpoints nécessaires pour :

* récupérer les observations publiques ;
* récupérer une observation ;
* créer une observation publique ;
* modifier la visibilité ;
* rechercher ;
* filtrer ;
* ajouter/supprimer un favori ;
* commenter ;
* valider ;
* signaler ;
* récupérer un profil ;
* récupérer une collection ;
* récupérer les données communautaires pour l'assistant IA.

Respecter les conventions API déjà présentes dans le projet.

---

# 21. PERMISSIONS ET CONFIDENTIALITÉ

Une observation doit pouvoir être :

* privée ;
* communautaire ;
* publique.

Prévoir la protection des données personnelles.

La localisation précise ne doit pas être exposée publiquement par défaut.

Pour les espèces sensibles :

utiliser une localisation approximative.

---

# 22. DESIGN

Ne fais pas une interface de réseau social générique.

Le design doit rester BirdSense :

* nature ;
* scientifique ;
* moderne ;
* premium ;
* calme ;
* accessible.

Utiliser les composants et tokens du Design System déjà présents dans le projet.

Ne crée pas un nouveau style visuel incompatible avec l'application.

Les cartes d'observation doivent être riches mais respirantes.

Les animations doivent être discrètes et utiles.

---

# 23. PRIORITÉS D'IMPLÉMENTATION

Ne développe pas tout simultanément.

Ordre recommandé :

### PRIORITÉ 1

Feed communautaire

↓

Détail observation

↓

Profil

↓

Recherche/filtres

### PRIORITÉ 2

Carte communautaire

↓

Favoris

↓

Partage

↓

Signalement

### PRIORITÉ 3

Validation communautaire

↓

Statuts de validation

↓

Profils experts

### PRIORITÉ 4

Commentaires

↓

Notifications

↓

Gamification

### PRIORITÉ 5

Intégration profonde avec l'assistant IA

---

# 24. QUALITÉ

Avant de considérer la fonctionnalité comme terminée :

* tester tous les parcours ;
* tester les états vides ;
* tester les erreurs réseau ;
* tester les chargements ;
* tester les images absentes ;
* tester les observations privées ;
* tester les permissions ;
* tester les signalements ;
* tester les validations ;
* tester les petits écrans ;
* tester le mode sombre si présent.

Prévoir :

* loading states ;
* skeletons ;
* empty states ;
* error states ;
* retry.

---

# 25. IMPORTANT

Ne te contente pas de créer des écrans statiques ou des données fictives si le backend existe déjà.

La fonctionnalité doit être réellement connectée au backend et aux données de BirdSense AI.

Avant toute modification :

1. Analyse le projet.
2. Identifie l'architecture existante.
3. Identifie les modèles déjà présents.
4. Identifie les endpoints existants.
5. Identifie le système de navigation.
6. Identifie le Design System.
7. Réutilise ce qui existe.
8. Implémente la fonctionnalité sans casser les fonctionnalités actuelles.

Si une partie du backend nécessaire n'existe pas, crée-la proprement.

Ne modifie pas arbitrairement les fonctionnalités existantes.

À la fin, vérifie que l'application compile et que le parcours complet fonctionne :

**Connexion → Communauté → Observation → Détail → Profil → Validation → Carte → Assistant IA.**

Le résultat attendu est une véritable fonctionnalité de **science participative**, pas un simple réseau social.
