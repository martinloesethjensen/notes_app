import 'package:isar/isar.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/search.dart';
import 'package:notes_app/models/tag.dart';

class NotesService {
  const NotesService(this.isar);

  final Isar isar;

  Stream<List<Note>> search(
    String query, [
    NoteStatus status = NoteStatus.unarchived,
  ]) {
    return isar.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .or()
        .tags((tag) => tag.nameContains(query))
        .sortByDateTime()
        .watch(fireImmediately: true);
  }

  Stream<List<Search>> recentSearches() {
    return isar.searches
        .filter()
        .queryIsNotEmpty()
        .sortByDateTime()
        .watch(fireImmediately: true);
  }

  Future<bool> hasSearch(String query) async {
    final count = await isar.searches
        .filter()
        .queryEqualTo(query, caseSensitive: false)
        .count();
    return count >= 1;
  }

  Future<void> saveSearch(String query) async {
    final search = Search()..query = query;
    if (!await hasSearch(query)) {
      isar.writeTxnSync(() => isar.searches.putSync(search));
    }
  }

  Future<bool> removeSearch(int id) {
    return isar.writeTxn(() => isar.searches.delete(id));
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
