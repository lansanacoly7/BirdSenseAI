import 'dart:async';
import 'package:flutter/foundation.dart';

enum OfflinePackStatus {
  notDownloaded,
  downloading,
  downloaded,
}

class OfflineTilePack {
  final String id;
  final String regionName;
  final String boundsDescription;
  final double minZoom;
  final double maxZoom;
  final double estimatedSizeMb;
  OfflinePackStatus status;
  double downloadProgress; // 0.0 to 1.0

  OfflineTilePack({
    required this.id,
    required this.regionName,
    required this.boundsDescription,
    required this.minZoom,
    required this.maxZoom,
    required this.estimatedSizeMb,
    this.status = OfflinePackStatus.notDownloaded,
    this.downloadProgress = 0.0,
  });
}

class OfflineMapManager extends ChangeNotifier {
  final List<OfflineTilePack> _availablePacks = [
    OfflineTilePack(
      id: 'djoudj_pack',
      regionName: 'Parc National des Oiseaux du Djoudj',
      boundsDescription: 'Lat: 16.10 à 16.45 | Lng: -16.35 à -16.10',
      minZoom: 10.0,
      maxZoom: 16.0,
      estimatedSizeMb: 45.8,
      status: OfflinePackStatus.downloaded,
      downloadProgress: 1.0,
    ),
    OfflineTilePack(
      id: 'somone_pack',
      regionName: 'Réserve Naturelle de la Somone',
      boundsDescription: 'Lat: 14.45 à 14.55 | Lng: -17.10 à -16.95',
      minZoom: 10.0,
      maxZoom: 16.0,
      estimatedSizeMb: 18.2,
      status: OfflinePackStatus.notDownloaded,
      downloadProgress: 0.0,
    ),
    OfflineTilePack(
      id: 'niokolo_pack',
      regionName: 'Parc National du Niokolo-Koba',
      boundsDescription: 'Lat: 12.50 à 13.30 | Lng: -13.30 à -12.30',
      minZoom: 9.0,
      maxZoom: 15.0,
      estimatedSizeMb: 82.4,
      status: OfflinePackStatus.notDownloaded,
      downloadProgress: 0.0,
    ),
  ];

  List<OfflineTilePack> get availablePacks => List.unmodifiable(_availablePacks);

  Future<void> downloadPack(String packId) async {
    final index = _availablePacks.indexWhere((p) => p.id == packId);
    if (index == -1) return;

    final pack = _availablePacks[index];
    if (pack.status == OfflinePackStatus.downloading) return;

    pack.status = OfflinePackStatus.downloading;
    pack.downloadProgress = 0.05;
    notifyListeners();

    // Simulate progressive MBTiles vector tile chunk download
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      pack.downloadProgress += 0.08;
      if (pack.downloadProgress >= 1.0) {
        pack.downloadProgress = 1.0;
        pack.status = OfflinePackStatus.downloaded;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> deletePack(String packId) async {
    final index = _availablePacks.indexWhere((p) => p.id == packId);
    if (index == -1) return;

    _availablePacks[index].status = OfflinePackStatus.notDownloaded;
    _availablePacks[index].downloadProgress = 0.0;
    notifyListeners();
  }
}
