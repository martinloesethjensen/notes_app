import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/provider.dart';

class NoteDetailsPage extends ConsumerStatefulWidget {
  const NoteDetailsPage({required this.noteId, super.key});

  final int noteId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteDetailsPageState();
}

final notePod = StreamProvider.family<Note?, int>((ref, id) async* {
  final service = await ref.watch(notesServicePod.future);
  yield await service.getNoteById(id);
});

class _NoteDetailsPageState extends ConsumerState<NoteDetailsPage> {
  late final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final note = ref.watch(notePod(widget.noteId)).valueOrNull;
    if (note != null) controller.text = note.content;
    return Scaffold(
      appBar: AppBar(
        title: Text(note?.title ?? 'unknown'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop('/'),
        ),
      ),
      body: TextField(
        controller: controller,
        maxLines: null,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}
