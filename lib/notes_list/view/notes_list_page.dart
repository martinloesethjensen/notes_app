import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/provider.dart';

final notesPod = StreamProvider((ref) async* {
  final isar = await ref.watch(notesServicePod.future);
  await for (final note in isar.watchNotes()) {
    yield note;
  }
});

class NotesListPage extends ConsumerStatefulWidget {
  const NotesListPage({super.key});

  @override
  ConsumerState<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends ConsumerState<NotesListPage> {
  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesPod).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      // TODO: add search bar to search / filter on notes
      body: notes == null
          ? const Center(
              child: Text('No notes'),
            )
          : GridView.count(
              crossAxisCount: 2,
              children: notes.map((e) => NoteCard(note: e)).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final notesService = ref.read(notesServicePod).valueOrNull;

          final untitledCount = await notesService?.getUntitledCount() ?? -1;

          final newNote = Note()
            ..title = 'Untitled${untitledCount >= 1 ? ' $untitledCount' : ''}';

          await notesService
              ?.saveNote(newNote)
              .then((_) => context.push('/note/${newNote.id}'));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteCard extends ConsumerWidget {
  const NoteCard({required this.note, super.key});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/note/${note.id}');
        },
        onLongPress: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete '${note.title}'"),
            content: const Text('Do you want to continue?'),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final service = await ref.read(notesServicePod.future);
                  await service
                      .removeNote(note.id)
                      .whenComplete(() => context.pop());
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                note.title,
              ),
              Wrap(
                children: [
                  for (final tag in note.tags)
                    Chip(
                      label: Text(tag.name),
                      backgroundColor: tag.color,
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
