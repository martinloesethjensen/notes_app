import 'package:isar/isar.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/tag.dart';

class NotesService {
  const NotesService(this.isar);

  final Isar isar;

  Stream<List<Note>> search(String query, [List<Tag> tags = const <Tag>[]]) {
    return isar.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .watch(fireImmediately: true);
  }

  Future<Note?> getNoteById(int id) {
    return isar.notes.where().idEqualTo(id).findFirst();
  }

  Future<void> saveNote(Note note) async {
    isar.writeTxnSync(() => isar.notes.putSync(note));
  }

  Future<void> saveTag(Tag tag) async {
    isar.writeTxnSync(() => isar.tags.putSync(tag));
  }

  Stream<List<Note>> watchNotes() {
    return isar.notes.filter().titleIsNotEmpty().watch(fireImmediately: true);
  }

  Future<int> getUntitledCount() {
    return isar.notes
        .filter()
        .titleContains('Untitled', caseSensitive: false)
        .count();
  }

  Future<bool> removeNote(int id) {
    return isar.writeTxn(() => isar.notes.delete(id));
  }

  Future<void> cleanDB() async => isar.writeTxn(isar.clear);
}
