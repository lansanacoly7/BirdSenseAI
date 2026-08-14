// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalObservationsTable extends LocalObservations
    with TableInfo<$LocalObservationsTable, LocalObservation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPhotoPathMeta = const VerificationMeta(
    'localPhotoPath',
  );
  @override
  late final GeneratedColumn<String> localPhotoPath = GeneratedColumn<String>(
    'local_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVideoPathMeta = const VerificationMeta(
    'localVideoPath',
  );
  @override
  late final GeneratedColumn<String> localVideoPath = GeneratedColumn<String>(
    'local_video_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncErrorMeta = const VerificationMeta(
    'lastSyncError',
  );
  @override
  late final GeneratedColumn<String> lastSyncError = GeneratedColumn<String>(
    'last_sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    latitude,
    longitude,
    localPhotoPath,
    localVideoPath,
    status,
    retryCount,
    lastSyncError,
    serverId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalObservation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('local_photo_path')) {
      context.handle(
        _localPhotoPathMeta,
        localPhotoPath.isAcceptableOrUnknown(
          data['local_photo_path']!,
          _localPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('local_video_path')) {
      context.handle(
        _localVideoPathMeta,
        localVideoPath.isAcceptableOrUnknown(
          data['local_video_path']!,
          _localVideoPathMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_sync_error')) {
      context.handle(
        _lastSyncErrorMeta,
        lastSyncError.isAcceptableOrUnknown(
          data['last_sync_error']!,
          _lastSyncErrorMeta,
        ),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalObservation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalObservation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      localPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_photo_path'],
      ),
      localVideoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_video_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastSyncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error'],
      ),
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
    );
  }

  @override
  $LocalObservationsTable createAlias(String alias) {
    return $LocalObservationsTable(attachedDatabase, alias);
  }
}

class LocalObservation extends DataClass
    implements Insertable<LocalObservation> {
  /// UUID v4 généré côté mobile. Sert de clé d'idempotence pour la synchro.
  final String id;

  /// Identifiant de l'utilisateur ayant capturé l'observation.
  final String userId;

  /// Horodatage de la capture, stocké en UTC.
  final DateTime createdAt;

  /// Coordonnées GPS au moment de la capture (nullable si GPS désactivé).
  final double? latitude;
  final double? longitude;

  /// Chemin absolu local vers la photo capturée.
  final String? localPhotoPath;

  /// Chemin absolu local vers la vidéo capturée.
  final String? localVideoPath;

  /// Statut de synchronisation : 'pending', 'syncing', 'synced', 'failed', 'abandoned'.
  final String status;

  /// Nombre de tentatives de synchronisation échouées.
  final int retryCount;

  /// Message d'erreur de la dernière tentative échouée.
  final String? lastSyncError;

  /// UUID attribué par le serveur après synchronisation réussie.
  final String? serverId;
  const LocalObservation({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.localPhotoPath,
    this.localVideoPath,
    required this.status,
    required this.retryCount,
    this.lastSyncError,
    this.serverId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || localPhotoPath != null) {
      map['local_photo_path'] = Variable<String>(localPhotoPath);
    }
    if (!nullToAbsent || localVideoPath != null) {
      map['local_video_path'] = Variable<String>(localVideoPath);
    }
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastSyncError != null) {
      map['last_sync_error'] = Variable<String>(lastSyncError);
    }
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    return map;
  }

  LocalObservationsCompanion toCompanion(bool nullToAbsent) {
    return LocalObservationsCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      localPhotoPath: localPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPhotoPath),
      localVideoPath: localVideoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localVideoPath),
      status: Value(status),
      retryCount: Value(retryCount),
      lastSyncError: lastSyncError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncError),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
    );
  }

  factory LocalObservation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalObservation(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      localPhotoPath: serializer.fromJson<String?>(json['localPhotoPath']),
      localVideoPath: serializer.fromJson<String?>(json['localVideoPath']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastSyncError: serializer.fromJson<String?>(json['lastSyncError']),
      serverId: serializer.fromJson<String?>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'localPhotoPath': serializer.toJson<String?>(localPhotoPath),
      'localVideoPath': serializer.toJson<String?>(localVideoPath),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastSyncError': serializer.toJson<String?>(lastSyncError),
      'serverId': serializer.toJson<String?>(serverId),
    };
  }

  LocalObservation copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> localPhotoPath = const Value.absent(),
    Value<String?> localVideoPath = const Value.absent(),
    String? status,
    int? retryCount,
    Value<String?> lastSyncError = const Value.absent(),
    Value<String?> serverId = const Value.absent(),
  }) => LocalObservation(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    localPhotoPath: localPhotoPath.present
        ? localPhotoPath.value
        : this.localPhotoPath,
    localVideoPath: localVideoPath.present
        ? localVideoPath.value
        : this.localVideoPath,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastSyncError: lastSyncError.present
        ? lastSyncError.value
        : this.lastSyncError,
    serverId: serverId.present ? serverId.value : this.serverId,
  );
  LocalObservation copyWithCompanion(LocalObservationsCompanion data) {
    return LocalObservation(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      localPhotoPath: data.localPhotoPath.present
          ? data.localPhotoPath.value
          : this.localPhotoPath,
      localVideoPath: data.localVideoPath.present
          ? data.localVideoPath.value
          : this.localVideoPath,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastSyncError: data.lastSyncError.present
          ? data.lastSyncError.value
          : this.lastSyncError,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalObservation(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('localPhotoPath: $localPhotoPath, ')
          ..write('localVideoPath: $localVideoPath, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    latitude,
    longitude,
    localPhotoPath,
    localVideoPath,
    status,
    retryCount,
    lastSyncError,
    serverId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalObservation &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.localPhotoPath == this.localPhotoPath &&
          other.localVideoPath == this.localVideoPath &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastSyncError == this.lastSyncError &&
          other.serverId == this.serverId);
}

class LocalObservationsCompanion extends UpdateCompanion<LocalObservation> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> localPhotoPath;
  final Value<String?> localVideoPath;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastSyncError;
  final Value<String?> serverId;
  final Value<int> rowid;
  const LocalObservationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.localVideoPath = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalObservationsCompanion.insert({
    required String id,
    required String userId,
    required DateTime createdAt,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.localVideoPath = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastSyncError = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       createdAt = Value(createdAt);
  static Insertable<LocalObservation> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? localPhotoPath,
    Expression<String>? localVideoPath,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastSyncError,
    Expression<String>? serverId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (localPhotoPath != null) 'local_photo_path': localPhotoPath,
      if (localVideoPath != null) 'local_video_path': localVideoPath,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastSyncError != null) 'last_sync_error': lastSyncError,
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? localPhotoPath,
    Value<String?>? localVideoPath,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? lastSyncError,
    Value<String?>? serverId,
    Value<int>? rowid,
  }) {
    return LocalObservationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      localVideoPath: localVideoPath ?? this.localVideoPath,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      serverId: serverId ?? this.serverId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (localPhotoPath.present) {
      map['local_photo_path'] = Variable<String>(localPhotoPath.value);
    }
    if (localVideoPath.present) {
      map['local_video_path'] = Variable<String>(localVideoPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastSyncError.present) {
      map['last_sync_error'] = Variable<String>(lastSyncError.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalObservationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('localPhotoPath: $localPhotoPath, ')
          ..write('localVideoPath: $localVideoPath, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastSyncError: $lastSyncError, ')
          ..write('serverId: $serverId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalObservationItemsTable extends LocalObservationItems
    with TableInfo<$LocalObservationItemsTable, LocalObservationItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalObservationItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observationIdMeta = const VerificationMeta(
    'observationId',
  );
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
    'observation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_observations (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    observationId,
    label,
    confidence,
    trackId,
    x,
    y,
    width,
    height,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_observation_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalObservationItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('observation_id')) {
      context.handle(
        _observationIdMeta,
        observationId.isAcceptableOrUnknown(
          data['observation_id']!,
          _observationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalObservationItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalObservationItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      observationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      ),
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
    );
  }

  @override
  $LocalObservationItemsTable createAlias(String alias) {
    return $LocalObservationItemsTable(attachedDatabase, alias);
  }
}

class LocalObservationItem extends DataClass
    implements Insertable<LocalObservationItem> {
  /// UUID v4 unique de cet item de détection.
  final String id;

  /// Clé étrangère vers [LocalObservations.id].
  final String observationId;

  /// Nom de l'espèce détectée (ex: "pélican blanc").
  final String label;

  /// Score de confiance du modèle IA, entre 0.0 et 1.0.
  final double confidence;

  /// Identifiant de suivi inter-frames (tracking). Nullable si pas de suivi.
  final String? trackId;

  /// Coordonnée X du coin supérieur gauche de la bounding box (normalisée).
  final double x;

  /// Coordonnée Y du coin supérieur gauche de la bounding box (normalisée).
  final double y;

  /// Largeur de la bounding box (normalisée).
  final double width;

  /// Hauteur de la bounding box (normalisée).
  final double height;
  const LocalObservationItem({
    required this.id,
    required this.observationId,
    required this.label,
    required this.confidence,
    this.trackId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['observation_id'] = Variable<String>(observationId);
    map['label'] = Variable<String>(label);
    map['confidence'] = Variable<double>(confidence);
    if (!nullToAbsent || trackId != null) {
      map['track_id'] = Variable<String>(trackId);
    }
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    return map;
  }

  LocalObservationItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalObservationItemsCompanion(
      id: Value(id),
      observationId: Value(observationId),
      label: Value(label),
      confidence: Value(confidence),
      trackId: trackId == null && nullToAbsent
          ? const Value.absent()
          : Value(trackId),
      x: Value(x),
      y: Value(y),
      width: Value(width),
      height: Value(height),
    );
  }

  factory LocalObservationItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalObservationItem(
      id: serializer.fromJson<String>(json['id']),
      observationId: serializer.fromJson<String>(json['observationId']),
      label: serializer.fromJson<String>(json['label']),
      confidence: serializer.fromJson<double>(json['confidence']),
      trackId: serializer.fromJson<String?>(json['trackId']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'observationId': serializer.toJson<String>(observationId),
      'label': serializer.toJson<String>(label),
      'confidence': serializer.toJson<double>(confidence),
      'trackId': serializer.toJson<String?>(trackId),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
    };
  }

  LocalObservationItem copyWith({
    String? id,
    String? observationId,
    String? label,
    double? confidence,
    Value<String?> trackId = const Value.absent(),
    double? x,
    double? y,
    double? width,
    double? height,
  }) => LocalObservationItem(
    id: id ?? this.id,
    observationId: observationId ?? this.observationId,
    label: label ?? this.label,
    confidence: confidence ?? this.confidence,
    trackId: trackId.present ? trackId.value : this.trackId,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
  );
  LocalObservationItem copyWithCompanion(LocalObservationItemsCompanion data) {
    return LocalObservationItem(
      id: data.id.present ? data.id.value : this.id,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      label: data.label.present ? data.label.value : this.label,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalObservationItem(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('label: $label, ')
          ..write('confidence: $confidence, ')
          ..write('trackId: $trackId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    observationId,
    label,
    confidence,
    trackId,
    x,
    y,
    width,
    height,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalObservationItem &&
          other.id == this.id &&
          other.observationId == this.observationId &&
          other.label == this.label &&
          other.confidence == this.confidence &&
          other.trackId == this.trackId &&
          other.x == this.x &&
          other.y == this.y &&
          other.width == this.width &&
          other.height == this.height);
}

class LocalObservationItemsCompanion
    extends UpdateCompanion<LocalObservationItem> {
  final Value<String> id;
  final Value<String> observationId;
  final Value<String> label;
  final Value<double> confidence;
  final Value<String?> trackId;
  final Value<double> x;
  final Value<double> y;
  final Value<double> width;
  final Value<double> height;
  final Value<int> rowid;
  const LocalObservationItemsCompanion({
    this.id = const Value.absent(),
    this.observationId = const Value.absent(),
    this.label = const Value.absent(),
    this.confidence = const Value.absent(),
    this.trackId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalObservationItemsCompanion.insert({
    required String id,
    required String observationId,
    required String label,
    required double confidence,
    this.trackId = const Value.absent(),
    required double x,
    required double y,
    required double width,
    required double height,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       observationId = Value(observationId),
       label = Value(label),
       confidence = Value(confidence),
       x = Value(x),
       y = Value(y),
       width = Value(width),
       height = Value(height);
  static Insertable<LocalObservationItem> custom({
    Expression<String>? id,
    Expression<String>? observationId,
    Expression<String>? label,
    Expression<double>? confidence,
    Expression<String>? trackId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? width,
    Expression<double>? height,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (observationId != null) 'observation_id': observationId,
      if (label != null) 'label': label,
      if (confidence != null) 'confidence': confidence,
      if (trackId != null) 'track_id': trackId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalObservationItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? observationId,
    Value<String>? label,
    Value<double>? confidence,
    Value<String?>? trackId,
    Value<double>? x,
    Value<double>? y,
    Value<double>? width,
    Value<double>? height,
    Value<int>? rowid,
  }) {
    return LocalObservationItemsCompanion(
      id: id ?? this.id,
      observationId: observationId ?? this.observationId,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      trackId: trackId ?? this.trackId,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalObservationItemsCompanion(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('label: $label, ')
          ..write('confidence: $confidence, ')
          ..write('trackId: $trackId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalImpactScoresTable extends LocalImpactScores
    with TableInfo<$LocalImpactScoresTable, LocalImpactScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalImpactScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observationIdMeta = const VerificationMeta(
    'observationId',
  );
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
    'observation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_observations (id)',
    ),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculationVersionMeta =
      const VerificationMeta('calculationVersion');
  @override
  late final GeneratedColumn<String> calculationVersion =
      GeneratedColumn<String>(
        'calculation_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<DateTime> computedAt = GeneratedColumn<DateTime>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _componentsJsonMeta = const VerificationMeta(
    'componentsJson',
  );
  @override
  late final GeneratedColumn<String> componentsJson = GeneratedColumn<String>(
    'components_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    observationId,
    score,
    level,
    calculationVersion,
    computedAt,
    componentsJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_impact_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalImpactScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('observation_id')) {
      context.handle(
        _observationIdMeta,
        observationId.isAcceptableOrUnknown(
          data['observation_id']!,
          _observationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('calculation_version')) {
      context.handle(
        _calculationVersionMeta,
        calculationVersion.isAcceptableOrUnknown(
          data['calculation_version']!,
          _calculationVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculationVersionMeta);
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    if (data.containsKey('components_json')) {
      context.handle(
        _componentsJsonMeta,
        componentsJson.isAcceptableOrUnknown(
          data['components_json']!,
          _componentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalImpactScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalImpactScore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      observationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      calculationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculation_version'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}computed_at'],
      )!,
      componentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}components_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalImpactScoresTable createAlias(String alias) {
    return $LocalImpactScoresTable(attachedDatabase, alias);
  }
}

class LocalImpactScore extends DataClass
    implements Insertable<LocalImpactScore> {
  final String id;
  final String observationId;
  final double score;
  final String level;
  final String calculationVersion;
  final DateTime computedAt;
  final String? componentsJson;
  final DateTime updatedAt;
  const LocalImpactScore({
    required this.id,
    required this.observationId,
    required this.score,
    required this.level,
    required this.calculationVersion,
    required this.computedAt,
    this.componentsJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['observation_id'] = Variable<String>(observationId);
    map['score'] = Variable<double>(score);
    map['level'] = Variable<String>(level);
    map['calculation_version'] = Variable<String>(calculationVersion);
    map['computed_at'] = Variable<DateTime>(computedAt);
    if (!nullToAbsent || componentsJson != null) {
      map['components_json'] = Variable<String>(componentsJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalImpactScoresCompanion toCompanion(bool nullToAbsent) {
    return LocalImpactScoresCompanion(
      id: Value(id),
      observationId: Value(observationId),
      score: Value(score),
      level: Value(level),
      calculationVersion: Value(calculationVersion),
      computedAt: Value(computedAt),
      componentsJson: componentsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(componentsJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalImpactScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalImpactScore(
      id: serializer.fromJson<String>(json['id']),
      observationId: serializer.fromJson<String>(json['observationId']),
      score: serializer.fromJson<double>(json['score']),
      level: serializer.fromJson<String>(json['level']),
      calculationVersion: serializer.fromJson<String>(
        json['calculationVersion'],
      ),
      computedAt: serializer.fromJson<DateTime>(json['computedAt']),
      componentsJson: serializer.fromJson<String?>(json['componentsJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'observationId': serializer.toJson<String>(observationId),
      'score': serializer.toJson<double>(score),
      'level': serializer.toJson<String>(level),
      'calculationVersion': serializer.toJson<String>(calculationVersion),
      'computedAt': serializer.toJson<DateTime>(computedAt),
      'componentsJson': serializer.toJson<String?>(componentsJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalImpactScore copyWith({
    String? id,
    String? observationId,
    double? score,
    String? level,
    String? calculationVersion,
    DateTime? computedAt,
    Value<String?> componentsJson = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalImpactScore(
    id: id ?? this.id,
    observationId: observationId ?? this.observationId,
    score: score ?? this.score,
    level: level ?? this.level,
    calculationVersion: calculationVersion ?? this.calculationVersion,
    computedAt: computedAt ?? this.computedAt,
    componentsJson: componentsJson.present
        ? componentsJson.value
        : this.componentsJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalImpactScore copyWithCompanion(LocalImpactScoresCompanion data) {
    return LocalImpactScore(
      id: data.id.present ? data.id.value : this.id,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      score: data.score.present ? data.score.value : this.score,
      level: data.level.present ? data.level.value : this.level,
      calculationVersion: data.calculationVersion.present
          ? data.calculationVersion.value
          : this.calculationVersion,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
      componentsJson: data.componentsJson.present
          ? data.componentsJson.value
          : this.componentsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalImpactScore(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('score: $score, ')
          ..write('level: $level, ')
          ..write('calculationVersion: $calculationVersion, ')
          ..write('computedAt: $computedAt, ')
          ..write('componentsJson: $componentsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    observationId,
    score,
    level,
    calculationVersion,
    computedAt,
    componentsJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalImpactScore &&
          other.id == this.id &&
          other.observationId == this.observationId &&
          other.score == this.score &&
          other.level == this.level &&
          other.calculationVersion == this.calculationVersion &&
          other.computedAt == this.computedAt &&
          other.componentsJson == this.componentsJson &&
          other.updatedAt == this.updatedAt);
}

class LocalImpactScoresCompanion extends UpdateCompanion<LocalImpactScore> {
  final Value<String> id;
  final Value<String> observationId;
  final Value<double> score;
  final Value<String> level;
  final Value<String> calculationVersion;
  final Value<DateTime> computedAt;
  final Value<String?> componentsJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalImpactScoresCompanion({
    this.id = const Value.absent(),
    this.observationId = const Value.absent(),
    this.score = const Value.absent(),
    this.level = const Value.absent(),
    this.calculationVersion = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.componentsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalImpactScoresCompanion.insert({
    required String id,
    required String observationId,
    required double score,
    required String level,
    required String calculationVersion,
    required DateTime computedAt,
    this.componentsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       observationId = Value(observationId),
       score = Value(score),
       level = Value(level),
       calculationVersion = Value(calculationVersion),
       computedAt = Value(computedAt);
  static Insertable<LocalImpactScore> custom({
    Expression<String>? id,
    Expression<String>? observationId,
    Expression<double>? score,
    Expression<String>? level,
    Expression<String>? calculationVersion,
    Expression<DateTime>? computedAt,
    Expression<String>? componentsJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (observationId != null) 'observation_id': observationId,
      if (score != null) 'score': score,
      if (level != null) 'level': level,
      if (calculationVersion != null) 'calculation_version': calculationVersion,
      if (computedAt != null) 'computed_at': computedAt,
      if (componentsJson != null) 'components_json': componentsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalImpactScoresCompanion copyWith({
    Value<String>? id,
    Value<String>? observationId,
    Value<double>? score,
    Value<String>? level,
    Value<String>? calculationVersion,
    Value<DateTime>? computedAt,
    Value<String?>? componentsJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalImpactScoresCompanion(
      id: id ?? this.id,
      observationId: observationId ?? this.observationId,
      score: score ?? this.score,
      level: level ?? this.level,
      calculationVersion: calculationVersion ?? this.calculationVersion,
      computedAt: computedAt ?? this.computedAt,
      componentsJson: componentsJson ?? this.componentsJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (calculationVersion.present) {
      map['calculation_version'] = Variable<String>(calculationVersion.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<DateTime>(computedAt.value);
    }
    if (componentsJson.present) {
      map['components_json'] = Variable<String>(componentsJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalImpactScoresCompanion(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('score: $score, ')
          ..write('level: $level, ')
          ..write('calculationVersion: $calculationVersion, ')
          ..write('computedAt: $computedAt, ')
          ..write('componentsJson: $componentsJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalObservationsTable localObservations =
      $LocalObservationsTable(this);
  late final $LocalObservationItemsTable localObservationItems =
      $LocalObservationItemsTable(this);
  late final $LocalImpactScoresTable localImpactScores =
      $LocalImpactScoresTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localObservations,
    localObservationItems,
    localImpactScores,
  ];
}

typedef $$LocalObservationsTableCreateCompanionBuilder =
    LocalObservationsCompanion Function({
      required String id,
      required String userId,
      required DateTime createdAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> localPhotoPath,
      Value<String?> localVideoPath,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastSyncError,
      Value<String?> serverId,
      Value<int> rowid,
    });
typedef $$LocalObservationsTableUpdateCompanionBuilder =
    LocalObservationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> localPhotoPath,
      Value<String?> localVideoPath,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastSyncError,
      Value<String?> serverId,
      Value<int> rowid,
    });

final class $$LocalObservationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalObservationsTable,
          LocalObservation
        > {
  $$LocalObservationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $LocalObservationItemsTable,
    List<LocalObservationItem>
  >
  _localObservationItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localObservationItems,
        aliasName:
            'local_observations__id__local_observation_items__observation_id',
      );

  $$LocalObservationItemsTableProcessedTableManager
  get localObservationItemsRefs {
    final manager = $$LocalObservationItemsTableTableManager(
      $_db,
      $_db.localObservationItems,
    ).filter((f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localObservationItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LocalImpactScoresTable, List<LocalImpactScore>>
  _localImpactScoresRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localImpactScores,
        aliasName:
            'local_observations__id__local_impact_scores__observation_id',
      );

  $$LocalImpactScoresTableProcessedTableManager get localImpactScoresRefs {
    final manager = $$LocalImpactScoresTableTableManager(
      $_db,
      $_db.localImpactScores,
    ).filter((f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localImpactScoresRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalObservationsTable> {
  $$LocalObservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localObservationItemsRefs(
    Expression<bool> Function($$LocalObservationItemsTableFilterComposer f) f,
  ) {
    final $$LocalObservationItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localObservationItems,
          getReferencedColumn: (t) => t.observationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalObservationItemsTableFilterComposer(
                $db: $db,
                $table: $db.localObservationItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> localImpactScoresRefs(
    Expression<bool> Function($$LocalImpactScoresTableFilterComposer f) f,
  ) {
    final $$LocalImpactScoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localImpactScores,
      getReferencedColumn: (t) => t.observationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalImpactScoresTableFilterComposer(
            $db: $db,
            $table: $db.localImpactScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalObservationsTable> {
  $$LocalObservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalObservationsTable> {
  $$LocalObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localVideoPath => $composableBuilder(
    column: $table.localVideoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  Expression<T> localObservationItemsRefs<T extends Object>(
    Expression<T> Function($$LocalObservationItemsTableAnnotationComposer a) f,
  ) {
    final $$LocalObservationItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localObservationItems,
          getReferencedColumn: (t) => t.observationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalObservationItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.localObservationItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localImpactScoresRefs<T extends Object>(
    Expression<T> Function($$LocalImpactScoresTableAnnotationComposer a) f,
  ) {
    final $$LocalImpactScoresTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localImpactScores,
          getReferencedColumn: (t) => t.observationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalImpactScoresTableAnnotationComposer(
                $db: $db,
                $table: $db.localImpactScores,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalObservationsTable,
          LocalObservation,
          $$LocalObservationsTableFilterComposer,
          $$LocalObservationsTableOrderingComposer,
          $$LocalObservationsTableAnnotationComposer,
          $$LocalObservationsTableCreateCompanionBuilder,
          $$LocalObservationsTableUpdateCompanionBuilder,
          (LocalObservation, $$LocalObservationsTableReferences),
          LocalObservation,
          PrefetchHooks Function({
            bool localObservationItemsRefs,
            bool localImpactScoresRefs,
          })
        > {
  $$LocalObservationsTableTableManager(
    _$AppDatabase db,
    $LocalObservationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalObservationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> localPhotoPath = const Value.absent(),
                Value<String?> localVideoPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalObservationsCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                latitude: latitude,
                longitude: longitude,
                localPhotoPath: localPhotoPath,
                localVideoPath: localVideoPath,
                status: status,
                retryCount: retryCount,
                lastSyncError: lastSyncError,
                serverId: serverId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime createdAt,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> localPhotoPath = const Value.absent(),
                Value<String?> localVideoPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalObservationsCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                latitude: latitude,
                longitude: longitude,
                localPhotoPath: localPhotoPath,
                localVideoPath: localVideoPath,
                status: status,
                retryCount: retryCount,
                lastSyncError: lastSyncError,
                serverId: serverId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalObservationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                localObservationItemsRefs = false,
                localImpactScoresRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localObservationItemsRefs) db.localObservationItems,
                    if (localImpactScoresRefs) db.localImpactScores,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localObservationItemsRefs)
                        await $_getPrefetchedData<
                          LocalObservation,
                          $LocalObservationsTable,
                          LocalObservationItem
                        >(
                          currentTable: table,
                          referencedTable: $$LocalObservationsTableReferences
                              ._localObservationItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalObservationsTableReferences(
                                db,
                                table,
                                p0,
                              ).localObservationItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.observationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localImpactScoresRefs)
                        await $_getPrefetchedData<
                          LocalObservation,
                          $LocalObservationsTable,
                          LocalImpactScore
                        >(
                          currentTable: table,
                          referencedTable: $$LocalObservationsTableReferences
                              ._localImpactScoresRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalObservationsTableReferences(
                                db,
                                table,
                                p0,
                              ).localImpactScoresRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.observationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalObservationsTable,
      LocalObservation,
      $$LocalObservationsTableFilterComposer,
      $$LocalObservationsTableOrderingComposer,
      $$LocalObservationsTableAnnotationComposer,
      $$LocalObservationsTableCreateCompanionBuilder,
      $$LocalObservationsTableUpdateCompanionBuilder,
      (LocalObservation, $$LocalObservationsTableReferences),
      LocalObservation,
      PrefetchHooks Function({
        bool localObservationItemsRefs,
        bool localImpactScoresRefs,
      })
    >;
typedef $$LocalObservationItemsTableCreateCompanionBuilder =
    LocalObservationItemsCompanion Function({
      required String id,
      required String observationId,
      required String label,
      required double confidence,
      Value<String?> trackId,
      required double x,
      required double y,
      required double width,
      required double height,
      Value<int> rowid,
    });
typedef $$LocalObservationItemsTableUpdateCompanionBuilder =
    LocalObservationItemsCompanion Function({
      Value<String> id,
      Value<String> observationId,
      Value<String> label,
      Value<double> confidence,
      Value<String?> trackId,
      Value<double> x,
      Value<double> y,
      Value<double> width,
      Value<double> height,
      Value<int> rowid,
    });

final class $$LocalObservationItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalObservationItemsTable,
          LocalObservationItem
        > {
  $$LocalObservationItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalObservationsTable _observationIdTable(_$AppDatabase db) =>
      db.localObservations.createAlias(
        'local_observation_items__observation_id__local_observations__id',
      );

  $$LocalObservationsTableProcessedTableManager get observationId {
    final $_column = $_itemColumn<String>('observation_id')!;

    final manager = $$LocalObservationsTableTableManager(
      $_db,
      $_db.localObservations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalObservationItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalObservationItemsTable> {
  $$LocalObservationItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalObservationsTableFilterComposer get observationId {
    final $$LocalObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.localObservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalObservationsTableFilterComposer(
            $db: $db,
            $table: $db.localObservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalObservationItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalObservationItemsTable> {
  $$LocalObservationItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalObservationsTableOrderingComposer get observationId {
    final $$LocalObservationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.localObservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalObservationsTableOrderingComposer(
            $db: $db,
            $table: $db.localObservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalObservationItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalObservationItemsTable> {
  $$LocalObservationItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  $$LocalObservationsTableAnnotationComposer get observationId {
    final $$LocalObservationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.observationId,
          referencedTable: $db.localObservations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalObservationsTableAnnotationComposer(
                $db: $db,
                $table: $db.localObservations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalObservationItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalObservationItemsTable,
          LocalObservationItem,
          $$LocalObservationItemsTableFilterComposer,
          $$LocalObservationItemsTableOrderingComposer,
          $$LocalObservationItemsTableAnnotationComposer,
          $$LocalObservationItemsTableCreateCompanionBuilder,
          $$LocalObservationItemsTableUpdateCompanionBuilder,
          (LocalObservationItem, $$LocalObservationItemsTableReferences),
          LocalObservationItem,
          PrefetchHooks Function({bool observationId})
        > {
  $$LocalObservationItemsTableTableManager(
    _$AppDatabase db,
    $LocalObservationItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalObservationItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalObservationItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalObservationItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> observationId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String?> trackId = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalObservationItemsCompanion(
                id: id,
                observationId: observationId,
                label: label,
                confidence: confidence,
                trackId: trackId,
                x: x,
                y: y,
                width: width,
                height: height,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String observationId,
                required String label,
                required double confidence,
                Value<String?> trackId = const Value.absent(),
                required double x,
                required double y,
                required double width,
                required double height,
                Value<int> rowid = const Value.absent(),
              }) => LocalObservationItemsCompanion.insert(
                id: id,
                observationId: observationId,
                label: label,
                confidence: confidence,
                trackId: trackId,
                x: x,
                y: y,
                width: width,
                height: height,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalObservationItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({observationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (observationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.observationId,
                                referencedTable:
                                    $$LocalObservationItemsTableReferences
                                        ._observationIdTable(db),
                                referencedColumn:
                                    $$LocalObservationItemsTableReferences
                                        ._observationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalObservationItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalObservationItemsTable,
      LocalObservationItem,
      $$LocalObservationItemsTableFilterComposer,
      $$LocalObservationItemsTableOrderingComposer,
      $$LocalObservationItemsTableAnnotationComposer,
      $$LocalObservationItemsTableCreateCompanionBuilder,
      $$LocalObservationItemsTableUpdateCompanionBuilder,
      (LocalObservationItem, $$LocalObservationItemsTableReferences),
      LocalObservationItem,
      PrefetchHooks Function({bool observationId})
    >;
typedef $$LocalImpactScoresTableCreateCompanionBuilder =
    LocalImpactScoresCompanion Function({
      required String id,
      required String observationId,
      required double score,
      required String level,
      required String calculationVersion,
      required DateTime computedAt,
      Value<String?> componentsJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalImpactScoresTableUpdateCompanionBuilder =
    LocalImpactScoresCompanion Function({
      Value<String> id,
      Value<String> observationId,
      Value<double> score,
      Value<String> level,
      Value<String> calculationVersion,
      Value<DateTime> computedAt,
      Value<String?> componentsJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LocalImpactScoresTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalImpactScoresTable,
          LocalImpactScore
        > {
  $$LocalImpactScoresTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalObservationsTable _observationIdTable(_$AppDatabase db) =>
      db.localObservations.createAlias(
        'local_impact_scores__observation_id__local_observations__id',
      );

  $$LocalObservationsTableProcessedTableManager get observationId {
    final $_column = $_itemColumn<String>('observation_id')!;

    final manager = $$LocalObservationsTableTableManager(
      $_db,
      $_db.localObservations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalImpactScoresTableFilterComposer
    extends Composer<_$AppDatabase, $LocalImpactScoresTable> {
  $$LocalImpactScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentsJson => $composableBuilder(
    column: $table.componentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalObservationsTableFilterComposer get observationId {
    final $$LocalObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.localObservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalObservationsTableFilterComposer(
            $db: $db,
            $table: $db.localObservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalImpactScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalImpactScoresTable> {
  $$LocalImpactScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentsJson => $composableBuilder(
    column: $table.componentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalObservationsTableOrderingComposer get observationId {
    final $$LocalObservationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.localObservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalObservationsTableOrderingComposer(
            $db: $db,
            $table: $db.localObservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalImpactScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalImpactScoresTable> {
  $$LocalImpactScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get componentsJson => $composableBuilder(
    column: $table.componentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LocalObservationsTableAnnotationComposer get observationId {
    final $$LocalObservationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.observationId,
          referencedTable: $db.localObservations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalObservationsTableAnnotationComposer(
                $db: $db,
                $table: $db.localObservations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalImpactScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalImpactScoresTable,
          LocalImpactScore,
          $$LocalImpactScoresTableFilterComposer,
          $$LocalImpactScoresTableOrderingComposer,
          $$LocalImpactScoresTableAnnotationComposer,
          $$LocalImpactScoresTableCreateCompanionBuilder,
          $$LocalImpactScoresTableUpdateCompanionBuilder,
          (LocalImpactScore, $$LocalImpactScoresTableReferences),
          LocalImpactScore,
          PrefetchHooks Function({bool observationId})
        > {
  $$LocalImpactScoresTableTableManager(
    _$AppDatabase db,
    $LocalImpactScoresTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalImpactScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalImpactScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalImpactScoresTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> observationId = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> calculationVersion = const Value.absent(),
                Value<DateTime> computedAt = const Value.absent(),
                Value<String?> componentsJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalImpactScoresCompanion(
                id: id,
                observationId: observationId,
                score: score,
                level: level,
                calculationVersion: calculationVersion,
                computedAt: computedAt,
                componentsJson: componentsJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String observationId,
                required double score,
                required String level,
                required String calculationVersion,
                required DateTime computedAt,
                Value<String?> componentsJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalImpactScoresCompanion.insert(
                id: id,
                observationId: observationId,
                score: score,
                level: level,
                calculationVersion: calculationVersion,
                computedAt: computedAt,
                componentsJson: componentsJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalImpactScoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({observationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (observationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.observationId,
                                referencedTable:
                                    $$LocalImpactScoresTableReferences
                                        ._observationIdTable(db),
                                referencedColumn:
                                    $$LocalImpactScoresTableReferences
                                        ._observationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalImpactScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalImpactScoresTable,
      LocalImpactScore,
      $$LocalImpactScoresTableFilterComposer,
      $$LocalImpactScoresTableOrderingComposer,
      $$LocalImpactScoresTableAnnotationComposer,
      $$LocalImpactScoresTableCreateCompanionBuilder,
      $$LocalImpactScoresTableUpdateCompanionBuilder,
      (LocalImpactScore, $$LocalImpactScoresTableReferences),
      LocalImpactScore,
      PrefetchHooks Function({bool observationId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalObservationsTableTableManager get localObservations =>
      $$LocalObservationsTableTableManager(_db, _db.localObservations);
  $$LocalObservationItemsTableTableManager get localObservationItems =>
      $$LocalObservationItemsTableTableManager(_db, _db.localObservationItems);
  $$LocalImpactScoresTableTableManager get localImpactScores =>
      $$LocalImpactScoresTableTableManager(_db, _db.localImpactScores);
}
