import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    // Utilise une base IndexedDB dans Chrome, qui est compatible Web !
    return WebDatabase('birdsense_db_web');
  });
}
