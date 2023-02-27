import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/provider.dart';
import 'package:notes_app/widgets/note_card.dart';

final notesSearchPod =
    StreamProvider.family<List<Note>, String>((ref, query) async* {
  final isar = await ref.watch(notesServicePod.future);
  await for (final note in isar.search(query)) {
    yield note;
  }
});

final recentSearchesPod = StreamProvider((ref) async* {
  final isar = await ref.watch(notesServicePod.future);
  await for (final search in isar.recentSearches()) {
    yield search;
  }
});

class NotesSearchDelegate extends SearchDelegate<List<NoteCard>?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final notes = ref.watch(notesSearchPod(query)).valueOrNull;

        ref.read(notesServicePod).valueOrNull?.saveSearch(query);

        if (notes != null && notes.isEmpty) {
          return const Center(
            child: Text('No results...'),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          children: notes
                  ?.map(
                    (note) => NoteCard(
                      note: note,
                      key: ValueKey('note_${note.id}'),
                    ),
                  )
                  .toList() ??
              [],
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Consumer(
        builder: (context, ref, child) {
          final searches = ref.watch(recentSearchesPod).valueOrNull;

          if (searches != null && searches.isEmpty) {
            return const Center(
              child: Text(
                'Type to search...',
              ),
            );
          }

          return ListView(
            children: searches
                    ?.map(
                      (search) => ListTile(
                        title: Text(search.query),
                        onTap: () => query = search.query,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await ref
                                .read(notesServicePod)
                                .valueOrNull
                                ?.removeSearch(search.id);
                          },
                        ),
                      ),
                    )
                    .toList() ??
                [],
          );
        },
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final notes = ref.watch(notesSearchPod(query)).valueOrNull;

        if (notes != null && notes.isEmpty) {
          return const Center(
            child: Text('No results...'),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          children: notes
                  ?.map(
                    (note) =>
                        NoteCard(note: note, key: ValueKey('note_${note.id}')),
                  )
                  .toList() ??
              [],
        );
      },
    );
  }
}
