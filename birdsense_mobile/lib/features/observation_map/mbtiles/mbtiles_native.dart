import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:path/path.dart' as p;

class MbTilesTileProvider extends TileProvider {
  final String mbtilesPath;
  sqlite.Database? _db;
  bool _isInit = false;
  bool _initFailed = false;

  MbTilesTileProvider({required this.mbtilesPath});

  Future<void> _initDb() async {
    if (_isInit || _initFailed) return;
    try {
      String path = mbtilesPath;
      if (mbtilesPath.startsWith('assets/')) {
        final dir = await getTemporaryDirectory();
        final fileName = p.basename(mbtilesPath);
        final file = File(p.join(dir.path, fileName));
        
        if (!await file.exists()) {
          final data = await rootBundle.load(mbtilesPath);
          await file.writeAsBytes(
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        }
        path = file.path;
      }
      
      _db = sqlite.sqlite3.open(path);
      _isInit = true;
    } catch (e) {
      _initFailed = true;
    }
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    if (!_isInit && !_initFailed) {
      _initDb();
      return MemoryImage(_transparentPixel);
    }
    
    if (_initFailed || _db == null) {
      return MemoryImage(_transparentPixel);
    }

    try {
      final z = coordinates.z;
      final x = coordinates.x;
      final y = (1 << z) - 1 - coordinates.y;

      final stmt = _db!.prepare(
          'SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?');
      final result = stmt.select([z, x, y]);
      stmt.dispose();

      if (result.isNotEmpty) {
        final tileData = result.first['tile_data'] as Uint8List;
        return MemoryImage(tileData);
      }
    } catch (e) {}
    
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
    _db?.dispose();
  }
}
