import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'species_detail_screen.dart';

class SpeciesItem {
  final String id;
  final String scientificName;
  final String commonNameFr;
  final String family;
  final String iucnCategory;
  final String description;

  const SpeciesItem({
    required this.id,
    required this.scientificName,
    required this.commonNameFr,
    required this.family,
    required this.iucnCategory,
    required this.description,
  });
}

class SpeciesCatalogScreen extends StatefulWidget {
  const SpeciesCatalogScreen({super.key});

  @override
  State<SpeciesCatalogScreen> createState() => _SpeciesCatalogScreenState();
}

class _SpeciesCatalogScreenState extends State<SpeciesCatalogScreen> {
  String _searchQuery = '';

  final List<SpeciesItem> _speciesList = const [
    SpeciesItem(
      id: '1',
      scientificName: 'Pelecanus onocrotalus',
      commonNameFr: 'Pélican blanc',
      family: 'Pelecanidae',
      iucnCategory: 'LC',
      description: 'Grand oiseau aquatique caractérisé par une large poche sous le bec.',
    ),
    SpeciesItem(
      id: '2',
      scientificName: 'Phoenicopterus roseus',
      commonNameFr: 'Flamant rose',
      family: 'Phoenicopteridae',
      iucnCategory: 'LC',
      description: 'Grand échassier aux plumes roses vivant dans les lagunes et lacs salés.',
    ),
    SpeciesItem(
      id: '3',
      scientificName: 'Haliaeetus vocifer',
      commonNameFr: 'Aigle pêcheur d\'Afrique',
      family: 'Accipitridae',
      iucnCategory: 'LC',
      description: 'Rapace emblématique des zones humides africaines au cri puissant.',
    ),
    SpeciesItem(
      id: '4',
      scientificName: 'Necrosyrtes monachus',
      commonNameFr: 'Vautour charognard',
      family: 'Accipitridae',
      iucnCategory: 'CR',
      description: 'Petit vautour d\'Afrique de l\'Ouest, en danger critique d\'extinction.',
    ),
    SpeciesItem(
      id: '5',
      scientificName: 'Ardea goliath',
      commonNameFr: 'Héron goliath',
      family: 'Ardeidae',
      iucnCategory: 'LC',
      description: 'Le plus grand héron du monde, haut de plus de 1,50 mètre.',
    ),
  ];

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
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _speciesList.where((species) {
      final query = _searchQuery.toLowerCase();
      return species.commonNameFr.toLowerCase().contains(query) ||
          species.scientificName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Espèces',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un oiseau...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Fake Image Placeholder with Hero
                          Hero(
                            tag: 'species_img_${item.id}',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                              child: const Icon(
                                Icons.eco,
                                size: 40,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.commonNameFr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            letterSpacing: -0.5,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: iucnColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.iucnCategory,
                                          style: TextStyle(
                                            color: iucnColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.scientificName,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.family.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                      letterSpacing: 1.0,
                                    ),
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
        ],
      ),
    );
  }
}
