import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  late final contentController = TextEditingController();
  late final titleController = TextEditingController();

  bool hasChangedContent = false;
  bool hasChangedTitle = false;

  bool isEdittingMode = false;

  Note? note;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    note = ref.watch(notePod(widget.noteId)).valueOrNull;
    if (note != null) contentController.text = note!.content;
    if (note != null) titleController.text = note!.title;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: titleController,
          readOnly: !isEdittingMode,
          onChanged: (value) => note?.title = value,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop('/'),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Text(
              '🏷️',
            ),
            tooltip: 'Tags',
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              readOnly: !isEdittingMode,
              expands: true,
              onChanged: (value) => note?.content = value,
            ),
          ),
          if (isEdittingMode)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: () async {
                    if (note != null) {
                      await ref
                          .read(notesServicePod)
                          .valueOrNull
                          ?.saveNote(note!);
                    }

                    /// delay and then set editting mode
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Save'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isEdittingMode = !isEdittingMode;
          });
        },
        child: AnimatedCrossFade(
          duration: 200.ms,
          firstChild: const Icon(Icons.cancel),
          secondChild: const Icon(Icons.edit),
          crossFadeState: isEdittingMode
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      ),
    );
  }
}
