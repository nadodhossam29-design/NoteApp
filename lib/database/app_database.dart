// dart run build_runner build  <-- run this after adding dependencies
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'note.dart';
import 'note_dao.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [Note])
abstract class AppDatabase extends FloorDatabase {
  NoteDao get noteDao;

  static Future<AppDatabase> buildDatabase() async {
    return await $FloorAppDatabase
        .databaseBuilder('notes_app.db')
        .build();
  }
}
