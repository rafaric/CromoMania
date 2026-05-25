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

class $SyncQueueItemsTable extends SyncQueueItems
    with TableInfo<$SyncQueueItemsTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueItemsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<String> stickerId = GeneratedColumn<String>(
    'sticker_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stickerId,
    operation,
    payload,
    retryCount,
    status,
    createdAt,
    processedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueItem> instance, {
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
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id},
  ];
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stickerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sticker_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      ),
    );
  }

  @override
  $SyncQueueItemsTable createAlias(String alias) {
    return $SyncQueueItemsTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final int id;
  final String stickerId;
  final String operation;
  final String payload;
  final int retryCount;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;
  const SyncQueueItem({
    required this.id,
    required this.stickerId,
    required this.operation,
    required this.payload,
    required this.retryCount,
    required this.status,
    required this.createdAt,
    this.processedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sticker_id'] = Variable<String>(stickerId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    return map;
  }

  SyncQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueItemsCompanion(
      id: Value(id),
      stickerId: Value(stickerId),
      operation: Value(operation),
      payload: Value(payload),
      retryCount: Value(retryCount),
      status: Value(status),
      createdAt: Value(createdAt),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
    );
  }

  factory SyncQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      stickerId: serializer.fromJson<String>(json['stickerId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stickerId': serializer.toJson<String>(stickerId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
    };
  }

  SyncQueueItem copyWith({
    int? id,
    String? stickerId,
    String? operation,
    String? payload,
    int? retryCount,
    String? status,
    DateTime? createdAt,
    Value<DateTime?> processedAt = const Value.absent(),
  }) => SyncQueueItem(
    id: id ?? this.id,
    stickerId: stickerId ?? this.stickerId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    processedAt: processedAt.present ? processedAt.value : this.processedAt,
  );
  SyncQueueItem copyWithCompanion(SyncQueueItemsCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      stickerId: data.stickerId.present ? data.stickerId.value : this.stickerId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('stickerId: $stickerId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stickerId,
    operation,
    payload,
    retryCount,
    status,
    createdAt,
    processedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.stickerId == this.stickerId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.processedAt == this.processedAt);
}

class SyncQueueItemsCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<String> stickerId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> processedAt;
  const SyncQueueItemsCompanion({
    this.id = const Value.absent(),
    this.stickerId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.processedAt = const Value.absent(),
  });
  SyncQueueItemsCompanion.insert({
    this.id = const Value.absent(),
    required String stickerId,
    required String operation,
    required String payload,
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.processedAt = const Value.absent(),
  }) : stickerId = Value(stickerId),
       operation = Value(operation),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<String>? stickerId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? processedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stickerId != null) 'sticker_id': stickerId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (processedAt != null) 'processed_at': processedAt,
    });
  }

  SyncQueueItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? stickerId,
    Value<String>? operation,
    Value<String>? payload,
    Value<int>? retryCount,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? processedAt,
  }) {
    return SyncQueueItemsCompanion(
      id: id ?? this.id,
      stickerId: stickerId ?? this.stickerId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stickerId.present) {
      map['sticker_id'] = Variable<String>(stickerId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('stickerId: $stickerId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }
}

class $TradeRecordsTable extends TradeRecords
    with TableInfo<$TradeRecordsTable, TradeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradeRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _partnerIdMeta = const VerificationMeta(
    'partnerId',
  );
  @override
  late final GeneratedColumn<String> partnerId = GeneratedColumn<String>(
    'partner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Anonymous'),
  );
  static const VerificationMeta _stickersGivenMeta = const VerificationMeta(
    'stickersGiven',
  );
  @override
  late final GeneratedColumn<int> stickersGiven = GeneratedColumn<int>(
    'stickers_given',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _givenIdsMeta = const VerificationMeta(
    'givenIds',
  );
  @override
  late final GeneratedColumn<String> givenIds = GeneratedColumn<String>(
    'given_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stickersReceivedMeta = const VerificationMeta(
    'stickersReceived',
  );
  @override
  late final GeneratedColumn<int> stickersReceived = GeneratedColumn<int>(
    'stickers_received',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _receivedIdsMeta = const VerificationMeta(
    'receivedIds',
  );
  @override
  late final GeneratedColumn<String> receivedIds = GeneratedColumn<String>(
    'received_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tradedAtMeta = const VerificationMeta(
    'tradedAt',
  );
  @override
  late final GeneratedColumn<int> tradedAt = GeneratedColumn<int>(
    'traded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeTypeMeta = const VerificationMeta(
    'tradeType',
  );
  @override
  late final GeneratedColumn<String> tradeType = GeneratedColumn<String>(
    'trade_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('qr_bidirectional'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    partnerId,
    partnerName,
    stickersGiven,
    givenIds,
    stickersReceived,
    receivedIds,
    tradedAt,
    tradeType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trade_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TradeRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('partner_id')) {
      context.handle(
        _partnerIdMeta,
        partnerId.isAcceptableOrUnknown(data['partner_id']!, _partnerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partnerIdMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    }
    if (data.containsKey('stickers_given')) {
      context.handle(
        _stickersGivenMeta,
        stickersGiven.isAcceptableOrUnknown(
          data['stickers_given']!,
          _stickersGivenMeta,
        ),
      );
    }
    if (data.containsKey('given_ids')) {
      context.handle(
        _givenIdsMeta,
        givenIds.isAcceptableOrUnknown(data['given_ids']!, _givenIdsMeta),
      );
    }
    if (data.containsKey('stickers_received')) {
      context.handle(
        _stickersReceivedMeta,
        stickersReceived.isAcceptableOrUnknown(
          data['stickers_received']!,
          _stickersReceivedMeta,
        ),
      );
    }
    if (data.containsKey('received_ids')) {
      context.handle(
        _receivedIdsMeta,
        receivedIds.isAcceptableOrUnknown(
          data['received_ids']!,
          _receivedIdsMeta,
        ),
      );
    }
    if (data.containsKey('traded_at')) {
      context.handle(
        _tradedAtMeta,
        tradedAt.isAcceptableOrUnknown(data['traded_at']!, _tradedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_tradedAtMeta);
    }
    if (data.containsKey('trade_type')) {
      context.handle(
        _tradeTypeMeta,
        tradeType.isAcceptableOrUnknown(data['trade_type']!, _tradeTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      partnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_id'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      )!,
      stickersGiven: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stickers_given'],
      )!,
      givenIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}given_ids'],
      ),
      stickersReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stickers_received'],
      )!,
      receivedIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_ids'],
      ),
      tradedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}traded_at'],
      )!,
      tradeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_type'],
      )!,
    );
  }

  @override
  $TradeRecordsTable createAlias(String alias) {
    return $TradeRecordsTable(attachedDatabase, alias);
  }
}

class TradeRecord extends DataClass implements Insertable<TradeRecord> {
  final int id;
  final String partnerId;
  final String partnerName;
  final int stickersGiven;
  final String? givenIds;
  final int stickersReceived;
  final String? receivedIds;
  final int tradedAt;
  final String tradeType;
  const TradeRecord({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.stickersGiven,
    this.givenIds,
    required this.stickersReceived,
    this.receivedIds,
    required this.tradedAt,
    required this.tradeType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['partner_id'] = Variable<String>(partnerId);
    map['partner_name'] = Variable<String>(partnerName);
    map['stickers_given'] = Variable<int>(stickersGiven);
    if (!nullToAbsent || givenIds != null) {
      map['given_ids'] = Variable<String>(givenIds);
    }
    map['stickers_received'] = Variable<int>(stickersReceived);
    if (!nullToAbsent || receivedIds != null) {
      map['received_ids'] = Variable<String>(receivedIds);
    }
    map['traded_at'] = Variable<int>(tradedAt);
    map['trade_type'] = Variable<String>(tradeType);
    return map;
  }

  TradeRecordsCompanion toCompanion(bool nullToAbsent) {
    return TradeRecordsCompanion(
      id: Value(id),
      partnerId: Value(partnerId),
      partnerName: Value(partnerName),
      stickersGiven: Value(stickersGiven),
      givenIds: givenIds == null && nullToAbsent
          ? const Value.absent()
          : Value(givenIds),
      stickersReceived: Value(stickersReceived),
      receivedIds: receivedIds == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedIds),
      tradedAt: Value(tradedAt),
      tradeType: Value(tradeType),
    );
  }

  factory TradeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradeRecord(
      id: serializer.fromJson<int>(json['id']),
      partnerId: serializer.fromJson<String>(json['partnerId']),
      partnerName: serializer.fromJson<String>(json['partnerName']),
      stickersGiven: serializer.fromJson<int>(json['stickersGiven']),
      givenIds: serializer.fromJson<String?>(json['givenIds']),
      stickersReceived: serializer.fromJson<int>(json['stickersReceived']),
      receivedIds: serializer.fromJson<String?>(json['receivedIds']),
      tradedAt: serializer.fromJson<int>(json['tradedAt']),
      tradeType: serializer.fromJson<String>(json['tradeType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partnerId': serializer.toJson<String>(partnerId),
      'partnerName': serializer.toJson<String>(partnerName),
      'stickersGiven': serializer.toJson<int>(stickersGiven),
      'givenIds': serializer.toJson<String?>(givenIds),
      'stickersReceived': serializer.toJson<int>(stickersReceived),
      'receivedIds': serializer.toJson<String?>(receivedIds),
      'tradedAt': serializer.toJson<int>(tradedAt),
      'tradeType': serializer.toJson<String>(tradeType),
    };
  }

  TradeRecord copyWith({
    int? id,
    String? partnerId,
    String? partnerName,
    int? stickersGiven,
    Value<String?> givenIds = const Value.absent(),
    int? stickersReceived,
    Value<String?> receivedIds = const Value.absent(),
    int? tradedAt,
    String? tradeType,
  }) => TradeRecord(
    id: id ?? this.id,
    partnerId: partnerId ?? this.partnerId,
    partnerName: partnerName ?? this.partnerName,
    stickersGiven: stickersGiven ?? this.stickersGiven,
    givenIds: givenIds.present ? givenIds.value : this.givenIds,
    stickersReceived: stickersReceived ?? this.stickersReceived,
    receivedIds: receivedIds.present ? receivedIds.value : this.receivedIds,
    tradedAt: tradedAt ?? this.tradedAt,
    tradeType: tradeType ?? this.tradeType,
  );
  TradeRecord copyWithCompanion(TradeRecordsCompanion data) {
    return TradeRecord(
      id: data.id.present ? data.id.value : this.id,
      partnerId: data.partnerId.present ? data.partnerId.value : this.partnerId,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      stickersGiven: data.stickersGiven.present
          ? data.stickersGiven.value
          : this.stickersGiven,
      givenIds: data.givenIds.present ? data.givenIds.value : this.givenIds,
      stickersReceived: data.stickersReceived.present
          ? data.stickersReceived.value
          : this.stickersReceived,
      receivedIds: data.receivedIds.present
          ? data.receivedIds.value
          : this.receivedIds,
      tradedAt: data.tradedAt.present ? data.tradedAt.value : this.tradedAt,
      tradeType: data.tradeType.present ? data.tradeType.value : this.tradeType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradeRecord(')
          ..write('id: $id, ')
          ..write('partnerId: $partnerId, ')
          ..write('partnerName: $partnerName, ')
          ..write('stickersGiven: $stickersGiven, ')
          ..write('givenIds: $givenIds, ')
          ..write('stickersReceived: $stickersReceived, ')
          ..write('receivedIds: $receivedIds, ')
          ..write('tradedAt: $tradedAt, ')
          ..write('tradeType: $tradeType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    partnerId,
    partnerName,
    stickersGiven,
    givenIds,
    stickersReceived,
    receivedIds,
    tradedAt,
    tradeType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradeRecord &&
          other.id == this.id &&
          other.partnerId == this.partnerId &&
          other.partnerName == this.partnerName &&
          other.stickersGiven == this.stickersGiven &&
          other.givenIds == this.givenIds &&
          other.stickersReceived == this.stickersReceived &&
          other.receivedIds == this.receivedIds &&
          other.tradedAt == this.tradedAt &&
          other.tradeType == this.tradeType);
}

class TradeRecordsCompanion extends UpdateCompanion<TradeRecord> {
  final Value<int> id;
  final Value<String> partnerId;
  final Value<String> partnerName;
  final Value<int> stickersGiven;
  final Value<String?> givenIds;
  final Value<int> stickersReceived;
  final Value<String?> receivedIds;
  final Value<int> tradedAt;
  final Value<String> tradeType;
  const TradeRecordsCompanion({
    this.id = const Value.absent(),
    this.partnerId = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.stickersGiven = const Value.absent(),
    this.givenIds = const Value.absent(),
    this.stickersReceived = const Value.absent(),
    this.receivedIds = const Value.absent(),
    this.tradedAt = const Value.absent(),
    this.tradeType = const Value.absent(),
  });
  TradeRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String partnerId,
    this.partnerName = const Value.absent(),
    this.stickersGiven = const Value.absent(),
    this.givenIds = const Value.absent(),
    this.stickersReceived = const Value.absent(),
    this.receivedIds = const Value.absent(),
    required int tradedAt,
    this.tradeType = const Value.absent(),
  }) : partnerId = Value(partnerId),
       tradedAt = Value(tradedAt);
  static Insertable<TradeRecord> custom({
    Expression<int>? id,
    Expression<String>? partnerId,
    Expression<String>? partnerName,
    Expression<int>? stickersGiven,
    Expression<String>? givenIds,
    Expression<int>? stickersReceived,
    Expression<String>? receivedIds,
    Expression<int>? tradedAt,
    Expression<String>? tradeType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partnerId != null) 'partner_id': partnerId,
      if (partnerName != null) 'partner_name': partnerName,
      if (stickersGiven != null) 'stickers_given': stickersGiven,
      if (givenIds != null) 'given_ids': givenIds,
      if (stickersReceived != null) 'stickers_received': stickersReceived,
      if (receivedIds != null) 'received_ids': receivedIds,
      if (tradedAt != null) 'traded_at': tradedAt,
      if (tradeType != null) 'trade_type': tradeType,
    });
  }

  TradeRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? partnerId,
    Value<String>? partnerName,
    Value<int>? stickersGiven,
    Value<String?>? givenIds,
    Value<int>? stickersReceived,
    Value<String?>? receivedIds,
    Value<int>? tradedAt,
    Value<String>? tradeType,
  }) {
    return TradeRecordsCompanion(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      stickersGiven: stickersGiven ?? this.stickersGiven,
      givenIds: givenIds ?? this.givenIds,
      stickersReceived: stickersReceived ?? this.stickersReceived,
      receivedIds: receivedIds ?? this.receivedIds,
      tradedAt: tradedAt ?? this.tradedAt,
      tradeType: tradeType ?? this.tradeType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partnerId.present) {
      map['partner_id'] = Variable<String>(partnerId.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (stickersGiven.present) {
      map['stickers_given'] = Variable<int>(stickersGiven.value);
    }
    if (givenIds.present) {
      map['given_ids'] = Variable<String>(givenIds.value);
    }
    if (stickersReceived.present) {
      map['stickers_received'] = Variable<int>(stickersReceived.value);
    }
    if (receivedIds.present) {
      map['received_ids'] = Variable<String>(receivedIds.value);
    }
    if (tradedAt.present) {
      map['traded_at'] = Variable<int>(tradedAt.value);
    }
    if (tradeType.present) {
      map['trade_type'] = Variable<String>(tradeType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('partnerId: $partnerId, ')
          ..write('partnerName: $partnerName, ')
          ..write('stickersGiven: $stickersGiven, ')
          ..write('givenIds: $givenIds, ')
          ..write('stickersReceived: $stickersReceived, ')
          ..write('receivedIds: $receivedIds, ')
          ..write('tradedAt: $tradedAt, ')
          ..write('tradeType: $tradeType')
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
  late final $SyncQueueItemsTable syncQueueItems = $SyncQueueItemsTable(this);
  late final $TradeRecordsTable tradeRecords = $TradeRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    albums,
    sections,
    stickers,
    collectionStatuses,
    syncQueueItems,
    tradeRecords,
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
typedef $$SyncQueueItemsTableCreateCompanionBuilder =
    SyncQueueItemsCompanion Function({
      Value<int> id,
      required String stickerId,
      required String operation,
      required String payload,
      Value<int> retryCount,
      Value<String> status,
      required DateTime createdAt,
      Value<DateTime?> processedAt,
    });
typedef $$SyncQueueItemsTableUpdateCompanionBuilder =
    SyncQueueItemsCompanion Function({
      Value<int> id,
      Value<String> stickerId,
      Value<String> operation,
      Value<String> payload,
      Value<int> retryCount,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> processedAt,
    });

class $$SyncQueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableFilterComposer({
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

  ColumnFilters<String> get stickerId => $composableBuilder(
    column: $table.stickerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableOrderingComposer({
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

  ColumnOrderings<String> get stickerId => $composableBuilder(
    column: $table.stickerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stickerId =>
      $composableBuilder(column: $table.stickerId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );
}

class $$SyncQueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueItemsTable,
          SyncQueueItem,
          $$SyncQueueItemsTableFilterComposer,
          $$SyncQueueItemsTableOrderingComposer,
          $$SyncQueueItemsTableAnnotationComposer,
          $$SyncQueueItemsTableCreateCompanionBuilder,
          $$SyncQueueItemsTableUpdateCompanionBuilder,
          (
            SyncQueueItem,
            BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>,
          ),
          SyncQueueItem,
          PrefetchHooks Function()
        > {
  $$SyncQueueItemsTableTableManager(
    _$AppDatabase db,
    $SyncQueueItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> stickerId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
              }) => SyncQueueItemsCompanion(
                id: id,
                stickerId: stickerId,
                operation: operation,
                payload: payload,
                retryCount: retryCount,
                status: status,
                createdAt: createdAt,
                processedAt: processedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String stickerId,
                required String operation,
                required String payload,
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> processedAt = const Value.absent(),
              }) => SyncQueueItemsCompanion.insert(
                id: id,
                stickerId: stickerId,
                operation: operation,
                payload: payload,
                retryCount: retryCount,
                status: status,
                createdAt: createdAt,
                processedAt: processedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueItemsTable,
      SyncQueueItem,
      $$SyncQueueItemsTableFilterComposer,
      $$SyncQueueItemsTableOrderingComposer,
      $$SyncQueueItemsTableAnnotationComposer,
      $$SyncQueueItemsTableCreateCompanionBuilder,
      $$SyncQueueItemsTableUpdateCompanionBuilder,
      (
        SyncQueueItem,
        BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>,
      ),
      SyncQueueItem,
      PrefetchHooks Function()
    >;
typedef $$TradeRecordsTableCreateCompanionBuilder =
    TradeRecordsCompanion Function({
      Value<int> id,
      required String partnerId,
      Value<String> partnerName,
      Value<int> stickersGiven,
      Value<String?> givenIds,
      Value<int> stickersReceived,
      Value<String?> receivedIds,
      required int tradedAt,
      Value<String> tradeType,
    });
typedef $$TradeRecordsTableUpdateCompanionBuilder =
    TradeRecordsCompanion Function({
      Value<int> id,
      Value<String> partnerId,
      Value<String> partnerName,
      Value<int> stickersGiven,
      Value<String?> givenIds,
      Value<int> stickersReceived,
      Value<String?> receivedIds,
      Value<int> tradedAt,
      Value<String> tradeType,
    });

class $$TradeRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TradeRecordsTable> {
  $$TradeRecordsTableFilterComposer({
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

  ColumnFilters<String> get partnerId => $composableBuilder(
    column: $table.partnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stickersGiven => $composableBuilder(
    column: $table.stickersGiven,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get givenIds => $composableBuilder(
    column: $table.givenIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stickersReceived => $composableBuilder(
    column: $table.stickersReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedIds => $composableBuilder(
    column: $table.receivedIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tradedAt => $composableBuilder(
    column: $table.tradedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeType => $composableBuilder(
    column: $table.tradeType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TradeRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TradeRecordsTable> {
  $$TradeRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get partnerId => $composableBuilder(
    column: $table.partnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stickersGiven => $composableBuilder(
    column: $table.stickersGiven,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get givenIds => $composableBuilder(
    column: $table.givenIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stickersReceived => $composableBuilder(
    column: $table.stickersReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedIds => $composableBuilder(
    column: $table.receivedIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tradedAt => $composableBuilder(
    column: $table.tradedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeType => $composableBuilder(
    column: $table.tradeType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TradeRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradeRecordsTable> {
  $$TradeRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partnerId =>
      $composableBuilder(column: $table.partnerId, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stickersGiven => $composableBuilder(
    column: $table.stickersGiven,
    builder: (column) => column,
  );

  GeneratedColumn<String> get givenIds =>
      $composableBuilder(column: $table.givenIds, builder: (column) => column);

  GeneratedColumn<int> get stickersReceived => $composableBuilder(
    column: $table.stickersReceived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receivedIds => $composableBuilder(
    column: $table.receivedIds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tradedAt =>
      $composableBuilder(column: $table.tradedAt, builder: (column) => column);

  GeneratedColumn<String> get tradeType =>
      $composableBuilder(column: $table.tradeType, builder: (column) => column);
}

class $$TradeRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradeRecordsTable,
          TradeRecord,
          $$TradeRecordsTableFilterComposer,
          $$TradeRecordsTableOrderingComposer,
          $$TradeRecordsTableAnnotationComposer,
          $$TradeRecordsTableCreateCompanionBuilder,
          $$TradeRecordsTableUpdateCompanionBuilder,
          (
            TradeRecord,
            BaseReferences<_$AppDatabase, $TradeRecordsTable, TradeRecord>,
          ),
          TradeRecord,
          PrefetchHooks Function()
        > {
  $$TradeRecordsTableTableManager(_$AppDatabase db, $TradeRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradeRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradeRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradeRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> partnerId = const Value.absent(),
                Value<String> partnerName = const Value.absent(),
                Value<int> stickersGiven = const Value.absent(),
                Value<String?> givenIds = const Value.absent(),
                Value<int> stickersReceived = const Value.absent(),
                Value<String?> receivedIds = const Value.absent(),
                Value<int> tradedAt = const Value.absent(),
                Value<String> tradeType = const Value.absent(),
              }) => TradeRecordsCompanion(
                id: id,
                partnerId: partnerId,
                partnerName: partnerName,
                stickersGiven: stickersGiven,
                givenIds: givenIds,
                stickersReceived: stickersReceived,
                receivedIds: receivedIds,
                tradedAt: tradedAt,
                tradeType: tradeType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String partnerId,
                Value<String> partnerName = const Value.absent(),
                Value<int> stickersGiven = const Value.absent(),
                Value<String?> givenIds = const Value.absent(),
                Value<int> stickersReceived = const Value.absent(),
                Value<String?> receivedIds = const Value.absent(),
                required int tradedAt,
                Value<String> tradeType = const Value.absent(),
              }) => TradeRecordsCompanion.insert(
                id: id,
                partnerId: partnerId,
                partnerName: partnerName,
                stickersGiven: stickersGiven,
                givenIds: givenIds,
                stickersReceived: stickersReceived,
                receivedIds: receivedIds,
                tradedAt: tradedAt,
                tradeType: tradeType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TradeRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradeRecordsTable,
      TradeRecord,
      $$TradeRecordsTableFilterComposer,
      $$TradeRecordsTableOrderingComposer,
      $$TradeRecordsTableAnnotationComposer,
      $$TradeRecordsTableCreateCompanionBuilder,
      $$TradeRecordsTableUpdateCompanionBuilder,
      (
        TradeRecord,
        BaseReferences<_$AppDatabase, $TradeRecordsTable, TradeRecord>,
      ),
      TradeRecord,
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
  $$SyncQueueItemsTableTableManager get syncQueueItems =>
      $$SyncQueueItemsTableTableManager(_db, _db.syncQueueItems);
  $$TradeRecordsTableTableManager get tradeRecords =>
      $$TradeRecordsTableTableManager(_db, _db.tradeRecords);
}
