import 'package:floor/floor.dart';
import 'note.dart';

@dao
abstract class NoteDao {
  @Query('SELECT * FROM Note ORDER BY id DESC')
  Future<List<Note>> getAllNotes();

  @insert
  Future<void> insertNote(Note note);

  @update
  Future<void> updateNote(Note note);

  @delete
  Future<void> deleteNote(Note note);

  @Query('DELETE FROM Note')
  Future<void> deleteAllNotes();
}
