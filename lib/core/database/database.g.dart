// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ChatsTable extends Chats with TableInfo<$ChatsTable, Chat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, role, content, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class Chat extends DataClass implements Insertable<Chat> {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  const Chat({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      timestamp: Value(timestamp),
    );
  }

  factory Chat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chat(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  Chat copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
  }) => Chat(
    id: id ?? this.id,
    role: role ?? this.role,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp,
  );
  Chat copyWithCompanion(ChatsCompanion data) {
    return Chat(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, content, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chat &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.timestamp == this.timestamp);
}

class ChatsCompanion extends UpdateCompanion<Chat> {
  final Value<String> id;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatsCompanion.insert({
    required String id,
    required String role,
    required String content,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role),
       content = Value(content),
       timestamp = Value(timestamp);
  static Insertable<Chat> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatsCompanion copyWith({
    Value<String>? id,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return ChatsCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiMemoriesTable extends AiMemories
    with TableInfo<$AiMemoriesTable, AiMemory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiMemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiMemory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AiMemory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiMemory(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AiMemoriesTable createAlias(String alias) {
    return $AiMemoriesTable(attachedDatabase, alias);
  }
}

class AiMemory extends DataClass implements Insertable<AiMemory> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AiMemory({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AiMemoriesCompanion toCompanion(bool nullToAbsent) {
    return AiMemoriesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiMemory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiMemory(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AiMemory copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AiMemory(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AiMemory copyWithCompanion(AiMemoriesCompanion data) {
    return AiMemory(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiMemory(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiMemory &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AiMemoriesCompanion extends UpdateCompanion<AiMemory> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AiMemoriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiMemoriesCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AiMemory> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiMemoriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AiMemoriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
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
    return (StringBuffer('AiMemoriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedDeadlinesTable extends CachedDeadlines
    with TableInfo<$CachedDeadlinesTable, CachedDeadline> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedDeadlinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _dueTimeMeta = const VerificationMeta(
    'dueTime',
  );
  @override
  late final GeneratedColumn<DateTime> dueTime = GeneratedColumn<DateTime>(
    'due_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternateLinkMeta = const VerificationMeta(
    'alternateLink',
  );
  @override
  late final GeneratedColumn<String> alternateLink = GeneratedColumn<String>(
    'alternate_link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSubmittedMeta = const VerificationMeta(
    'isSubmitted',
  );
  @override
  late final GeneratedColumn<bool> isSubmitted = GeneratedColumn<bool>(
    'is_submitted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_submitted" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseName,
    title,
    description,
    dueTime,
    alternateLink,
    isSubmitted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_deadlines';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedDeadline> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    } else if (isInserting) {
      context.missing(_courseNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('due_time')) {
      context.handle(
        _dueTimeMeta,
        dueTime.isAcceptableOrUnknown(data['due_time']!, _dueTimeMeta),
      );
    }
    if (data.containsKey('alternate_link')) {
      context.handle(
        _alternateLinkMeta,
        alternateLink.isAcceptableOrUnknown(
          data['alternate_link']!,
          _alternateLinkMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alternateLinkMeta);
    }
    if (data.containsKey('is_submitted')) {
      context.handle(
        _isSubmittedMeta,
        isSubmitted.isAcceptableOrUnknown(
          data['is_submitted']!,
          _isSubmittedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isSubmittedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedDeadline map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDeadline(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dueTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_time'],
      ),
      alternateLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_link'],
      )!,
      isSubmitted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_submitted'],
      )!,
    );
  }

  @override
  $CachedDeadlinesTable createAlias(String alias) {
    return $CachedDeadlinesTable(attachedDatabase, alias);
  }
}

class CachedDeadline extends DataClass implements Insertable<CachedDeadline> {
  final String id;
  final String courseName;
  final String title;
  final String? description;
  final DateTime? dueTime;
  final String alternateLink;
  final bool isSubmitted;
  const CachedDeadline({
    required this.id,
    required this.courseName,
    required this.title,
    this.description,
    this.dueTime,
    required this.alternateLink,
    required this.isSubmitted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['course_name'] = Variable<String>(courseName);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || dueTime != null) {
      map['due_time'] = Variable<DateTime>(dueTime);
    }
    map['alternate_link'] = Variable<String>(alternateLink);
    map['is_submitted'] = Variable<bool>(isSubmitted);
    return map;
  }

  CachedDeadlinesCompanion toCompanion(bool nullToAbsent) {
    return CachedDeadlinesCompanion(
      id: Value(id),
      courseName: Value(courseName),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueTime: dueTime == null && nullToAbsent
          ? const Value.absent()
          : Value(dueTime),
      alternateLink: Value(alternateLink),
      isSubmitted: Value(isSubmitted),
    );
  }

  factory CachedDeadline.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedDeadline(
      id: serializer.fromJson<String>(json['id']),
      courseName: serializer.fromJson<String>(json['courseName']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueTime: serializer.fromJson<DateTime?>(json['dueTime']),
      alternateLink: serializer.fromJson<String>(json['alternateLink']),
      isSubmitted: serializer.fromJson<bool>(json['isSubmitted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'courseName': serializer.toJson<String>(courseName),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueTime': serializer.toJson<DateTime?>(dueTime),
      'alternateLink': serializer.toJson<String>(alternateLink),
      'isSubmitted': serializer.toJson<bool>(isSubmitted),
    };
  }

  CachedDeadline copyWith({
    String? id,
    String? courseName,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> dueTime = const Value.absent(),
    String? alternateLink,
    bool? isSubmitted,
  }) => CachedDeadline(
    id: id ?? this.id,
    courseName: courseName ?? this.courseName,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    dueTime: dueTime.present ? dueTime.value : this.dueTime,
    alternateLink: alternateLink ?? this.alternateLink,
    isSubmitted: isSubmitted ?? this.isSubmitted,
  );
  CachedDeadline copyWithCompanion(CachedDeadlinesCompanion data) {
    return CachedDeadline(
      id: data.id.present ? data.id.value : this.id,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueTime: data.dueTime.present ? data.dueTime.value : this.dueTime,
      alternateLink: data.alternateLink.present
          ? data.alternateLink.value
          : this.alternateLink,
      isSubmitted: data.isSubmitted.present
          ? data.isSubmitted.value
          : this.isSubmitted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedDeadline(')
          ..write('id: $id, ')
          ..write('courseName: $courseName, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueTime: $dueTime, ')
          ..write('alternateLink: $alternateLink, ')
          ..write('isSubmitted: $isSubmitted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseName,
    title,
    description,
    dueTime,
    alternateLink,
    isSubmitted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedDeadline &&
          other.id == this.id &&
          other.courseName == this.courseName &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueTime == this.dueTime &&
          other.alternateLink == this.alternateLink &&
          other.isSubmitted == this.isSubmitted);
}

class CachedDeadlinesCompanion extends UpdateCompanion<CachedDeadline> {
  final Value<String> id;
  final Value<String> courseName;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> dueTime;
  final Value<String> alternateLink;
  final Value<bool> isSubmitted;
  final Value<int> rowid;
  const CachedDeadlinesCompanion({
    this.id = const Value.absent(),
    this.courseName = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueTime = const Value.absent(),
    this.alternateLink = const Value.absent(),
    this.isSubmitted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedDeadlinesCompanion.insert({
    required String id,
    required String courseName,
    required String title,
    this.description = const Value.absent(),
    this.dueTime = const Value.absent(),
    required String alternateLink,
    required bool isSubmitted,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseName = Value(courseName),
       title = Value(title),
       alternateLink = Value(alternateLink),
       isSubmitted = Value(isSubmitted);
  static Insertable<CachedDeadline> custom({
    Expression<String>? id,
    Expression<String>? courseName,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueTime,
    Expression<String>? alternateLink,
    Expression<bool>? isSubmitted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseName != null) 'course_name': courseName,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueTime != null) 'due_time': dueTime,
      if (alternateLink != null) 'alternate_link': alternateLink,
      if (isSubmitted != null) 'is_submitted': isSubmitted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedDeadlinesCompanion copyWith({
    Value<String>? id,
    Value<String>? courseName,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? dueTime,
    Value<String>? alternateLink,
    Value<bool>? isSubmitted,
    Value<int>? rowid,
  }) {
    return CachedDeadlinesCompanion(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      title: title ?? this.title,
      description: description ?? this.description,
      dueTime: dueTime ?? this.dueTime,
      alternateLink: alternateLink ?? this.alternateLink,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueTime.present) {
      map['due_time'] = Variable<DateTime>(dueTime.value);
    }
    if (alternateLink.present) {
      map['alternate_link'] = Variable<String>(alternateLink.value);
    }
    if (isSubmitted.present) {
      map['is_submitted'] = Variable<bool>(isSubmitted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedDeadlinesCompanion(')
          ..write('id: $id, ')
          ..write('courseName: $courseName, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueTime: $dueTime, ')
          ..write('alternateLink: $alternateLink, ')
          ..write('isSubmitted: $isSubmitted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedEmailsTable extends CachedEmails
    with TableInfo<$CachedEmailsTable, CachedEmail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedEmailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snippetMeta = const VerificationMeta(
    'snippet',
  );
  @override
  late final GeneratedColumn<String> snippet = GeneratedColumn<String>(
    'snippet',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodySummaryMeta = const VerificationMeta(
    'bodySummary',
  );
  @override
  late final GeneratedColumn<String> bodySummary = GeneratedColumn<String>(
    'body_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAcademicMeta = const VerificationMeta(
    'isAcademic',
  );
  @override
  late final GeneratedColumn<bool> isAcademic = GeneratedColumn<bool>(
    'is_academic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_academic" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sender,
    subject,
    snippet,
    bodySummary,
    receivedAt,
    isAcademic,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_emails';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedEmail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('snippet')) {
      context.handle(
        _snippetMeta,
        snippet.isAcceptableOrUnknown(data['snippet']!, _snippetMeta),
      );
    } else if (isInserting) {
      context.missing(_snippetMeta);
    }
    if (data.containsKey('body_summary')) {
      context.handle(
        _bodySummaryMeta,
        bodySummary.isAcceptableOrUnknown(
          data['body_summary']!,
          _bodySummaryMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('is_academic')) {
      context.handle(
        _isAcademicMeta,
        isAcademic.isAcceptableOrUnknown(data['is_academic']!, _isAcademicMeta),
      );
    } else if (isInserting) {
      context.missing(_isAcademicMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedEmail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedEmail(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      snippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet'],
      )!,
      bodySummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_summary'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      isAcademic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_academic'],
      )!,
    );
  }

  @override
  $CachedEmailsTable createAlias(String alias) {
    return $CachedEmailsTable(attachedDatabase, alias);
  }
}

class CachedEmail extends DataClass implements Insertable<CachedEmail> {
  final String id;
  final String sender;
  final String subject;
  final String snippet;
  final String? bodySummary;
  final DateTime receivedAt;
  final bool isAcademic;
  const CachedEmail({
    required this.id,
    required this.sender,
    required this.subject,
    required this.snippet,
    this.bodySummary,
    required this.receivedAt,
    required this.isAcademic,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender'] = Variable<String>(sender);
    map['subject'] = Variable<String>(subject);
    map['snippet'] = Variable<String>(snippet);
    if (!nullToAbsent || bodySummary != null) {
      map['body_summary'] = Variable<String>(bodySummary);
    }
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['is_academic'] = Variable<bool>(isAcademic);
    return map;
  }

  CachedEmailsCompanion toCompanion(bool nullToAbsent) {
    return CachedEmailsCompanion(
      id: Value(id),
      sender: Value(sender),
      subject: Value(subject),
      snippet: Value(snippet),
      bodySummary: bodySummary == null && nullToAbsent
          ? const Value.absent()
          : Value(bodySummary),
      receivedAt: Value(receivedAt),
      isAcademic: Value(isAcademic),
    );
  }

  factory CachedEmail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedEmail(
      id: serializer.fromJson<String>(json['id']),
      sender: serializer.fromJson<String>(json['sender']),
      subject: serializer.fromJson<String>(json['subject']),
      snippet: serializer.fromJson<String>(json['snippet']),
      bodySummary: serializer.fromJson<String?>(json['bodySummary']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      isAcademic: serializer.fromJson<bool>(json['isAcademic']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sender': serializer.toJson<String>(sender),
      'subject': serializer.toJson<String>(subject),
      'snippet': serializer.toJson<String>(snippet),
      'bodySummary': serializer.toJson<String?>(bodySummary),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'isAcademic': serializer.toJson<bool>(isAcademic),
    };
  }

  CachedEmail copyWith({
    String? id,
    String? sender,
    String? subject,
    String? snippet,
    Value<String?> bodySummary = const Value.absent(),
    DateTime? receivedAt,
    bool? isAcademic,
  }) => CachedEmail(
    id: id ?? this.id,
    sender: sender ?? this.sender,
    subject: subject ?? this.subject,
    snippet: snippet ?? this.snippet,
    bodySummary: bodySummary.present ? bodySummary.value : this.bodySummary,
    receivedAt: receivedAt ?? this.receivedAt,
    isAcademic: isAcademic ?? this.isAcademic,
  );
  CachedEmail copyWithCompanion(CachedEmailsCompanion data) {
    return CachedEmail(
      id: data.id.present ? data.id.value : this.id,
      sender: data.sender.present ? data.sender.value : this.sender,
      subject: data.subject.present ? data.subject.value : this.subject,
      snippet: data.snippet.present ? data.snippet.value : this.snippet,
      bodySummary: data.bodySummary.present
          ? data.bodySummary.value
          : this.bodySummary,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      isAcademic: data.isAcademic.present
          ? data.isAcademic.value
          : this.isAcademic,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedEmail(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('subject: $subject, ')
          ..write('snippet: $snippet, ')
          ..write('bodySummary: $bodySummary, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('isAcademic: $isAcademic')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sender,
    subject,
    snippet,
    bodySummary,
    receivedAt,
    isAcademic,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedEmail &&
          other.id == this.id &&
          other.sender == this.sender &&
          other.subject == this.subject &&
          other.snippet == this.snippet &&
          other.bodySummary == this.bodySummary &&
          other.receivedAt == this.receivedAt &&
          other.isAcademic == this.isAcademic);
}

class CachedEmailsCompanion extends UpdateCompanion<CachedEmail> {
  final Value<String> id;
  final Value<String> sender;
  final Value<String> subject;
  final Value<String> snippet;
  final Value<String?> bodySummary;
  final Value<DateTime> receivedAt;
  final Value<bool> isAcademic;
  final Value<int> rowid;
  const CachedEmailsCompanion({
    this.id = const Value.absent(),
    this.sender = const Value.absent(),
    this.subject = const Value.absent(),
    this.snippet = const Value.absent(),
    this.bodySummary = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.isAcademic = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedEmailsCompanion.insert({
    required String id,
    required String sender,
    required String subject,
    required String snippet,
    this.bodySummary = const Value.absent(),
    required DateTime receivedAt,
    required bool isAcademic,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sender = Value(sender),
       subject = Value(subject),
       snippet = Value(snippet),
       receivedAt = Value(receivedAt),
       isAcademic = Value(isAcademic);
  static Insertable<CachedEmail> custom({
    Expression<String>? id,
    Expression<String>? sender,
    Expression<String>? subject,
    Expression<String>? snippet,
    Expression<String>? bodySummary,
    Expression<DateTime>? receivedAt,
    Expression<bool>? isAcademic,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sender != null) 'sender': sender,
      if (subject != null) 'subject': subject,
      if (snippet != null) 'snippet': snippet,
      if (bodySummary != null) 'body_summary': bodySummary,
      if (receivedAt != null) 'received_at': receivedAt,
      if (isAcademic != null) 'is_academic': isAcademic,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedEmailsCompanion copyWith({
    Value<String>? id,
    Value<String>? sender,
    Value<String>? subject,
    Value<String>? snippet,
    Value<String?>? bodySummary,
    Value<DateTime>? receivedAt,
    Value<bool>? isAcademic,
    Value<int>? rowid,
  }) {
    return CachedEmailsCompanion(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      snippet: snippet ?? this.snippet,
      bodySummary: bodySummary ?? this.bodySummary,
      receivedAt: receivedAt ?? this.receivedAt,
      isAcademic: isAcademic ?? this.isAcademic,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (snippet.present) {
      map['snippet'] = Variable<String>(snippet.value);
    }
    if (bodySummary.present) {
      map['body_summary'] = Variable<String>(bodySummary.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (isAcademic.present) {
      map['is_academic'] = Variable<bool>(isAcademic.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedEmailsCompanion(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('subject: $subject, ')
          ..write('snippet: $snippet, ')
          ..write('bodySummary: $bodySummary, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('isAcademic: $isAcademic, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $AiMemoriesTable aiMemories = $AiMemoriesTable(this);
  late final $CachedDeadlinesTable cachedDeadlines = $CachedDeadlinesTable(
    this,
  );
  late final $CachedEmailsTable cachedEmails = $CachedEmailsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chats,
    aiMemories,
    cachedDeadlines,
    cachedEmails,
  ];
}

typedef $$ChatsTableCreateCompanionBuilder =
    ChatsCompanion Function({
      required String id,
      required String role,
      required String content,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$ChatsTableUpdateCompanionBuilder =
    ChatsCompanion Function({
      Value<String> id,
      Value<String> role,
      Value<String> content,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$ChatsTableFilterComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
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

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
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

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatsTable,
          Chat,
          $$ChatsTableFilterComposer,
          $$ChatsTableOrderingComposer,
          $$ChatsTableAnnotationComposer,
          $$ChatsTableCreateCompanionBuilder,
          $$ChatsTableUpdateCompanionBuilder,
          (Chat, BaseReferences<_$AppDatabase, $ChatsTable, Chat>),
          Chat,
          PrefetchHooks Function()
        > {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion(
                id: id,
                role: role,
                content: content,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String role,
                required String content,
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => ChatsCompanion.insert(
                id: id,
                role: role,
                content: content,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatsTable,
      Chat,
      $$ChatsTableFilterComposer,
      $$ChatsTableOrderingComposer,
      $$ChatsTableAnnotationComposer,
      $$ChatsTableCreateCompanionBuilder,
      $$ChatsTableUpdateCompanionBuilder,
      (Chat, BaseReferences<_$AppDatabase, $ChatsTable, Chat>),
      Chat,
      PrefetchHooks Function()
    >;
typedef $$AiMemoriesTableCreateCompanionBuilder =
    AiMemoriesCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AiMemoriesTableUpdateCompanionBuilder =
    AiMemoriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AiMemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $AiMemoriesTable> {
  $$AiMemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiMemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiMemoriesTable> {
  $$AiMemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiMemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiMemoriesTable> {
  $$AiMemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiMemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiMemoriesTable,
          AiMemory,
          $$AiMemoriesTableFilterComposer,
          $$AiMemoriesTableOrderingComposer,
          $$AiMemoriesTableAnnotationComposer,
          $$AiMemoriesTableCreateCompanionBuilder,
          $$AiMemoriesTableUpdateCompanionBuilder,
          (AiMemory, BaseReferences<_$AppDatabase, $AiMemoriesTable, AiMemory>),
          AiMemory,
          PrefetchHooks Function()
        > {
  $$AiMemoriesTableTableManager(_$AppDatabase db, $AiMemoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiMemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiMemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiMemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiMemoriesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AiMemoriesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiMemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiMemoriesTable,
      AiMemory,
      $$AiMemoriesTableFilterComposer,
      $$AiMemoriesTableOrderingComposer,
      $$AiMemoriesTableAnnotationComposer,
      $$AiMemoriesTableCreateCompanionBuilder,
      $$AiMemoriesTableUpdateCompanionBuilder,
      (AiMemory, BaseReferences<_$AppDatabase, $AiMemoriesTable, AiMemory>),
      AiMemory,
      PrefetchHooks Function()
    >;
typedef $$CachedDeadlinesTableCreateCompanionBuilder =
    CachedDeadlinesCompanion Function({
      required String id,
      required String courseName,
      required String title,
      Value<String?> description,
      Value<DateTime?> dueTime,
      required String alternateLink,
      required bool isSubmitted,
      Value<int> rowid,
    });
typedef $$CachedDeadlinesTableUpdateCompanionBuilder =
    CachedDeadlinesCompanion Function({
      Value<String> id,
      Value<String> courseName,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> dueTime,
      Value<String> alternateLink,
      Value<bool> isSubmitted,
      Value<int> rowid,
    });

class $$CachedDeadlinesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedDeadlinesTable> {
  $$CachedDeadlinesTableFilterComposer({
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

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueTime => $composableBuilder(
    column: $table.dueTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternateLink => $composableBuilder(
    column: $table.alternateLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedDeadlinesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedDeadlinesTable> {
  $$CachedDeadlinesTableOrderingComposer({
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

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueTime => $composableBuilder(
    column: $table.dueTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternateLink => $composableBuilder(
    column: $table.alternateLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedDeadlinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedDeadlinesTable> {
  $$CachedDeadlinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueTime =>
      $composableBuilder(column: $table.dueTime, builder: (column) => column);

  GeneratedColumn<String> get alternateLink => $composableBuilder(
    column: $table.alternateLink,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => column,
  );
}

class $$CachedDeadlinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedDeadlinesTable,
          CachedDeadline,
          $$CachedDeadlinesTableFilterComposer,
          $$CachedDeadlinesTableOrderingComposer,
          $$CachedDeadlinesTableAnnotationComposer,
          $$CachedDeadlinesTableCreateCompanionBuilder,
          $$CachedDeadlinesTableUpdateCompanionBuilder,
          (
            CachedDeadline,
            BaseReferences<
              _$AppDatabase,
              $CachedDeadlinesTable,
              CachedDeadline
            >,
          ),
          CachedDeadline,
          PrefetchHooks Function()
        > {
  $$CachedDeadlinesTableTableManager(
    _$AppDatabase db,
    $CachedDeadlinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedDeadlinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedDeadlinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedDeadlinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> courseName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueTime = const Value.absent(),
                Value<String> alternateLink = const Value.absent(),
                Value<bool> isSubmitted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedDeadlinesCompanion(
                id: id,
                courseName: courseName,
                title: title,
                description: description,
                dueTime: dueTime,
                alternateLink: alternateLink,
                isSubmitted: isSubmitted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String courseName,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueTime = const Value.absent(),
                required String alternateLink,
                required bool isSubmitted,
                Value<int> rowid = const Value.absent(),
              }) => CachedDeadlinesCompanion.insert(
                id: id,
                courseName: courseName,
                title: title,
                description: description,
                dueTime: dueTime,
                alternateLink: alternateLink,
                isSubmitted: isSubmitted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedDeadlinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedDeadlinesTable,
      CachedDeadline,
      $$CachedDeadlinesTableFilterComposer,
      $$CachedDeadlinesTableOrderingComposer,
      $$CachedDeadlinesTableAnnotationComposer,
      $$CachedDeadlinesTableCreateCompanionBuilder,
      $$CachedDeadlinesTableUpdateCompanionBuilder,
      (
        CachedDeadline,
        BaseReferences<_$AppDatabase, $CachedDeadlinesTable, CachedDeadline>,
      ),
      CachedDeadline,
      PrefetchHooks Function()
    >;
typedef $$CachedEmailsTableCreateCompanionBuilder =
    CachedEmailsCompanion Function({
      required String id,
      required String sender,
      required String subject,
      required String snippet,
      Value<String?> bodySummary,
      required DateTime receivedAt,
      required bool isAcademic,
      Value<int> rowid,
    });
typedef $$CachedEmailsTableUpdateCompanionBuilder =
    CachedEmailsCompanion Function({
      Value<String> id,
      Value<String> sender,
      Value<String> subject,
      Value<String> snippet,
      Value<String?> bodySummary,
      Value<DateTime> receivedAt,
      Value<bool> isAcademic,
      Value<int> rowid,
    });

class $$CachedEmailsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedEmailsTable> {
  $$CachedEmailsTableFilterComposer({
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

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodySummary => $composableBuilder(
    column: $table.bodySummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAcademic => $composableBuilder(
    column: $table.isAcademic,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedEmailsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedEmailsTable> {
  $$CachedEmailsTableOrderingComposer({
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

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodySummary => $composableBuilder(
    column: $table.bodySummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAcademic => $composableBuilder(
    column: $table.isAcademic,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedEmailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedEmailsTable> {
  $$CachedEmailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get snippet =>
      $composableBuilder(column: $table.snippet, builder: (column) => column);

  GeneratedColumn<String> get bodySummary => $composableBuilder(
    column: $table.bodySummary,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAcademic => $composableBuilder(
    column: $table.isAcademic,
    builder: (column) => column,
  );
}

class $$CachedEmailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedEmailsTable,
          CachedEmail,
          $$CachedEmailsTableFilterComposer,
          $$CachedEmailsTableOrderingComposer,
          $$CachedEmailsTableAnnotationComposer,
          $$CachedEmailsTableCreateCompanionBuilder,
          $$CachedEmailsTableUpdateCompanionBuilder,
          (
            CachedEmail,
            BaseReferences<_$AppDatabase, $CachedEmailsTable, CachedEmail>,
          ),
          CachedEmail,
          PrefetchHooks Function()
        > {
  $$CachedEmailsTableTableManager(_$AppDatabase db, $CachedEmailsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedEmailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedEmailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedEmailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> snippet = const Value.absent(),
                Value<String?> bodySummary = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<bool> isAcademic = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedEmailsCompanion(
                id: id,
                sender: sender,
                subject: subject,
                snippet: snippet,
                bodySummary: bodySummary,
                receivedAt: receivedAt,
                isAcademic: isAcademic,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sender,
                required String subject,
                required String snippet,
                Value<String?> bodySummary = const Value.absent(),
                required DateTime receivedAt,
                required bool isAcademic,
                Value<int> rowid = const Value.absent(),
              }) => CachedEmailsCompanion.insert(
                id: id,
                sender: sender,
                subject: subject,
                snippet: snippet,
                bodySummary: bodySummary,
                receivedAt: receivedAt,
                isAcademic: isAcademic,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedEmailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedEmailsTable,
      CachedEmail,
      $$CachedEmailsTableFilterComposer,
      $$CachedEmailsTableOrderingComposer,
      $$CachedEmailsTableAnnotationComposer,
      $$CachedEmailsTableCreateCompanionBuilder,
      $$CachedEmailsTableUpdateCompanionBuilder,
      (
        CachedEmail,
        BaseReferences<_$AppDatabase, $CachedEmailsTable, CachedEmail>,
      ),
      CachedEmail,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$AiMemoriesTableTableManager get aiMemories =>
      $$AiMemoriesTableTableManager(_db, _db.aiMemories);
  $$CachedDeadlinesTableTableManager get cachedDeadlines =>
      $$CachedDeadlinesTableTableManager(_db, _db.cachedDeadlines);
  $$CachedEmailsTableTableManager get cachedEmails =>
      $$CachedEmailsTableTableManager(_db, _db.cachedEmails);
}
