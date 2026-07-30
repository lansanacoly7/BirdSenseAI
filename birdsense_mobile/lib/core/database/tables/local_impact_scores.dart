import 'package:drift/drift.dart';
import 'local_observations.dart';

/// Table pour stocker les scores d'impact calculés (Phase 2).
@DataClassName('LocalImpactScore')
class LocalImpactScores extends Table {
  TextColumn get id => text()();
  TextColumn get observationId => text().references(LocalObservations, #id)();
  RealColumn get score => real()();
  TextColumn get level => text()();
  TextColumn get calculationVersion => text()();
  DateTimeColumn get computedAt => dateTime()();
  TextColumn get componentsJson => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
