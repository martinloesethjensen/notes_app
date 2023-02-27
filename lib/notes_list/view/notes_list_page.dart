import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/provider.dart';
import 'package:notes_app/widgets/note_card.dart';
import 'package:notes_app/widgets/notes_search_delegate.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 80,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Notes'),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: NotesSearchDelegate(),
                  );
                },
              ),
            ],
          ),
          SliverGrid.count(
            crossAxisCount: 2,
            children: notes?.map((e) => NoteCard(note: e)).toList() ?? [],
          ),
        ],
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
