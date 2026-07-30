import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sqlite3/sqlite3.dart';

/// Un TileProvider hors-ligne qui extrait les tuiles d'une base MBTiles (SQLite) locale.
/// Implémentation réelle pour l'extension Hackathon.
class MbTilesTileProvider extends TileProvider {
  final String mbtilesPath;
  late final Database _db;
  bool _isDbOpen = false;

  MbTilesTileProvider({required this.mbtilesPath}) {
    _initDb();
  }

  void _initDb() {
    try {
      _db = sqlite3.open(mbtilesPath);
      _isDbOpen = true;
    } catch (e) {
      debugPrint('Erreur ouverture MBTiles : \$e');
      _isDbOpen = false;
    }
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    if (!_isDbOpen) {
      return MemoryImage(_transparentPixel);
    }

    try {
      // MBTiles utilise un format TMS (Y inversé par rapport au XYZ standard)
      final int z = coordinates.z;
      final int x = coordinates.x;
      final int y = (1 << z) - 1 - coordinates.y;

      final stmt = _db.prepare(
          'SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?');
      final result = stmt.select([z, x, y]);
      stmt.dispose();

      if (result.isNotEmpty) {
        final Uint8List tileData = result.first['tile_data'] as Uint8List;
        return MemoryImage(tileData);
      }
    } catch (e) {
      debugPrint('Erreur lecture tuile \$coordinates : \$e');
    }

    // Retourne une tuile vide si non trouvée
    return MemoryImage(_transparentPixel);
  }

  static final Uint8List _transparentPixel = Uint8List.fromList([
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
    0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
  ]);

  void dispose() {
    if (_isDbOpen) {
      _db.dispose();
      _isDbOpen = false;
    }
  }
}
