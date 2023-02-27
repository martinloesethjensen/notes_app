import 'package:isar/isar.dart';
import 'package:notes_app/models/tag.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  late String title;

  String content = '';

  DateTime dateTime = DateTime.now().toUtc();

  @enumerated
  NoteStatus status = NoteStatus.unarchived;

  final tags = IsarLinks<Tag>();
}

enum NoteStatus { archived, unarchived }
