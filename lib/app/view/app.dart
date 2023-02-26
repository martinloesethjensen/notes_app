import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notes_app/l10n/l10n.dart';
import 'package:notes_app/note_details/note_details.dart';
import 'package:notes_app/notes_list/notes_list.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Notes App',
      routerConfig: _router,
    );
  }
}

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotesListPage(),
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) => NoteDetailsPage(
        noteId: int.tryParse(state.params['id']!) ?? 0,
      ),
    ),
  ],
);
