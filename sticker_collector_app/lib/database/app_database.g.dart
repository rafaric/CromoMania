// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, Album> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalStickersMeta = const VerificationMeta(
    'totalStickers',
  );
  @override
  late final GeneratedColumn<int> totalStickers = GeneratedColumn<int>(
    'total_stickers',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    publisher,
    description,
    totalStickers,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<Album> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('total_stickers')) {
      context.handle(
        _totalStickersMeta,
        totalStickers.isAcceptableOrUnknown(
          data['total_stickers']!,
          _totalStickersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalStickersMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Album map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Album(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      totalStickers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_stickers'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class Album extends DataClass implements Insertable<Album> {
  final int id;
  final String name;
  final String? publisher;
  final String? description;
  final int totalStickers;
  final DateTime createdAt;
  const Album({
    required this.id,
    required this.name,
    this.publisher,
    this.description,
    required this.totalStickers,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['total_stickers'] = Variable<int>(totalStickers);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      name: Value(name),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      totalStickers: Value(totalStickers),
      createdAt: Value(createdAt),
    );
  }

  factory Album.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Album(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      description: serializer.fromJson<String?>(json['description']),
      totalStickers: serializer.fromJson<int>(json['totalStickers']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'publisher': serializer.toJson<String?>(publisher),
      'description': serializer.toJson<String?>(description),
      'totalStickers': serializer.toJson<int>(totalStickers),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Album copyWith({
    int? id,
    String? name,
    Value<String?> publisher = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? totalStickers,
    DateTime? createdAt,
  }) => Album(
    id: id ?? this.id,
    name: name ?? this.name,
    publisher: publisher.present ? publisher.value : this.publisher,
    description: description.present ? description.value : this.description,
    totalStickers: totalStickers ?? this.totalStickers,
    createdAt: createdAt ?? this.createdAt,
  );
  Album copyWithCompanion(AlbumsCompanion data) {
    return Album(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      description: data.description.present
          ? data.description.value
          : this.description,
      totalStickers: data.totalStickers.present
          ? data.totalStickers.value
          : this.totalStickers,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Album(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('publisher: $publisher, ')
          ..write('description: $description, ')
          ..write('totalStickers: $totalStickers, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, publisher, description, totalStickers, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Album &&
          other.id == this.id &&
          other.name == this.name &&
          other.publisher == this.publisher &&
          other.description == this.description &&
          other.totalStickers == this.totalStickers &&
          other.createdAt == this.createdAt);
}

class AlbumsCompanion extends UpdateCompanion<Album> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> publisher;
  final Value<String?> description;
  final Value<int> totalStickers;
  final Value<DateTime> createdAt;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.publisher = const Value.absent(),
    this.description = const Value.absent(),
    this.totalStickers = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AlbumsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.publisher = const Value.absent(),
    this.description = const Value.absent(),
    required int totalStickers,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       totalStickers = Value(totalStickers);
  static Insertable<Album> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? publisher,
    Expression<String>? description,
    Expression<int>? totalStickers,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (publisher != null) 'publisher': publisher,
      if (description != null) 'description': description,
      if (totalStickers != null) 'total_stickers': totalStickers,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AlbumsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? publisher,
    Value<String?>? description,
    Value<int>? totalStickers,
    Value<DateTime>? createdAt,
  }) {
    return AlbumsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      totalStickers: totalStickers ?? this.totalStickers,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (totalStickers.present) {
      map['total_stickers'] = Variable<int>(totalStickers.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('publisher: $publisher, ')
          ..write('description: $description, ')
          ..write('totalStickers: $totalStickers, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<int> albumId = GeneratedColumn<int>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, albumId, name, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final int id;
  final int albumId;
  final String name;
  final int orderIndex;
  const Section({
    required this.id,
    required this.albumId,
    required this.name,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['album_id'] = Variable<int>(albumId);
    map['name'] = Variable<String>(name);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      albumId: Value(albumId),
      name: Value(name),
      orderIndex: Value(orderIndex),
    );
  }

  factory Section.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<int>(json['id']),
      albumId: serializer.fromJson<int>(json['albumId']),
      name: serializer.fromJson<String>(json['name']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'albumId': serializer.toJson<int>(albumId),
      'name': serializer.toJson<String>(name),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Section copyWith({int? id, int? albumId, String? name, int? orderIndex}) =>
      Section(
        id: id ?? this.id,
        albumId: albumId ?? this.albumId,
        name: name ?? this.name,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  Section copyWithCompanion(SectionsCompanion data) {
    return Section(
      id: data.id.present ? data.id.value : this.id,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      name: data.name.present ? data.name.value : this.name,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, albumId, name, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == this.id &&
          other.albumId == this.albumId &&
          other.name == this.name &&
          other.orderIndex == this.orderIndex);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<int> id;
  final Value<int> albumId;
  final Value<String> name;
  final Value<int> orderIndex;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.albumId = const Value.absent(),
    this.name = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  SectionsCompanion.insert({
    this.id = const Value.absent(),
    required int albumId,
    required String name,
    required int orderIndex,
  }) : albumId = Value(albumId),
       name = Value(name),
       orderIndex = Value(orderIndex);
  static Insertable<Section> custom({
    Expression<int>? id,
    Expression<int>? albumId,
    Expression<String>? name,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (albumId != null) 'album_id': albumId,
      if (name != null) 'name': name,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  SectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? albumId,
    Value<String>? name,
    Value<int>? orderIndex,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<int>(albumId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('albumId: $albumId, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $StickersTable extends Stickers with TableInfo<$StickersTable, Sticker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StickersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stickerNumberMeta = const VerificationMeta(
    'stickerNumber',
  );
  @override
  late final GeneratedColumn<String> stickerNumber = GeneratedColumn<String>(
    'sticker_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSpecialMeta = const VerificationMeta(
    'isSpecial',
  );
  @override
  late final GeneratedColumn<bool> isSpecial = GeneratedColumn<bool>(
    'is_special',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_special" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sectionId,
    stickerNumber,
    name,
    isSpecial,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stickers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sticker> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('sticker_number')) {
      context.handle(
        _stickerNumberMeta,
        stickerNumber.isAcceptableOrUnknown(
          data['sticker_number']!,
          _stickerNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stickerNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_special')) {
      context.handle(
        _isSpecialMeta,
        isSpecial.isAcceptableOrUnknown(data['is_special']!, _isSpecialMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sticker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sticker(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
      stickerNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sticker_number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isSpecial: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_special'],
      )!,
    );
  }

  @override
  $StickersTable createAlias(String alias) {
    return $StickersTable(attachedDatabase, alias);
  }
}

class Sticker extends DataClass implements Insertable<Sticker> {
  final int id;
  final int sectionId;
  final String stickerNumber;
  final String name;
  final bool isSpecial;
  const Sticker({
    required this.id,
    required this.sectionId,
    required this.stickerNumber,
    required this.name,
    required this.isSpecial,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['section_id'] = Variable<int>(sectionId);
    map['sticker_number'] = Variable<String>(stickerNumber);
    map['name'] = Variable<String>(name);
    map['is_special'] = Variable<bool>(isSpecial);
    return map;
  }

  StickersCompanion toCompanion(bool nullToAbsent) {
    return StickersCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      stickerNumber: Value(stickerNumber),
      name: Value(name),
      isSpecial: Value(isSpecial),
    );
  }

  factory Sticker.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sticker(
      id: serializer.fromJson<int>(json['id']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
      stickerNumber: serializer.fromJson<String>(json['stickerNumber']),
      name: serializer.fromJson<String>(json['name']),
      isSpecial: serializer.fromJson<bool>(json['isSpecial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sectionId': serializer.toJson<int>(sectionId),
      'stickerNumber': serializer.toJson<String>(stickerNumber),
      'name': serializer.toJson<String>(name),
      'isSpecial': serializer.toJson<bool>(isSpecial),
    };
  }

  Sticker copyWith({
    int? id,
    int? sectionId,
    String? stickerNumber,
    String? name,
    bool? isSpecial,
  }) => Sticker(
    id: id ?? this.id,
    sectionId: sectionId ?? this.sectionId,
    stickerNumber: stickerNumber ?? this.stickerNumber,
    name: name ?? this.name,
    isSpecial: isSpecial ?? this.isSpecial,
  );
  Sticker copyWithCompanion(StickersCompanion data) {
    return Sticker(
      id: data.id.present ? data.id.value : this.id,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      stickerNumber: data.stickerNumber.present
          ? data.stickerNumber.value
          : this.stickerNumber,
      name: data.name.present ? data.name.value : this.name,
      isSpecial: data.isSpecial.present ? data.isSpecial.value : this.isSpecial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sticker(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('stickerNumber: $stickerNumber, ')
          ..write('name: $name, ')
          ..write('isSpecial: $isSpecial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sectionId, stickerNumber, name, isSpecial);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sticker &&
          other.id == this.id &&
          other.sectionId == this.sectionId &&
          other.stickerNumber == this.stickerNumber &&
          other.name == this.name &&
          other.isSpecial == this.isSpecial);
}

class StickersCompanion extends UpdateCompanion<Sticker> {
  final Value<int> id;
  final Value<int> sectionId;
  final Value<String> stickerNumber;
  final Value<String> name;
  final Value<bool> isSpecial;
  const StickersCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.stickerNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.isSpecial = const Value.absent(),
  });
  StickersCompanion.insert({
    this.id = const Value.absent(),
    required int sectionId,
    required String stickerNumber,
    required String name,
    this.isSpecial = const Value.absent(),
  }) : sectionId = Value(sectionId),
       stickerNumber = Value(stickerNumber),
       name = Value(name);
  static Insertable<Sticker> custom({
    Expression<int>? id,
    Expression<int>? sectionId,
    Expression<String>? stickerNumber,
    Expression<String>? name,
    Expression<bool>? isSpecial,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (stickerNumber != null) 'sticker_number': stickerNumber,
      if (name != null) 'name': name,
      if (isSpecial != null) 'is_special': isSpecial,
    });
  }

  StickersCompanion copyWith({
    Value<int>? id,
    Value<int>? sectionId,
    Value<String>? stickerNumber,
    Value<String>? name,
    Value<bool>? isSpecial,
  }) {
    return StickersCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      stickerNumber: stickerNumber ?? this.stickerNumber,
      name: name ?? this.name,
      isSpecial: isSpecial ?? this.isSpecial,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (stickerNumber.present) {
      map['sticker_number'] = Variable<String>(stickerNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isSpecial.present) {
      map['is_special'] = Variable<bool>(isSpecial.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StickersCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('stickerNumber: $stickerNumber, ')
          ..write('name: $name, ')
          ..write('isSpecial: $isSpecial')
          ..write(')'))
        .toString();
  }
}

class $CollectionStatusesTable extends CollectionStatuses
    with TableInfo<$CollectionStatusesTable, CollectionStatuse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _stickerIdMeta = const VerificationMeta(
    'stickerId',
  );
  @override
  late final GeneratedColumn<int> stickerId = GeneratedColumn<int>(
    'sticker_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default_user'),
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, stickerId, userId, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionStatuse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sticker_id')) {
      context.handle(
        _stickerIdMeta,
        stickerId.isAcceptableOrUnknown(data['sticker_id']!, _stickerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stickerIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {stickerId, userId},
  ];
  @override
  CollectionStatuse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionStatuse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stickerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sticker_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $CollectionStatusesTable createAlias(String alias) {
    return $CollectionStatusesTable(attachedDatabase, alias);
  }
}

class CollectionStatuse extends DataClass
    implements Insertable<CollectionStatuse> {
  final int id;
  final int stickerId;
  final String userId;
  final int count;
  const CollectionStatuse({
    required this.id,
    required this.stickerId,
    required this.userId,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sticker_id'] = Variable<int>(stickerId);
    map['user_id'] = Variable<String>(userId);
    map['count'] = Variable<int>(count);
    return map;
  }

  CollectionStatusesCompanion toCompanion(bool nullToAbsent) {
    return CollectionStatusesCompanion(
      id: Value(id),
      stickerId: Value(stickerId),
      userId: Value(userId),
      count: Value(count),
    );
  }

  factory CollectionStatuse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionStatuse(
      id: serializer.fromJson<int>(json['id']),
      stickerId: serializer.fromJson<int>(json['stickerId']),
      userId: serializer.fromJson<String>(json['userId']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stickerId': serializer.toJson<int>(stickerId),
      'userId': serializer.toJson<String>(userId),
      'count': serializer.toJson<int>(count),
    };
  }

  CollectionStatuse copyWith({
    int? id,
    int? stickerId,
    String? userId,
    int? count,
  }) => CollectionStatuse(
    id: id ?? this.id,
    stickerId: stickerId ?? this.stickerId,
    userId: userId ?? this.userId,
    count: count ?? this.count,
  );
  CollectionStatuse copyWithCompanion(CollectionStatusesCompanion data) {
    return CollectionStatuse(
      id: data.id.present ? data.id.value : this.id,
      stickerId: data.stickerId.present ? data.stickerId.value : this.stickerId,
      userId: data.userId.present ? data.userId.value : this.userId,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionStatuse(')
          ..write('id: $id, ')
          ..write('stickerId: $stickerId, ')
          ..write('userId: $userId, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, stickerId, userId, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionStatuse &&
          other.id == this.id &&
          other.stickerId == this.stickerId &&
          other.userId == this.userId &&
          other.count == this.count);
}

class CollectionStatusesCompanion extends UpdateCompanion<CollectionStatuse> {
  final Value<int> id;
  final Value<int> stickerId;
  final Value<String> userId;
  final Value<int> count;
  const CollectionStatusesCompanion({
    this.id = const Value.absent(),
    this.stickerId = const Value.absent(),
    this.userId = const Value.absent(),
    this.count = const Value.absent(),
  });
  CollectionStatusesCompanion.insert({
    this.id = const Value.absent(),
    required int stickerId,
    this.userId = const Value.absent(),
    this.count = const Value.absent(),
  }) : stickerId = Value(stickerId);
  static Insertable<CollectionStatuse> custom({
    Expression<int>? id,
    Expression<int>? stickerId,
    Expression<String>? userId,
    Expression<int>? count,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stickerId != null) 'sticker_id': stickerId,
      if (userId != null) 'user_id': userId,
      if (count != null) 'count': count,
    });
  }

  CollectionStatusesCompanion copyWith({
    Value<int>? id,
    Value<int>? stickerId,
    Value<String>? userId,
    Value<int>? count,
  }) {
    return CollectionStatusesCompanion(
      id: id ?? this.id,
      stickerId: stickerId ?? this.stickerId,
      userId: userId ?? this.userId,
      count: count ?? this.count,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stickerId.present) {
      map['sticker_id'] = Variable<int>(stickerId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionStatusesCompanion(')
          ..write('id: $id, ')
          ..write('stickerId: $stickerId, ')
          ..write('userId: $userId, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $StickersTable stickers = $StickersTable(this);
  late final $CollectionStatusesTable collectionStatuses =
      $CollectionStatusesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    albums,
    sections,
    stickers,
    collectionStatuses,
  ];
}

typedef $$AlbumsTableCreateCompanionBuilder =
    AlbumsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> publisher,
      Value<String?> description,
      required int totalStickers,
      Value<DateTime> createdAt,
    });
typedef $$AlbumsTableUpdateCompanionBuilder =
    AlbumsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> publisher,
      Value<String?> description,
      Value<int> totalStickers,
      Value<DateTime> createdAt,
    });

class $$AlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalStickers => $composableBuilder(
    column: $table.totalStickers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalStickers => $composableBuilder(
    column: $table.totalStickers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalStickers => $composableBuilder(
    column: $table.totalStickers,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumsTable,
          Album,
          $$AlbumsTableFilterComposer,
          $$AlbumsTableOrderingComposer,
          $$AlbumsTableAnnotationComposer,
          $$AlbumsTableCreateCompanionBuilder,
          $$AlbumsTableUpdateCompanionBuilder,
          (Album, BaseReferences<_$AppDatabase, $AlbumsTable, Album>),
          Album,
          PrefetchHooks Function()
        > {
  $$AlbumsTableTableManager(_$AppDatabase db, $AlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> totalStickers = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AlbumsCompanion(
                id: id,
                name: name,
                publisher: publisher,
                description: description,
                totalStickers: totalStickers,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> publisher = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required int totalStickers,
                Value<DateTime> createdAt = const Value.absent(),
              }) => AlbumsCompanion.insert(
                id: id,
                name: name,
                publisher: publisher,
                description: description,
                totalStickers: totalStickers,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumsTable,
      Album,
      $$AlbumsTableFilterComposer,
      $$AlbumsTableOrderingComposer,
      $$AlbumsTableAnnotationComposer,
      $$AlbumsTableCreateCompanionBuilder,
      $$AlbumsTableUpdateCompanionBuilder,
      (Album, BaseReferences<_$AppDatabase, $AlbumsTable, Album>),
      Album,
      PrefetchHooks Function()
    >;
typedef $$SectionsTableCreateCompanionBuilder =
    SectionsCompanion Function({
      Value<int> id,
      required int albumId,
      required String name,
      required int orderIndex,
    });
typedef $$SectionsTableUpdateCompanionBuilder =
    SectionsCompanion Function({
      Value<int> id,
      Value<int> albumId,
      Value<String> name,
      Value<int> orderIndex,
    });

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, BaseReferences<_$AppDatabase, $SectionsTable, Section>),
          Section,
          PrefetchHooks Function()
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> albumId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                albumId: albumId,
                name: name,
                orderIndex: orderIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int albumId,
                required String name,
                required int orderIndex,
              }) => SectionsCompanion.insert(
                id: id,
                albumId: albumId,
                name: name,
                orderIndex: orderIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, BaseReferences<_$AppDatabase, $SectionsTable, Section>),
      Section,
      PrefetchHooks Function()
    >;
typedef $$StickersTableCreateCompanionBuilder =
    StickersCompanion Function({
      Value<int> id,
      required int sectionId,
      required String stickerNumber,
      required String name,
      Value<bool> isSpecial,
    });
typedef $$StickersTableUpdateCompanionBuilder =
    StickersCompanion Function({
      Value<int> id,
      Value<int> sectionId,
      Value<String> stickerNumber,
      Value<String> name,
      Value<bool> isSpecial,
    });

class $$StickersTableFilterComposer
    extends Composer<_$AppDatabase, $StickersTable> {
  $$StickersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stickerNumber => $composableBuilder(
    column: $table.stickerNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSpecial => $composableBuilder(
    column: $table.isSpecial,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StickersTableOrderingComposer
    extends Composer<_$AppDatabase, $StickersTable> {
  $$StickersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stickerNumber => $composableBuilder(
    column: $table.stickerNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSpecial => $composableBuilder(
    column: $table.isSpecial,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StickersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StickersTable> {
  $$StickersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get stickerNumber => $composableBuilder(
    column: $table.stickerNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isSpecial =>
      $composableBuilder(column: $table.isSpecial, builder: (column) => column);
}

class $$StickersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StickersTable,
          Sticker,
          $$StickersTableFilterComposer,
          $$StickersTableOrderingComposer,
          $$StickersTableAnnotationComposer,
          $$StickersTableCreateCompanionBuilder,
          $$StickersTableUpdateCompanionBuilder,
          (Sticker, BaseReferences<_$AppDatabase, $StickersTable, Sticker>),
          Sticker,
          PrefetchHooks Function()
        > {
  $$StickersTableTableManager(_$AppDatabase db, $StickersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StickersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StickersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StickersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<String> stickerNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isSpecial = const Value.absent(),
              }) => StickersCompanion(
                id: id,
                sectionId: sectionId,
                stickerNumber: stickerNumber,
                name: name,
                isSpecial: isSpecial,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sectionId,
                required String stickerNumber,
                required String name,
                Value<bool> isSpecial = const Value.absent(),
              }) => StickersCompanion.insert(
                id: id,
                sectionId: sectionId,
                stickerNumber: stickerNumber,
                name: name,
                isSpecial: isSpecial,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StickersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StickersTable,
      Sticker,
      $$StickersTableFilterComposer,
      $$StickersTableOrderingComposer,
      $$StickersTableAnnotationComposer,
      $$StickersTableCreateCompanionBuilder,
      $$StickersTableUpdateCompanionBuilder,
      (Sticker, BaseReferences<_$AppDatabase, $StickersTable, Sticker>),
      Sticker,
      PrefetchHooks Function()
    >;
typedef $$CollectionStatusesTableCreateCompanionBuilder =
    CollectionStatusesCompanion Function({
      Value<int> id,
      required int stickerId,
      Value<String> userId,
      Value<int> count,
    });
typedef $$CollectionStatusesTableUpdateCompanionBuilder =
    CollectionStatusesCompanion Function({
      Value<int> id,
      Value<int> stickerId,
      Value<String> userId,
      Value<int> count,
    });

class $$CollectionStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionStatusesTable> {
  $$CollectionStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stickerId => $composableBuilder(
    column: $table.stickerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionStatusesTable> {
  $$CollectionStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stickerId => $composableBuilder(
    column: $table.stickerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionStatusesTable> {
  $$CollectionStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stickerId =>
      $composableBuilder(column: $table.stickerId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$CollectionStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionStatusesTable,
          CollectionStatuse,
          $$CollectionStatusesTableFilterComposer,
          $$CollectionStatusesTableOrderingComposer,
          $$CollectionStatusesTableAnnotationComposer,
          $$CollectionStatusesTableCreateCompanionBuilder,
          $$CollectionStatusesTableUpdateCompanionBuilder,
          (
            CollectionStatuse,
            BaseReferences<
              _$AppDatabase,
              $CollectionStatusesTable,
              CollectionStatuse
            >,
          ),
          CollectionStatuse,
          PrefetchHooks Function()
        > {
  $$CollectionStatusesTableTableManager(
    _$AppDatabase db,
    $CollectionStatusesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionStatusesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> stickerId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> count = const Value.absent(),
              }) => CollectionStatusesCompanion(
                id: id,
                stickerId: stickerId,
                userId: userId,
                count: count,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int stickerId,
                Value<String> userId = const Value.absent(),
                Value<int> count = const Value.absent(),
              }) => CollectionStatusesCompanion.insert(
                id: id,
                stickerId: stickerId,
                userId: userId,
                count: count,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionStatusesTable,
      CollectionStatuse,
      $$CollectionStatusesTableFilterComposer,
      $$CollectionStatusesTableOrderingComposer,
      $$CollectionStatusesTableAnnotationComposer,
      $$CollectionStatusesTableCreateCompanionBuilder,
      $$CollectionStatusesTableUpdateCompanionBuilder,
      (
        CollectionStatuse,
        BaseReferences<
          _$AppDatabase,
          $CollectionStatusesTable,
          CollectionStatuse
        >,
      ),
      CollectionStatuse,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db, _db.albums);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$StickersTableTableManager get stickers =>
      $$StickersTableTableManager(_db, _db.stickers);
  $$CollectionStatusesTableTableManager get collectionStatuses =>
      $$CollectionStatusesTableTableManager(_db, _db.collectionStatuses);
}
