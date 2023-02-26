import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/tag.dart';
import 'package:notes_app/notes_service.dart';

final isarPod = FutureProvider((ref) => Isar.open([NoteSchema, TagSchema]));

final notesServicePod = FutureProvider((ref) async {
  final isar = await ref.watch(isarPod.future);
  return NotesService(isar);
});
