import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AiMemories extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

class CachedDeadlines extends Table {
  TextColumn get id => text()();
  TextColumn get courseName => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueTime => dateTime().nullable()();
  TextColumn get alternateLink => text()();
  BoolColumn get isSubmitted => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedEmails extends Table {
  TextColumn get id => text()();
  TextColumn get sender => text()();
  TextColumn get subject => text()();
  TextColumn get snippet => text()();
  TextColumn get bodySummary => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get isAcademic => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Chats, AiMemories, CachedDeadlines, CachedEmails])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'deadlineai.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
