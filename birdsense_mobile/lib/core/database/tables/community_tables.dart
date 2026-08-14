import 'package:drift/drift.dart';

/// Table SQLite locale pour la mise en cache du flux communautaire
class CommunityFeed extends Table {
  TextColumn get id => text()();
  TextColumn get userName => text()();
  TextColumn get userAvatar => text()();
  TextColumn get userLevel => text()();
  TextColumn get locationLabel => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  BoolColumn get isLocationBlurred => boolean().withDefault(const Constant(false))();
  TextColumn get speciesNameFr => text()();
  TextColumn get speciesNameScientific => text()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  IntColumn get confidenceScore => integer()();
  TextColumn get imageUrl => text()();
  TextColumn get validationStatus => text()(); // aiOnly, community, expert, needsReview
  IntColumn get likesCount => integer().withDefault(const Constant(0))();
  BoolColumn get isLiked => boolean().withDefault(const Constant(false))();
  IntColumn get commentsCount => integer().withDefault(const Constant(0))();
  BoolColumn get isSensitive => boolean().withDefault(const Constant(false))();
  TextColumn get aiReasoning => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table des favoris de l'utilisateur
class UserFavorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get observationId => text()();
  DateTimeColumn get savedAt => dateTime()();
}

/// Table de la collection d'espèces débloquées par l'utilisateur
class UserCollection extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get speciesId => text()();
  TextColumn get speciesFr => text()();
  TextColumn get speciesScientific => text()();
  TextColumn get imageUrl => text()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(true))();
  DateTimeColumn get unlockedAt => dateTime()();
}

/// Table des actions en attente de synchronisation WorkManager (Validations, Signalements, etc.)
class PendingActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()(); // validation, report, favorite
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, syncing, failed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
