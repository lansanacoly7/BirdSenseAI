import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MbTilesTileProvider extends TileProvider {
  final String mbtilesPath;
  MbTilesTileProvider({required this.mbtilesPath});

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return NetworkImage('https://tile.openstreetmap.org/${coordinates.z}/${coordinates.x}/${coordinates.y}.png');
  }

  void dispose() {}
}
