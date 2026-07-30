# 🏆 PHASE 2 : "Wow Features" (Gagner le Hackathon)

Afin de garantir la victoire et d'ajouter une forte valeur perçue (AR, Multimodal, GenAI, Impact), voici les tâches additionnelles réparties entre les membres de l'équipe :

### 1️⃣ Lansana Coly — UI/UX & Interactions
- [ ] **T1.5 — UI Scan Bioacoustique :** Créer le widget `AudioWaveformWidget` (animation de la waveform).
- [ ] **T1.6 — HUD Réalité Augmentée :** Implémenter le `RadarScannerOverlay` et le style de ciblage AR.
- [ ] **T1.7 — UI Assistant IA :** Créer le chat flottant avec effet d'écriture machine.
- [ ] **T1.8 — UI Dashboard Impact :** Intégrer les jauges d'impact écologique sur l'onglet Stats.

### 2️⃣ El Hadji Massogui Diop — Hardware & Synchronisation
- [ ] **T2.4 — Capture Micro Native :** Extraire le flux de décibels brut via le microphone du device.
- [ ] **T2.5 — Sync Impact Local :** Sauvegarder les "Scores d'impact" (calculés par Pathé) dans la base SQLite locale.

### 3️⃣ Pape Alioune Sène — Backend Core & Infrastructure
- [ ] **T3.4 — Endpoint Chatbot IA :** Créer une route WebSockets ou SSE (Server-Sent Events) pour streamer les réponses génératives en temps réel vers le mobile.

### 4️⃣ Ibrahima Khalilou Diallo — Ingénieur CV & YOLO
- [ ] **T4.4 — Coordonnées pour HUD AR :** Exposer les Bounding Boxes (x, y, w, h) au format requis par le HUD de Lansana.
- [ ] **T4.5 — IA Audio (Optionnel) :** Coupler un modèle de reconnaissance audio (ex: BirdNET) au flux de Massogui.

### 5️⃣ Pathé Fall — Dev Fullstack Data & Analytics
- [ ] **T5.5 — Prompt Engineering RAG :** Connecter l'API LLM (OpenAI/Gemini) pour l'Assistant Ornithologue avec le contexte des oiseaux de la région.
- [ ] **T5.6 — Formule Impact Écologique :** Calculer le JSON de la Heatmap et l'indice d'impact du joueur.
