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
      appBar: AppBar(
        title: const Text('Catalogue des Espèces'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Rechercher une espèce (ex: Pélican)...',
                prefixIcon: Icon(Icons.search, color: AppColors.accentAmber),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryCanopy.withAlpha(80),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.flutter_dash, color: AppColors.accentAmber, size: 28),
                    ),
                    title: Text(
                      item.commonNameFr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          item.scientificName,
                          style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(item.family, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getIucnColor(item.iucnCategory),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.iucnCategory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpeciesDetailScreen(species: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
