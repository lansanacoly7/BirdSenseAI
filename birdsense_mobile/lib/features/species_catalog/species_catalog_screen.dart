import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import '../chat/chat_screen.dart';
import 'species_detail_screen.dart';

class SpeciesItem {
  final String id;
  final String scientificName;
  final String commonNameFr;
  final String family;
  final String order;
  final String iucnCategory;
  final String iucnDescription;
  final String imageUrl;
  final String assetImage; // Local asset path for reliable loading
  final String illustrationUrl;
  final String audioUrl;
  final String description;
  final String habitat;
  final String diet;
  final String wingspan;
  final String weight;
  final String lifespan;
  final String migrationStatus;
  final String didYouKnow;
  final String ecologicalRole;
  final String acousticFreq;

  const SpeciesItem({
    required this.id,
    required this.scientificName,
    required this.commonNameFr,
    required this.family,
    required this.order,
    required this.iucnCategory,
    required this.iucnDescription,
    required this.imageUrl,
    required this.assetImage,
    required this.illustrationUrl,
    required this.audioUrl,
    required this.description,
    required this.habitat,
    required this.diet,
    required this.wingspan,
    required this.weight,
    required this.lifespan,
    required this.migrationStatus,
    required this.didYouKnow,
    required this.ecologicalRole,
    required this.acousticFreq,
  });

  factory SpeciesItem.fromJson(Map<String, dynamic> json) {
    final scientificName = json['scientific_name'] ?? 'Inconnu';
    
    // Données simulées par défaut
    String diet = 'Insectes et graines';
    String wingspan = '30 - 50 cm';
    String weight = '50 - 150 g';
    String lifespan = '3 - 5 ans';
    String migrationStatus = 'Résident';
    String didYouKnow = 'Cet oiseau joue un rôle clé dans la pollinisation et la dispersion des graines.';
    String ecologicalRole = 'Contrôle des populations d\'insectes.';
    String acousticFreq = '2.5 kHz - 4.5 kHz';
    String description = json['description'] ?? 'Une espèce remarquable observée au Sénégal.';
    String habitat = json['habitat'] ?? 'Savanes et zones boisées.';

    // Détails spécifiques pour les 10 oiseaux du Sénégal avec un niveau pédagogique d'excellence
    if (scientificName == "Passer domesticus") {
      diet = "Granivore et opportuniste (graines, insectes, miettes)";
      wingspan = "21 - 25 cm";
      weight = "24 - 39 g";
      lifespan = "3 à 5 ans (jusqu'à 13 ans en captivité)";
      migrationStatus = "Sédentaire strict";
      didYouKnow = "Originaire du Moyen-Orient, le Moineau domestique a suivi l'expansion de l'agriculture humaine à travers le monde. Il est aujourd'hui l'un des oiseaux les plus largement répartis sur la planète.";
      ecologicalRole = "Il joue un rôle double : régulateur des petits insectes au printemps lors du nourrissage des jeunes, mais aussi disperseur de graines et nettoyeur des zones urbaines.";
      description = "Petit passereau robuste au bec conique adapté pour broyer les graines. Le mâle se distingue par une calotte grise, une nuque rousse et une bavette noire sur la gorge, dont la taille indique son statut social.";
      habitat = "Exclusivement inféodé aux installations humaines : villes, villages, fermes et parcs urbains.";
    } else if (scientificName == "Corvus albus") {
      diet = "Omnivore généraliste (charognes, fruits, invertébrés)";
      wingspan = "85 - 100 cm";
      weight = "400 - 600 g";
      lifespan = "10 à 15 ans";
      migrationStatus = "Sédentaire avec mouvements locaux";
      didYouKnow = "Le Corbeau pie fait preuve d'une intelligence exceptionnelle. Il est capable d'utiliser la circulation routière pour casser des noix ou résoudre des problèmes complexes pour obtenir de la nourriture.";
      ecologicalRole = "En tant que charognard urbain et rural, il participe activement à la décomposition de la matière organique et au nettoyage sanitaire des écosystèmes.";
      acousticFreq = "1.5 kHz (Cri puissant et rauque 'kraak')";
      description = "Grand corvidé au plumage noir lustré contrastant fortement avec un large collier blanc couvrant la poitrine et la nuque. Son bec est robuste, noir et légèrement incurvé.";
      habitat = "Zones ouvertes, savanes, bords de mer, ainsi que les environnements fortement urbanisés.";
    } else if (scientificName == "Bubulcus ibis") {
      diet = "Insectivore (criquets, sauterelles, grenouilles, tiques)";
      wingspan = "88 - 96 cm";
      weight = "300 - 400 g";
      lifespan = "Environ 10 ans";
      migrationStatus = "Migrateur partiel / Nomade";
      didYouKnow = "Contrairement aux autres hérons qui pêchent, le Héron garde-bœufs a évolué pour chasser dans les plaines. Il suit les grands mammifères (ou les tracteurs) qui débusquent les insectes dans les hautes herbes.";
      ecologicalRole = "C'est un allié précieux pour l'agriculture et l'élevage, car il consomme des quantités massives d'insectes ravageurs et de tiques parasitant le bétail.";
      description = "Héron trapu au plumage entièrement blanc. En période nuptiale, il arbore de magnifiques plumes ornementales (aigrettes) de couleur chamois ou rousse sur la tête, le dos et la poitrine.";
      habitat = "Prairies, pâturages, savanes inondables et abords de zones humides.";
    } else if (scientificName == "Ardea cinerea") {
      diet = "Piscivore et carnivore (poissons, amphibiens, rongeurs)";
      wingspan = "155 - 195 cm";
      weight = "1.5 - 2.1 kg";
      lifespan = "Jusqu'à 15 - 20 ans";
      migrationStatus = "Hivernant migrateur au Sénégal";
      didYouKnow = "Lorsqu'il pêche, le Héron cendré fait preuve d'une patience remarquable, capable de rester parfaitement immobile pendant des heures. Son cou se détend comme un ressort pour harponner sa proie à la vitesse de l'éclair.";
      ecologicalRole = "Il se situe au sommet de la chaîne alimentaire aquatique, régulant les populations de poissons malades et de rongeurs des rives.";
      description = "Grand oiseau majestueux au plumage à dominante gris cendré, avec un long cou blanc rayé de noir. Sa tête est blanche, ornée d'une crête noire et d'un long bec jaune en forme de poignard.";
      habitat = "Mangroves, estuaires, lacs, fleuves et toutes zones humides peu profondes.";
    } else if (scientificName == "Egretta garzetta") {
      diet = "Carnivore (petits poissons, crustacés, insectes aquatiques)";
      wingspan = "88 - 106 cm";
      weight = "350 - 550 g";
      lifespan = "Environ 9 ans";
      migrationStatus = "Sédentaire et migrateur paléarctique";
      didYouKnow = "À la fin du 19ème siècle, cette espèce a frôlé l'extinction car ses longues plumes immaculées (les 'aigrettes') étaient vendues à prix d'or pour décorer les chapeaux de la mode européenne.";
      ecologicalRole = "Exerce une pression de prédation essentielle sur les petits organismes aquatiques des zones littorales, maintenant l'équilibre des marais.";
      description = "Héron élégant et élancé au plumage d'un blanc pur. Il est facilement identifiable à son fin bec noir en forme de poignard et, surtout, à ses doigts jaunes contrastant avec ses pattes noires.";
      habitat = "Zones humides peu profondes, vasières, estuaires, marais salants et mangroves.";
    } else if (scientificName == "Falco tinnunculus") {
      diet = "Carnivore (micromammifères, lézards, gros insectes)";
      wingspan = "65 - 82 cm";
      weight = "150 - 300 g";
      lifespan = "4 à 8 ans";
      migrationStatus = "Hivernant régulier et résident local";
      didYouKnow = "Il est célèbre pour son vol stationnaire caractéristique appelé 'vol en Saint-Esprit'. Il se maintient face au vent en battant rapidement des ailes pour scruter le sol avant de piquer sur sa proie.";
      ecologicalRole = "Excellent auxiliaire agricole, il régule naturellement les populations de rongeurs et de gros insectes ravageurs dans les cultures.";
      description = "Petit rapace diurne au profil effilé. Le dos est roux tacheté de noir. Le mâle se distingue par une tête et une queue gris bleuté, avec une bande noire terminale sur la queue.";
      habitat = "Savanes ouvertes, zones agricoles, steppes et parfois milieux urbains (clochers, hauts bâtiments).";
    } else if (scientificName == "Streptopelia decaocto") {
      diet = "Granivore (graines, céréales, jeunes pousses)";
      wingspan = "47 - 55 cm";
      weight = "150 - 225 g";
      lifespan = "Jusqu'à 10 ans";
      migrationStatus = "Sédentaire en expansion";
      didYouKnow = "Originaire d'Asie, cette espèce a connu l'une des expansions naturelles les plus spectaculaires du 20ème siècle, colonisant l'Europe entière puis l'Afrique, portée par sa grande capacité d'adaptation.";
      ecologicalRole = "Constitue une importante base de proies pour les rapaces diurnes et participe à la dissémination de certaines plantes.";
      acousticFreq = "0.8 kHz - 1.2 kHz (Chant trisyllabique très rythmé)";
      description = "Tourterelle au plumage élégant beige rosé ou gris sable. Son signe distinctif est un demi-collier noir encadré de blanc, situé sur la nuque, d'où elle tire son nom scientifique 'decaocto' (dix-huit en grec, en référence au mythe d'une servante).";
      habitat = "Zones urbaines, parcs, jardins, villages et zones agricoles.";
    } else if (scientificName == "Merops pusillus") {
      diet = "Insectivore strict (abeilles, guêpes, libellules)";
      wingspan = "25 - 28 cm";
      weight = "13 - 18 g";
      lifespan = "Environ 5 ans";
      migrationStatus = "Sédentaire et migrateur intra-africain";
      didYouKnow = "Pour neutraliser le venin des abeilles et des guêpes, le Guêpier nain utilise une technique spectaculaire : il frappe l'insecte contre une branche et frotte l'abdomen pour extraire le dard avant de l'avaler.";
      ecologicalRole = "Il est le prédateur par excellence des insectes volants hyménoptères, contrôlant ainsi de manière fascinante leurs populations.";
      description = "Minuscule oiseau aux couleurs éclatantes : dos vert brillant, gorge jaune vif soulignée d'un collier noir, et poitrine rousse. Son bec noir est long, fin et très légèrement incurvé vers le bas.";
      habitat = "Savanes boisées, lisières de forêts, galeries forestières et bords de cours d'eau.";
    } else if (scientificName == "Halcyon senegalensis") {
      diet = "Insectivore et carnivore (sauterelles, lézards, grenouilles)";
      wingspan = "30 - 35 cm";
      weight = "40 - 60 g";
      lifespan = "Environ 6 ans";
      migrationStatus = "Migrateur intra-africain (suit les pluies)";
      didYouKnow = "Bien qu'il porte le nom de 'martin-pêcheur', cet oiseau est en réalité forestier. Il plonge très rarement dans l'eau et passe le plus clair de son temps à chasser des invertébrés dans la végétation dense.";
      ecologicalRole = "Prédateur très actif des orthoptères (criquets) et des petits vertébrés dans les écosystèmes arborés.";
      description = "Superbe oiseau au dos, ailes et queue d'un bleu cobalt éclatant. Son ventre est blanc pur. Il possède un grand bec puissant, caractéristique des martins-chasseurs, dont la mandibule supérieure est rouge vif et l'inférieure noire.";
      habitat = "Forêts-galeries, savanes boisées et parcs urbains très arborés.";
    } else if (scientificName == "Nectarinia senegalensis") {
      diet = "Nectarivore et insectivore (nectar, petites araignées)";
      wingspan = "14 - 16 cm";
      weight = "8 - 11 g";
      lifespan = "3 à 5 ans";
      migrationStatus = "Sédentaire";
      didYouKnow = "Les souimangas sont l'équivalent écologique africain des colibris américains. Comme eux, ils se nourrissent de nectar, mais au lieu de voler sur place en permanence, ils préfèrent souvent se percher sur la fleur.";
      ecologicalRole = "C'est un pollinisateur crucial. En plongeant son bec dans les corolles, il se couvre le front de pollen qu'il transporte ensuite d'une fleur à l'autre.";
      acousticFreq = "4.0 kHz - 6.5 kHz (Sons aigus et métalliques)";
      description = "Petit passereau au dimorphisme sexuel très marqué. Le mâle arbore un plumage noir velouté magnifique contrastant de façon spectaculaire avec une gorge et une poitrine rouge écarlate brillant, ornées de moustaches vert métallique.";
      habitat = "Savanes ouvertes, buissons fleuris, parcs et jardins.";
    }

    return SpeciesItem(
      id: json['id']?.toString() ?? '',
      scientificName: scientificName,
      commonNameFr: json['common_name_fr'] ?? 'Inconnu',
      family: json['family'] ?? 'Inconnue',
      order: json['order_name'] ?? 'Inconnu',
      iucnCategory: json['iucn_status'] ?? 'NE',
      iucnDescription: 'Status UICN: ${json['iucn_status']}',
      imageUrl: json['image_url'] ?? '',
      assetImage: 'assets/birds/pelican_blanc.png', // Default fallback
      illustrationUrl: json['image_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      description: description,
      habitat: habitat,
      diet: diet,
      wingspan: wingspan,
      weight: weight,
      lifespan: lifespan,
      migrationStatus: migrationStatus,
      didYouKnow: didYouKnow,
      ecologicalRole: ecologicalRole,
      acousticFreq: acousticFreq,
    );
  }
}

final speciesListProvider = FutureProvider<List<SpeciesItem>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/api/v1/species');
  final List<dynamic> data = response.data['species'];
  return data.map((json) => SpeciesItem.fromJson(json)).toList();
});

class SpeciesCatalogScreen extends ConsumerStatefulWidget {
  const SpeciesCatalogScreen({super.key});

  @override
  ConsumerState<SpeciesCatalogScreen> createState() => _SpeciesCatalogScreenState();
}

class _SpeciesCatalogScreenState extends ConsumerState<SpeciesCatalogScreen> {
  String _searchQuery = '';
  String? _playingAudioId;

  Color _getIucnColor(String category) {
    switch (category) {
      case 'LC':
        return AppColors.iucnLeastConcern;
      case 'NT':
        return AppColors.iucnNearThreatened;
      case 'VU':
        return AppColors.iucnVulnerable;
      case 'EN':
        return AppColors.iucnEndangered;
      case 'CR':
        return AppColors.iucnCriticallyEndangered;
      default:
        return AppColors.lightTextMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final speciesAsyncValue = ref.watch(speciesListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: speciesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (speciesDatabase) {
          final filteredList = speciesDatabase.where((species) {
            final query = _searchQuery.toLowerCase();
            return species.commonNameFr.toLowerCase().contains(query) ||
                species.scientificName.toLowerCase().contains(query) ||
                species.family.toLowerCase().contains(query);
          }).toList();

          return CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            elevation: 0,
            actions: [
              // Theme Toggle Button
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: AppColors.primaryAction,
                ),
                tooltip: 'Changer le thème',
                onPressed: () {
                  ref.read(themeModeProvider.notifier).state =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              // AI Chat Assistant Quick Button
              IconButton(
                icon: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryAction),
                tooltip: 'Assistant IA',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Espèces du Sénégal',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un oiseau, une famille...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAction),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = filteredList[index];
                final iucnColor = _getIucnColor(item.iucnCategory);
                final isAudioPlaying = _playingAudioId == item.id;

                return Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpeciesDetailScreen(species: item),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // High Resolution Bird Image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                            ),
                            child: Stack(
                              children: [
                                item.imageUrl.isNotEmpty
                                    ? (item.imageUrl.startsWith('assets/')
                                        ? Image.asset(
                                            item.imageUrl,
                                            width: 110,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                item.assetImage,
                                                width: 110,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.network(
                                            item.imageUrl,
                                            width: 110,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                item.assetImage,
                                                width: 110,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ))
                                    : Image.asset(
                                        item.assetImage,
                                        width: 110,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                // Gradient Overlay on image
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.black.withOpacity(0.2),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.commonNameFr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: -0.5,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // IUCN Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: iucnColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: iucnColor.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          item.iucnCategory,
                                          style: TextStyle(
                                            color: iucnColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.scientificName,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.family.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryAction,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      // Instant Audio Play Button
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (isAudioPlaying) {
                                              _playingAudioId = null;
                                            } else {
                                              _playingAudioId = item.id;
                                            }
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isAudioPlaying
                                                ? AppColors.secondaryAction
                                                : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isAudioPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                                                size: 14,
                                                color: isAudioPlaying
                                                    ? Colors.white
                                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isAudioPlaying ? 'Chant...' : 'Chant',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isAudioPlaying
                                                      ? Colors.white
                                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: filteredList.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      );
        },
      ),
    );
  }
}
