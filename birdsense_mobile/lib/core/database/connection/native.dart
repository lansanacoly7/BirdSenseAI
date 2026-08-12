import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'birdsense_db.sqlite'));

    // Chiffrement SQLCipher activé
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        const cipherKey = String.fromEnvironment(
          'SQLCIPHER_KEY',
          defaultValue: 'birdsense_secure_key_2026',
        );
        rawDb.execute("PRAGMA key = '$cipherKey';");
      },
    );
  });
}
